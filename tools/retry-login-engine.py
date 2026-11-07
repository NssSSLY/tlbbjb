"""Retry the corrected engine on the already-owned second game, preserving the first game.
Reads the user's saved selection locally; never prints account names or credentials.
"""
from pathlib import Path
import argparse,base64,datetime,hashlib,json,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
parser=argparse.ArgumentParser()
parser.add_argument('--host-pid',type=int,required=True)
parser.add_argument('--target-pid',type=int,required=True)
parser.add_argument('--protected-pid',type=int,required=True)
parser.add_argument('--diagnostics',type=Path,required=True)
parser.add_argument('--data-root',type=Path)
parser.add_argument('--protected-data-root',type=Path)
args=parser.parse_args()
assert args.target_pid!=args.protected_pid
EXE=ROOT/'dist/TLBBClient-0.4.2/TLBB.exe'
OUT=ROOT/'artifacts/login-live-test'
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
log=OUT/f'{stamp}-engine-events.jsonl'
host=psutil.Process(args.host_pid) if psutil.pid_exists(args.host_pid) else None
source=args.data_root if args.data_root else Path(host.exe()).parent/'data'
assert source.resolve().is_relative_to(ROOT.resolve())
if host:
 commands=host.cmdline();position=commands.index('--protected-login-hash');protected_hash=commands[position+1]
else:
 assert args.protected_data_root and args.protected_data_root.resolve().is_relative_to(ROOT.resolve())
 original=json.loads((args.protected_data_root/'launcher.json').read_text(encoding='utf-8-sig'))
 selected=next(a for a in original['accounts'] if a['id']==original['selected_account'])
 protected_hash=hashlib.sha256(selected['login'].strip().casefold().split('@')[0].encode()).hexdigest()
config=json.loads((source/'launcher.json').read_text(encoding='utf-8-sig'))
account=next(a for a in config['accounts'] if a['id']==config['selected_account'])
fingerprint=hashlib.sha256(account['login'].strip().casefold().split('@')[0].encode()).hexdigest()
assert fingerprint!=protected_hash,'Protected account cannot be submitted'
diag=json.loads(args.diagnostics.read_text(encoding='utf-8-sig'))
assert not diag.get('login_busy') and not diag.get('launch_ticket_active'),'Host is still running a login attempt'
assert any(s.get('pid')==args.target_pid and s.get('source')=='launcher' for s in diag['sessions'])
target=psutil.Process(args.target_pid);protected=psutil.Process(args.protected_pid)
assert Path(target.exe()).resolve()==Path(protected.exe()).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve()
protected_created=protected.create_time()
def protected_alive():
 try:return psutil.Process(args.protected_pid).create_time()==protected_created
 except psutil.Error:return False
binding=OUT/f'{stamp}-target-binding.json'
result=subprocess.run([str(EXE),'--probe-binding','--target-pid',str(args.target_pid),'--game-root',str(ROOT.parent),'--report',str(binding)],capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
assert result.returncode==0
info=json.loads(binding.read_text(encoding='utf-8-sig'))
identity={'account':account['id'],'district':config['district'],'server':config['server'],'slot':account.get('slot',1)}
encoded=base64.urlsafe_b64encode(json.dumps(identity,ensure_ascii=False).encode()).decode()
base=[str(EXE),'--login-worker','--target-pid',str(args.target_pid),'--created',info['created'],'--game-root',str(ROOT.parent),'--identity',encoded]
probe=subprocess.run([*base,'--login-read-only'],capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
assert probe.returncode==0,'Game state query is not ready'
state=[json.loads(line) for line in probe.stdout.decode('utf-8-sig').splitlines() if line][-1]
assert state['stage'] in (1,2) and state['actions']==0,'Second game is no longer at an unauthenticated login screen'
assert protected_alive()
with log.open('w',encoding='utf-8') as out, (OUT/f'{stamp}-engine-stderr.log').open('wb') as err:
 process=subprocess.Popen([*base,'--data-root',str(source)],stdout=out,stderr=err,creationflags=subprocess.CREATE_NO_WINDOW)
 deadline=time.monotonic()+320;last=0;terminal=None
 print(json.dumps({'event':'engine_retry_started','pid':process.pid,'target_pid':args.target_pid,'protected_pid':args.protected_pid,'password_on_command_line':False}),flush=True)
 while time.monotonic()<deadline:
  if not protected_alive():process.terminate();raise RuntimeError('Original game exited; test engine stopped')
  lines=log.read_text(encoding='utf-8-sig').splitlines()
  for line in lines[last:]:
   try:item=json.loads(line)
   except json.JSONDecodeError:continue
   allowed={k:v for k,v in item.items() if k in ('event','message','stage','command','bridge_status','win32_error','verified_world_samples')}
   print(json.dumps({**allowed,'protected_game_alive':True},ensure_ascii=False),flush=True)
   if item.get('event') in ('complete','failed','skipped'):terminal=item
  last=len(lines)
  if process.poll() is not None:break
  time.sleep(.5)
 if process.poll() is None:process.terminate();process.wait(timeout=5)
 final={'target_pid':args.target_pid,'protected_pid':args.protected_pid,'exit_code':process.returncode,'protected_game_alive':protected_alive(),'terminal':terminal,'engine_sha256':hashlib.sha256(EXE.read_bytes()).hexdigest()}
 (OUT/f'{stamp}-engine-result.json').write_text(json.dumps(final,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 if terminal and terminal.get('event')=='complete':
  private=ROOT/'user-data/login-verification';private.mkdir(parents=True,exist_ok=True)
  (private/f'{stamp}-verified-roles.json').write_text(json.dumps({'identity':identity,'target_created':info['created'],**final},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print(json.dumps({'event':'engine_retry_finished','exit_code':process.returncode,'result':terminal.get('event') if terminal else None,'protected_game_alive':protected_alive()},ensure_ascii=False),flush=True)
