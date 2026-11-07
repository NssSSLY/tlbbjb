"""Audit this refactor and write a delivery receipt; never read private profiles."""
from pathlib import Path
import hashlib
import json

ROOT=Path(__file__).resolve().parents[1]
VERSION='0.11.0'
STAGE=ROOT/f'dist/TLBBClient-{VERSION}'

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()

def save(name,data):
    (ROOT/'artifacts'/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

release=read(ROOT/f'artifacts/release-verification-{VERSION}.json')
package=read(ROOT/f'artifacts/package-{VERSION}.json')
installer=read(ROOT/f'artifacts/installer-build-{VERSION}.json')
manifest=read(STAGE/'package-manifest.json')
assert release['status']=='pass' and release['sha256']==sha(STAGE/'TLBB.exe')
assert release['engine_sha256']==sha(STAGE/'TLBBEngine.dll')
assert installer['SHA256'].lower()==sha(Path(installer['Installer']))
assert installer['ExecutableSHA256'].lower()==release['sha256']
assert package['zip_sha256']==sha(Path(package['zip']))
for entry in manifest['files']:
    assert sha(STAGE/entry['path'])==entry['sha256']

baseline_dir=ROOT/'artifacts/pre-resident-0.11.0'
baseline=read(baseline_dir/'baseline.json')
for name,digest in baseline.items():
    assert sha(baseline_dir/name)==digest, f'Backup changed: {name}'
current={}
for folder in ['src','include','scripts','tests','tools','packaging','design']:
    for path in (ROOT/folder).rglob('*'):
        if path.is_file() and not any(p in {'user','__pycache__','.git'} for p in path.relative_to(ROOT).parts):
            current[str(path.relative_to(ROOT))]=sha(path)
current['CMakeLists.txt']=sha(ROOT/'CMakeLists.txt')
changes={'baseline_file_count':len(baseline),'changed':[],'added':[],'removed':[]}
for name,digest in baseline.items():
    if name not in current:
        changes['removed'].append(name)
    elif current[name]!=digest:
        changes['changed'].append({'path':name,'before':digest,'after':current[name]})
for name,digest in current.items():
    if name not in baseline:
        changes['added'].append({'path':name,'sha256':digest})
assert not changes['removed']
preserved={name:baseline[name]==current[name] for name in ['include\\game_lua_login.hpp','scripts\\legacy\\manifest.json','design\\task-catalog.json']}
assert all(preserved.values())
changes['preserved']=preserved
save(f'resident-changes-{VERSION}.json',changes)

previous=read(ROOT/'artifacts/package-0.10.0.json')
comparison={}
for version,receipt in [('0.10.0',previous),(VERSION,package)]:
    directory=ROOT/f'dist/TLBBClient-{version}'
    dlls=list(directory.rglob('*.dll'))
    comparison[version]={'runtime_bytes':receipt['runtime_bytes'],'dll_count':len(dlls),
        'dll_bytes':sum(p.stat().st_size for p in dlls),'file_count':receipt['file_count'],'lua_count':receipt['lua_count']}
comparison['runtime_reduction_percent']=round(100*(1-package['runtime_bytes']/previous['runtime_bytes']),2)
comparison['note']='Task source increased; DLL count and runtime size compare complete published packages. No real game speedup was measured.'
save(f'resident-package-comparison-{VERSION}.json',comparison)

sdk=read(ROOT/'.tools/build/client/gameplay-snippet-test.json')
login=read(ROOT/f'artifacts/native-ui-{VERSION}/login-tests.json')
assistant=read(ROOT/f'artifacts/reference-tlzz/verification-{VERSION}.json')
reference=read(ROOT/f'artifacts/reference-mtx/verification-{VERSION}.json')
assert sdk['status']==assistant['status']==reference['status']==login['status']=='pass'
receipt={'status':'code_and_package_verified_live_test_pending','version':VERSION,
    'launcher':str(STAGE/'TLBB.exe'),'launcher_sha256':release['sha256'],'engine_sha256':release['engine_sha256'],
    'installer':installer,'package':package,'comparison':comparison,
    'checks':{'core':release['core_test_count'],'login':len(login['checks']),'game_sdk':sdk['checks'],'native_ui':release['native_ui_check_count']},
    'native_hotkey_input_verified_on_owned_fixtures':release['native_hotkeys_verified_on_owned_fixtures'],
    'resident_engine':manifest['resident_engine'],'gameplay_actions_sent':0,'real_game_tested':False,
    'long_duration_performance_tested':False,'installation_executed':False,'third_party_binary_executed':False,
    'private_data_included':False,'preserved_source':preserved,
    'remaining_live_checks':['resident game-thread scheduling','movement and NPC dialog','damage/cooldown/stop attack','full chess dungeon','long-running multi-session resource usage']}
save(f'delivery-{VERSION}.json',receipt)
lines=[f'# TLBBClient {VERSION} 软件包文件清单','',
    f'共 {package["file_count"]} 个文件，{package["lua_count"]} 份 Lua；二进制 DLL 9 个。程序文件合计 {package["runtime_bytes"]:,} 字节（不含清单自身）。',
    '','安装器默认 E:\\TLBBClient。完整 ZIP 解压后根目录为 TLBBClient。data/profiles、logs、cache、scripts/user 是空目录，运行时由用户产生，软件包不含已有账号或配置。',
    '','主程序 TLBB.exe；游戏内引擎 TLBBEngine.dll；其余 DLL 是 Qt 界面和编译运行库。当前 Lua 任务、公共层、模块、参考资料与元数据均随包提供。',
    '','| 文件 | 字节 |','| --- | ---: |']
for entry in manifest['files']:
    lines.append(f'| {entry["path"]} | {entry["bytes"]:,} |')
lines.extend(['| package-manifest.json | 见安装目录 |','',
    '每个文件的完整 SHA256 见软件目录 package-manifest.json。新脚本与模块下次任务加载；新增目录入口后重开面板/启动器。',
    '', '安装后另有 Inno 生成的 unins*.exe / unins*.dat 卸载文件；上述数量为发布文件数量。此安装器未在本轮执行安装。真实游戏与长期性能仍待验收，离线检查不代表已通关。'])
(ROOT/f'artifacts/软件包文件清单-{VERSION}.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(json.dumps({'status':receipt['status'],'checks':receipt['checks'],'comparison':comparison,'installer_bytes':installer['Bytes'],'source_backup_preserved':True},ensure_ascii=False))
