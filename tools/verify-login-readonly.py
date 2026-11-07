"""Probe the allowlisted login adapter with Query only. Never load stored accounts."""
from pathlib import Path
import base64,json,subprocess,sys,hashlib,argparse
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
parser=argparse.ArgumentParser()
parser.add_argument('--pid',type=int)
parser.add_argument('--exe',type=Path,default=ROOT/'dist/TLBBClient-0.4.1/TLBB.exe')
parser.add_argument('--out',type=Path,default=ROOT/'artifacts/login-readonly-0.4.1')
args=parser.parse_args()
EXE=args.exe
out=args.out
out.mkdir(parents=True,exist_ok=True)
games=[]
for process in psutil.process_iter(['pid','name','exe']):
 try:
  if process.info['name'].lower()=='game.exe' and Path(process.info['exe']).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve() and (args.pid is None or args.pid==process.info['pid']):games.append(process.info['pid'])
 except (psutil.Error,AttributeError,TypeError):pass
if not games:
 print(json.dumps({'status':'not_run','reason':'no_game_online'}));sys.exit(0)
reports=[]
for pid in games[:1]:
 result=subprocess.run([str(EXE),'--probe-binding','--target-pid',str(pid),'--game-root',str(ROOT.parent),'--report',str(out/'binding.json')],capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
 assert result.returncode==0,'Read-only binding failed'
 binding=json.loads((out/'binding.json').read_text(encoding='utf-8-sig'))
 identity=base64.urlsafe_b64encode(json.dumps({'district':'read-only-probe','server':'read-only-probe','slot':1}).encode()).decode()
 result=subprocess.run([str(EXE),'--login-worker','--login-read-only','--target-pid',str(pid),'--created',binding['created'],'--game-root',str(ROOT.parent),'--identity',identity],capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
 events=[json.loads(line) for line in result.stdout.decode('utf-8-sig').splitlines() if line]
 report={'pid':pid,'exit_code':result.returncode,'events':events,'game_alive_after':psutil.pid_exists(pid),'credentials_loaded':False,'login_actions_issued':sum(e.get('actions',0) for e in events),'exe_sha256':hashlib.sha256(EXE.read_bytes()).hexdigest(),'login_bridge_sha256':hashlib.sha256((EXE.parent/'TLBBLoginBridge.dll').read_bytes()).hexdigest()}
 reports.append(report)
 assert report['login_actions_issued']==0 and report['game_alive_after']
(out/'verification.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(reports,ensure_ascii=False))
