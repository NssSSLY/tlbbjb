"""One bounded test of the launcher's normal auto-start flow; no credentials in output/CLI."""
from pathlib import Path
import argparse,datetime,json,shutil,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
parser=argparse.ArgumentParser();parser.add_argument('--seconds',type=int,default=360);parser.add_argument('--version',default='0.5.2');parser.add_argument('--source-version',default='0.5.1');parser.add_argument('--replace-test-host',type=int,default=0);args=parser.parse_args()
assert 30<=args.seconds<=600
exe=ROOT/f'dist/TLBBClient-{args.version}/TLBB.exe';old=ROOT/f'dist/TLBBClient-{args.source_version}/data';target=exe.parent/'data'
assert exe.resolve().is_relative_to(ROOT.resolve()) and old.resolve().is_relative_to(ROOT.resolve())
if args.replace_test_host:
    owned=psutil.Process(args.replace_test_host)
    assert Path(owned.exe()).resolve()==(old.parent/'TLBB.exe').resolve() and '--auto-start' in owned.cmdline()
    recorded=False
    for file in (ROOT/'artifacts/login-live-test').glob('*-events.jsonl'):
        for line in file.read_text(encoding='utf-8-sig').splitlines():
            item=json.loads(line)
            if item.get('event')=='automatic_test_started' and item.get('launcher_pid')==owned.pid:
                recorded=abs(datetime.datetime.fromisoformat(item['time']).timestamp()-owned.create_time())<3
    assert recorded,'Only a test host created by this tool can be replaced'
    commands=owned.cmdline();diagnostic=Path(commands[commands.index('--diagnostics')+1]);state=json.loads(diagnostic.read_text(encoding='utf-8-sig'))
    assert not state.get('login_busy') and not state.get('launch_ticket_active') and not state.get('sessions'),'Test host is not idle'
    assert not any(p.info['name'].lower()=='game.exe' and p.info['exe'] and Path(p.info['exe']).resolve().is_relative_to(ROOT.parent.resolve()) for p in psutil.process_iter(['name','exe']))
    owned.terminate();owned.wait(timeout=5)
for process in psutil.process_iter(['pid','name','exe']):
    try:
        path=Path(process.info['exe']).resolve() if process.info['exe'] else None
        if path and path.is_relative_to(ROOT.parent.resolve()) and process.info['name'].lower() in ('game.exe','launch.exe','launch.bin','tlbb.exe'):
            raise RuntimeError('Existing launcher/game detected; do not start a second login automatically')
    except (psutil.NoSuchProcess,psutil.AccessDenied):pass
if not any(p.is_file() for p in target.rglob('*')):shutil.copytree(old,target,dirs_exist_ok=True)
config=json.loads((target/'launcher.json').read_text(encoding='utf-8-sig'))
selected=next((a for a in config.get('accounts',[]) if a.get('id')==config.get('selected_account')),None)
assert selected and selected.get('login') and selected.get('credential_ref')==selected['id'],'Saved selected account is incomplete'
out=ROOT/'artifacts/login-live-test';out.mkdir(parents=True,exist_ok=True)
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S');diagnostic=out/f'{stamp}-host.json';events=out/f'{stamp}-events.jsonl'
def emit(item):
    item={'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),**item}
    line=json.dumps(item,ensure_ascii=False)
    with events.open('a',encoding='utf-8') as file:file.write(line+'\n')
    print(line,flush=True)
process=subprocess.Popen([str(exe),'--auto-start','--protect-first-login','--diagnostics',str(diagnostic)],cwd=exe.parent,creationflags=subprocess.CREATE_NO_WINDOW)
emit({'event':'automatic_test_started','launcher_pid':process.pid,'preexisting_games':0,'password_in_command_line':False})
deadline=time.monotonic()+args.seconds;previous=None;busy_seen=False;quiet_since=None;state={}
while time.monotonic()<deadline and process.poll() is None:
    try:state=json.loads(diagnostic.read_text(encoding='utf-8-sig'))
    except (OSError,json.JSONDecodeError):time.sleep(.5);continue
    current={'event':'launcher_state','status':state.get('launcher_status'),'launching':state.get('launch_ticket_active'),
             'logging_in':state.get('login_busy'),'login_worker_pid':state.get('login_worker_pid'),
             'sessions':[{'pid':s.get('pid'),'source':s.get('source'),'ready':s.get('ready')} for s in state.get('sessions',[])]}
    if current!=previous:emit(current);previous=current
    busy=bool(current['launching'] or current['logging_in'])
    if busy:busy_seen=True;quiet_since=None
    elif busy_seen:
        quiet_since=quiet_since or time.monotonic()
        if time.monotonic()-quiet_since>4:break
    time.sleep(.5)
emit({'event':'observer_finished','launcher_running':process.poll() is None,'last_status':state.get('launcher_status'),
      'protected_game_pid':state.get('protected_game_pid'),'diagnostic':str(diagnostic),'events':str(events)})
# Leave the launcher, official updater and every game intact.
