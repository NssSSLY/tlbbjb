"""Check 0.4 delivery hashes and record exactly which login tests were performed."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[1]
stage=ROOT/'dist/TLBBClient-0.4.0'
def read(path):return json.loads(path.read_text(encoding='utf-8-sig'))
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
manifest=read(stage/'package-manifest.json')
release=read(ROOT/'artifacts/release-verification-0.4.json')
login=read(ROOT/'artifacts/native-ui-0.4/login-tests.json')
probe=read(ROOT/'artifacts/login-readonly/verification.json')
installer=read(ROOT/'artifacts/installer-build-0.4.json')
package=read(ROOT/'artifacts/package-0.4.json')
current=sha(stage/'TLBB.exe')
assert release['status']=='pass' and login['status']=='pass'
assert current==release['sha256']==installer['ExecutableSHA256'].lower()
assert sha(Path(installer['Installer']))==installer['SHA256'].lower()
assert sha(Path(package['zip']))==package['zip_sha256']
for entry in manifest['files']:
 file=stage/entry['path'];assert sha(file)==entry['sha256'] and file.stat().st_size==entry['bytes']
assert len(probe)==1 and probe[0]['exit_code']==0 and probe[0]['credentials_loaded'] is False
assert probe[0]['exe_sha256']==current and probe[0]['login_bridge_sha256']==sha(stage/'TLBBLoginBridge.dll')
assert probe[0]['login_actions_issued']==0 and probe[0]['game_alive_after']
report={'version':'0.4.0','status':'pass','exe':str(stage/'TLBB.exe'),'exe_sha256':current,
        'setup':installer['Installer'],'setup_sha256':installer['SHA256'].lower(),'setup_bytes':installer['Bytes'],
        'zip':package['zip'],'zip_sha256':package['zip_sha256'],'zip_bytes':package['zip_bytes'],
        'payload_files':len(manifest['files'])+1,'lua_files':len(manifest['scripts']),
        'core_test_groups':release['core_test_count'],'native_window_checks':release['native_ui_check_count'],
        'login_checks':len(login['checks']),'live_readonly_probe':probe[0],
        'real_automatic_authentication_verified':False,'installer_installed_this_turn':False,
        'installer_note':'0.3 launcher remains running; generated update installer without replacing the current installation',
        'private_data_excluded':package['private_data_excluded'],
        'previous_03_exe_sha256':sha(ROOT/'dist/TLBBClient-0.3.0/TLBB.exe') if (ROOT/'dist/TLBBClient-0.3.0/TLBB.exe').exists() else read(ROOT/'artifacts/delivery-0.4.json')['previous_03_exe_sha256']}
(ROOT/'artifacts/delivery-0.4.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
rows=['# 0.4.0 完整软件包文件清单','','检查目录：`'+str(stage)+'`','','完整包和安装包由同一发布目录生成，本表按 package-manifest.json 核对大小及 SHA256。此次未覆盖运行中的旧版安装；实际安装还会生成卸载器文件。','','| 相对路径 | 字节 |','|---|---:|']
rows.extend('| '+e['path']+' | '+str(e['bytes'])+' |' for e in manifest['files'])
rows.extend(['| package-manifest.json | '+str((stage/'package-manifest.json').stat().st_size)+' |','','运行时还会使用 data/profiles/、data/credentials/、scripts/user/、logs/ 和 cache/；完整包不包含真实账号、密码或用户脚本。'])
(ROOT/'artifacts/软件包文件清单-0.4.md').write_text('\n'.join(rows)+'\n',encoding='utf-8')
print(json.dumps({key:report[key] for key in ['status','payload_files','lua_files','core_test_groups','native_window_checks','login_checks','setup_bytes','zip_bytes','exe_sha256']},ensure_ascii=False))
