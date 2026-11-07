"""Isolate the instrumented login test build and preserve the previously verified release."""
from pathlib import Path
import hashlib,json,shutil,sys,zipfile
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
stage=ROOT/'dist/TLBBClient-0.4.0'
target=ROOT/'dist/TLBBClient-0.4.0-login-test'
def sha(data):return hashlib.sha256(data).hexdigest()
delivery=json.loads((ROOT/'artifacts/delivery-0.4.json').read_text(encoding='utf-8-sig'))
manifest=json.loads((stage/'package-manifest.json').read_text(encoding='utf-8'))
test_bytes=(stage/'TLBB.exe').read_bytes()
assert not target.exists(),'Test runtime already exists; inspect before replacing it'
with zipfile.ZipFile(delivery['zip']) as archive:
 assert sha(Path(delivery['zip']).read_bytes())==delivery['zip_sha256']
 release_bytes=archive.read('TLBBClient/TLBB.exe')
assert sha(release_bytes)==delivery['exe_sha256']
for process in psutil.process_iter(['pid','exe']):
 try:
  if process.info['exe'] and Path(process.info['exe']).resolve()==(stage/'TLBB.exe').resolve():raise RuntimeError('Release executable is in use; leave it unchanged')
 except (psutil.AccessDenied,psutil.NoSuchProcess):pass
target.mkdir()
for entry in manifest['files']:
 source=stage/entry['path'];destination=target/entry['path']
 destination.parent.mkdir(parents=True,exist_ok=True)
 if entry['path']!='TLBB.exe':assert sha(source.read_bytes())==entry['sha256']
 shutil.copy2(source,destination)
 if entry['path']=='TLBB.exe':entry['sha256']=sha(test_bytes);entry['bytes']=len(test_bytes)
for folder in ['data/profiles','scripts/user','logs','cache']:(target/folder).mkdir(parents=True,exist_ok=True)
manifest['test_instrumentation']=True
manifest['published_release_exe_sha256']=delivery['exe_sha256']
(target/'package-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(stage/'TLBB.exe').write_bytes(release_bytes)
for entry in manifest['files']:assert sha((target/entry['path']).read_bytes())==entry['sha256']
report={'test_exe':str(target/'TLBB.exe'),'test_exe_sha256':sha(test_bytes),'published_exe':str(stage/'TLBB.exe'),
        'published_exe_sha256':sha(release_bytes),'authentication_behavior_changed':False,
        'instrumentation':'launcher status and login busy state exposed in opt-in diagnostics',
        'real_login_attempted':False}
(ROOT/'artifacts/login-live-test/runtime.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(ROOT/'artifacts/client-build.json').write_text(json.dumps({'Executable':report['test_exe'],'SHA256':report['test_exe_sha256'],
    'TestsSkipped':False,'PublishedReleasePreserved':True,'PublishedSHA256':report['published_exe_sha256']},indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
