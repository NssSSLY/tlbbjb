"""Bounded observer for a user-operated login test. Does not read credentials or press UI controls."""
from pathlib import Path
import argparse,datetime,hashlib,json,subprocess,sys,time
import shutil
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
parser=argparse.ArgumentParser()
parser.add_argument('--protected-pid',type=int,default=0)
parser.add_argument('--seconds',type=int,default=300)
parser.add_argument('--attempts',type=int,default=1)
args=parser.parse_args()
assert 1<=args.seconds<=600
EXE=ROOT/'dist/TLBBClient-0.4.2/TLBB.exe'
OLD=ROOT/'dist/TLBBClient-0.4.1/TLBB.exe'
OUT=ROOT/'artifacts/login-live-test'
OUT.mkdir(parents=True,exist_ok=True)
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
diagnostic=OUT/f'{stamp}-host.json'
record=OUT/f'{stamp}-events.jsonl'
protected_created=None
protected_fingerprint=''
try:
 initial=json.loads((OLD.parent/'data/launcher.json').read_text(encoding='utf-8-sig'))
 account=next((a for a in initial.get('accounts',[]) if a.get('id')==initial.get('selected_account')),None)
 if account and account.get('login'):
  canonical=account['login'].strip().casefold().split('@')[0]
  protected_fingerprint=hashlib.sha256(canonical.encode()).hexdigest()
except (OSError,json.JSONDecodeError):pass
if args.protected_pid:
 protected=psutil.Process(args.protected_pid)
 protected_created=protected.create_time()
 assert Path(protected.exe()).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve()
def alive():
 if not args.protected_pid:return True
 try:return psutil.Process(args.protected_pid).create_time()==protected_created
 except psutil.Error:return False
def matching(path):
 found=[]
 for p in psutil.process_iter(['pid','exe']):
  try:
   if p.info['exe'] and Path(p.info['exe']).resolve()==path.resolve():found.append(p.info['pid'])
  except (psutil.Error,OSError):pass
 return found
def emit(data):
 data={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),**data,'original_game_process_alive':alive() if args.protected_pid else None}
 text=json.dumps(data,ensure_ascii=False)
 with record.open('a',encoding='utf-8') as file:file.write(text+'\n')
 print(text,flush=True)
deadline=time.monotonic()+args.seconds
emit({'event':'waiting_previous_launcher_exit','previous_pids':matching(OLD),'protected_pid':args.protected_pid})
while matching(OLD) and time.monotonic()<deadline:
 if not alive():emit({'event':'protected_game_exited'});sys.exit(2)
 time.sleep(1)
if matching(OLD):emit({'event':'waiting_user','reason':'previous_launcher_still_running'});sys.exit(0)
if matching(EXE):emit({'event':'waiting_user','reason':'new_launcher_already_running_without_this_observer'});sys.exit(0)
if not alive():emit({'event':'protected_game_exited'});sys.exit(2)
source_data=OLD.parent/'data'
target_data=EXE.parent/'data'
if source_data.is_dir() and not any(p.is_file() for p in target_data.rglob('*')):
 shutil.copytree(source_data,target_data,dirs_exist_ok=True)
 config_path=target_data/'launcher.json'
 if config_path.exists():
  config=json.loads(config_path.read_text(encoding='utf-8-sig'));config['selected_account']='';config['multi_open']=True
  if not args.protected_pid:
   try:
    original=json.loads((ROOT/'dist/TLBBClient-0.4.0-login-test/data/launcher.json').read_text(encoding='utf-8-sig'))
    first=next(a for a in original['accounts'] if a['id']==original['selected_account'])
    original_key=hashlib.sha256(first['login'].strip().casefold().split('@')[0].encode()).hexdigest()
    config['selected_account']=next(a['id'] for a in config['accounts'] if hashlib.sha256(a['login'].strip().casefold().split('@')[0].encode()).hexdigest()==original_key)
   except (OSError,KeyError,StopIteration,json.JSONDecodeError):pass
  config_path.write_text(json.dumps(config,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
launch=[str(EXE),'--diagnostics',str(diagnostic)]
if args.protected_pid and protected_fingerprint:launch+=['--protected-login-hash',protected_fingerprint]
elif not args.protected_pid:launch+=['--protect-first-login']
process=subprocess.Popen(launch,cwd=str(EXE.parent),creationflags=subprocess.CREATE_NO_WINDOW)
emit({'event':'launcher_started','pid':process.pid,'exe_sha256':hashlib.sha256(EXE.read_bytes()).hexdigest(),'diagnostics':str(diagnostic)})
last=None;seen_busy=False;stopped_at=None;attempts_finished=0;in_attempt=False
while time.monotonic()<deadline and process.poll() is None:
 if not alive():emit({'event':'protected_game_exited'});sys.exit(2)
 try:state=json.loads(diagnostic.read_text(encoding='utf-8-sig'))
 except (OSError,json.JSONDecodeError):time.sleep(.5);continue
 if not args.protected_pid and state.get('protected_game_pid'):
  args.protected_pid=int(state['protected_game_pid']);protected_created=psutil.Process(args.protected_pid).create_time()
  emit({'event':'first_login_protected','protected_pid':args.protected_pid})
 # Explicit allowlist: never emit account identifiers, stored profiles or configuration contents.
 item={'event':'status','status':state.get('launcher_status'),'login_busy':state.get('login_busy'),
       'launch_ticket_active':state.get('launch_ticket_active'),'login_worker_pid':state.get('login_worker_pid'),
       'sessions':[{'pid':s.get('pid'),'source':s.get('source'),'ready':s.get('ready')} for s in state.get('sessions',[])]}
 if item!=last:emit(item);last=item
 busy=item['login_busy'] or item['launch_ticket_active']
 if busy:seen_busy=True;in_attempt=True;stopped_at=None
 elif in_attempt:
  stopped_at=stopped_at or time.monotonic()
  if time.monotonic()-stopped_at>3:
   attempts_finished+=1;emit({'event':'test_attempt_ended','status':item['status'],'attempt_number':attempts_finished});in_attempt=False;stopped_at=None
   if attempts_finished>=args.attempts:break
 time.sleep(.5)
emit({'event':'observer_finished','launcher_still_running':process.poll() is None,'login_attempt_observed':seen_busy})
