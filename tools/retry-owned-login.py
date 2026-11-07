"""Continue one uncredentialed game owned by the current test launcher; refuse password replay."""
from pathlib import Path
import argparse,base64,datetime,json,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
p=argparse.ArgumentParser();p.add_argument('--host-pid',type=int,required=True);p.add_argument('--target-pid',type=int,required=True);p.add_argument('--diagnostics',type=Path,required=True);p.add_argument('--version',default='0.5.2');args=p.parse_args()
host=psutil.Process(args.host_pid);source=Path(host.exe()).parent/'data';assert source.resolve().is_relative_to(ROOT.resolve())
diag=json.loads(args.diagnostics.read_text(encoding='utf-8-sig'));assert not diag.get('login_busy') and not diag.get('launch_ticket_active')
target=next(s for s in diag['sessions'] if s['pid']==args.target_pid and s['source']=='launcher')
assert Path(psutil.Process(args.target_pid).exe()).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve()
for process in psutil.process_iter(['pid','exe']):
    try:
        if process.info['exe'] and Path(process.info['exe']).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve():assert process.pid==args.target_pid,'Other online game exists; refuse an automatic account test'
    except (psutil.NoSuchProcess,psutil.AccessDenied):pass
for file in [source/'logs/login-events.jsonl',*list((ROOT/'artifacts/login-live-test').glob('*-owned-engine.jsonl'))]:
    if not file.exists():continue
    for line in file.read_text(encoding='utf-8-sig').splitlines():
        try:item=json.loads(line)
        except json.JSONDecodeError:continue
        assert not (item.get('target_pid')==args.target_pid and item.get('command')==3),'A credential action was already attempted for this game; no replay'
config=json.loads((source/'launcher.json').read_text(encoding='utf-8-sig'));account=next(a for a in config['accounts'] if a['id']==config['selected_account'])
identity={'account':account['id'],'district':config['district'],'server':config['server'],'slot':account.get('slot',1)}
encoded=base64.urlsafe_b64encode(json.dumps(identity,ensure_ascii=False).encode()).decode();exe=ROOT/f'dist/TLBBClient-{args.version}/TLBB.exe'
base=[str(exe),'--login-worker','--target-pid',str(args.target_pid),'--created',target['created'],'--game-root',str(ROOT.parent),'--identity',encoded]
probe=subprocess.run([*base,'--login-read-only'],capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
assert probe.returncode==0,'Read-only game state query failed'
state=[json.loads(x) for x in probe.stdout.decode('utf-8-sig').splitlines() if x][-1]
assert state['stage'] in (1,2) and state['actions']==0,'Target no longer at an uncredentialed login stage'
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S');out=ROOT/'artifacts/login-live-test';log=out/f'{stamp}-owned-engine.jsonl';terminal=None
with log.open('w',encoding='utf-8') as stream:
    process=subprocess.Popen([*base,'--data-root',str(source)],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,creationflags=subprocess.CREATE_NO_WINDOW)
    for raw in process.stdout:
        item=json.loads(raw.decode('utf-8-sig'));allowed={k:v for k,v in item.items() if k in ('event','message','stage','command','bridge_status','win32_error','verified_world_samples')};allowed['target_pid']=args.target_pid
        stream.write(json.dumps(allowed,ensure_ascii=False)+'\n');stream.flush();print(json.dumps(allowed,ensure_ascii=False),flush=True)
        if item.get('event') in ('complete','failed','skipped'):terminal=item
    process.wait(timeout=15)
result={'version':args.version,'target_pid':args.target_pid,'target_created':target['created'],'terminal':terminal,'exit_code':process.returncode,'game_preserved':psutil.pid_exists(args.target_pid)}
private=ROOT/'user-data/login-verification';private.mkdir(parents=True,exist_ok=True);(private/f'{stamp}-result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'event':'test_ended','result':terminal.get('event') if terminal else None,'game_preserved':result['game_preserved']},ensure_ascii=False))
