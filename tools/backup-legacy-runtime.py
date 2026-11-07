"""Back up non-runtime files before user-authorized legacy release cleanup. No credentials printed."""
from pathlib import Path
import datetime,hashlib,json,os,sys,zipfile,argparse
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
parser=argparse.ArgumentParser();parser.add_argument('--prior-login-builds',action='store_true');args=parser.parse_args()
roots=[ROOT/'dist/TLBBClient',ROOT/'dist/TLBBClient-0.3.0',ROOT/'dist/installed-preview/TLBBClient']
packages=[ROOT/'dist/packages/TLBBClient-0.3.0-full.zip',ROOT/'dist/packages/TLBBClient-0.3.0-Setup.exe']
if args.prior_login_builds:
 roots=[ROOT/'dist/TLBBClient-0.4.0',ROOT/'dist/TLBBClient-0.4.0-login-test',ROOT/'dist/TLBBClient-0.4.1']
 packages=[ROOT/f'dist/packages/TLBBClient-{v}-{suffix}' for v in ('0.4.0','0.4.1') for suffix in ('full.zip','Setup.exe')]
for root in roots:
 assert root.resolve().is_relative_to((ROOT/'dist').resolve())
for process in psutil.process_iter(['pid','exe']):
 try:
  path=Path(process.info['exe']).resolve() if process.info['exe'] else None
  if path and any(path.is_relative_to(root.resolve()) for root in roots):raise RuntimeError('A legacy runtime is still running')
 except (psutil.NoSuchProcess,psutil.AccessDenied):pass
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
backup=ROOT/'user-data/legacy-backups'/stamp
backup.mkdir(parents=True)
archive=backup/'private-user-files.zip'
def digest(file):
 with file.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
entries=[];inventory=[]
with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED) as z:
 for root in roots:
  if not root.exists():continue
  total=0;files=0
  for path in root.rglob('*'):
   if getattr(path.stat(),'st_file_attributes',0)&0x400:raise RuntimeError('Reparse points require manual inspection')
   if not path.is_file():continue
   assert path.resolve().is_relative_to(root.resolve())
   rel=path.relative_to(root);total+=path.stat().st_size;files+=1
   private=bool(set(rel.parts)&{'data','user-data','logs','user'})
   generated=path.suffix.lower() in {'.exe','.dll'} and not private
   if generated:continue
   name=path.relative_to(ROOT).as_posix();z.write(path,name)
   entries.append({'source':str(path),'archive_name':name,'sha256':digest(path),'bytes':path.stat().st_size})
  inventory.append({'root':str(root),'files':files,'bytes':total})
with zipfile.ZipFile(archive) as z:
 for entry in entries:
  with z.open(entry['archive_name']) as stream:assert hashlib.file_digest(stream,'sha256').hexdigest()==entry['sha256']
report={'status':'backed_up','archive':str(archive),'archive_sha256':digest(archive),'private_archive_do_not_distribute':True,
        'preserved_files':entries,'inventory':inventory,
        'deletion_targets':[str(p) for p in (roots if args.prior_login_builds else roots[:2])+packages if p.exists()],
        'installed_preview_requires_registered_uninstaller':None if args.prior_login_builds else str(roots[2])}
report_path=ROOT/('artifacts/legacy-cleanup-preparation-0.4.json' if args.prior_login_builds else 'artifacts/legacy-cleanup-preparation.json')
report_path.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'status':report['status'],'backup':str(archive),'preserved_file_count':len(entries),'candidate_bytes':sum(x['bytes'] for x in inventory)+sum(x.stat().st_size for x in packages if x.exists())},ensure_ascii=False))
