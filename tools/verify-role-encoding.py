"""Query cached role UI text in the already-verified world; never authenticate or print names."""
from pathlib import Path
import base64,hashlib,json,shutil,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
EXE=ROOT/'dist/TLBBClient-0.5.4/TLBB.exe'
evidence=json.loads((ROOT/'artifacts/login-live-test/verified-0.5.2.json').read_text(encoding='utf-8'))
pid=evidence['target_pid']
out=ROOT/'artifacts/role-encoding-0.5.4';out.mkdir(parents=True,exist_ok=True)
if not psutil.pid_exists(pid):
    report={'status':'not_run','reason':'verified_game_not_running','credentials_loaded':False,'actions':0}
    (out/'verification.json').write_text(json.dumps(report)+'\n',encoding='utf-8')
    print(json.dumps(report));sys.exit(0)
game=psutil.Process(pid)
assert Path(game.exe()).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve()
state=json.loads((ROOT/'artifacts/login-live-test/20261025-010937-host.json').read_text(encoding='utf-8-sig'))
assert state['protected_game_pid']==pid and state['protected_login_guard'] and not state['login_busy']
source=ROOT/'dist/TLBBClient-0.5.2/data'
config=json.loads((source/'launcher.json').read_text(encoding='utf-8-sig'))
account=next(a for a in config['accounts'] if a['id']==state['protected_account_key'])
created=next(s['created'] for s in state['sessions'] if s['pid']==pid)
# Compare process creation time via the native binding before touching its query interface.
subprocess.run([str(EXE),'--probe-binding','--target-pid',str(pid),'--game-root',str(ROOT.parent),'--report',str(out/'binding.json')],check=True,capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
assert json.loads((out/'binding.json').read_text(encoding='utf-8-sig'))['created']==created
identity={'district':account['district'],'server':account['server'],'slot':account['slot']}
encoded=base64.urlsafe_b64encode(json.dumps(identity).encode()).decode()
result=subprocess.run([str(EXE),'--login-worker','--login-read-only','--include-cached-roles','--target-pid',str(pid),'--created',created,'--game-root',str(ROOT.parent),'--identity',encoded],capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
events=[json.loads(s) for s in result.stdout.decode('utf-8-sig').splitlines() if s]
private=ROOT/'user-data/role-encoding-verification';private.mkdir(parents=True,exist_ok=True)
(private/'probe.json').write_text(json.dumps(events,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
probe=next((e for e in events if e.get('event')=='probe'),{})
names=probe.get('roles',{})
assert result.returncode==0 and probe.get('stage')==4 and probe.get('actions')==0,'Read-only query did not confirm the same world'
assert names and all(k in ['1','2','3'] and isinstance(v,str) and v and len(v)<=64 and '\ufffd' not in v for k,v in names.items()),'Role cache is unavailable; do not guess names'
target=EXE.parent/'data'
if not any(p.is_file() for p in target.rglob('*')):shutil.copytree(source,target,dirs_exist_ok=True)
current=json.loads((target/'launcher.json').read_text(encoding='utf-8-sig'))
for a in current['accounts']:
    if a['id']!=account['id']:continue
    key=identity['district']+'/'+identity['server'];dest=a.setdefault('destinations',{}).setdefault(key,{})
    backup=target/'migrations/launcher-before-role-query-utf8.json';backup.parent.mkdir(parents=True,exist_ok=True)
    if not backup.exists():backup.write_bytes((target/'launcher.json').read_bytes())
    dest['roles']=names;dest['role_text_encoding']='cegui-utf8-v1'
temp=target/'launcher.utf8-repair.tmp';temp.write_text(json.dumps(current,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');temp.replace(target/'launcher.json')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report={'status':'pass','version':'0.5.4','query_only':True,'credentials_loaded':False,'actions':0,'stage':4,'role_count':len(names),'encoding':'cegui-utf8-v1','game_preserved':game.is_running(),'runtime_cache_repaired':True,'private_data_published':False,'exe_sha256':sha(EXE),'login_bridge_sha256':sha(EXE.parent/'TLBBLoginBridge.dll')}
(out/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
