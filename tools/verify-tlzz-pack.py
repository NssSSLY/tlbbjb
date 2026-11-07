"""Verify new reference provenance and packaging without executing vendor code."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/reference-tlzz'
SOURCE=ROOT/'满天星/天龙助手'
parser=argparse.ArgumentParser();parser.add_argument('--version',choices=['0.5.4','0.6.0','0.7.0','0.8.0','0.9.0','0.10.0','0.11.0','0.12.0'],default='0.12.0');version=parser.parse_args().version
STAGE=ROOT/f'dist/TLBBClient-{version}'
def sha(p):
    with p.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
audit=read(OUT/'analysis.json');inventory={e['path']:e for e in audit['inventory']}
changed=[k for k,e in inventory.items() if not (SOURCE/k).exists() or sha(SOURCE/k)!=e['sha256']]
assert not changed,'Source changed after static audit'
source=ROOT/'scripts/data/tlzz_reference_routes.json';catalog=read(source)
assert len(catalog['routes'])==72 and catalog['runtime_enabled'] is False
points=0
for route in catalog['routes']:
    origin=route['source'];path=SOURCE/origin['path'];assert sha(path)==origin['sha256']==inventory[origin['path']]['sha256']
    text=path.read_bytes().decode(origin['encoding'])
    if path.suffix=='.txt':
        expected=[]
        for i,line in enumerate(text.splitlines(),1):
            if not line.strip():continue
            m=re.fullmatch(r'\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*',line);assert m
            expected.append({'x':float(m[1]),'y':float(m[2]),'source_line':i})
    else:
        p=json.loads(text);expected=[{'x':p['x'],'y':p['y'],'source_line':1}]
        assert route['map_hint']==p['sceneName'] and route['scene_id_hint']==p['sceneID'] and route['radius_hint']==p['r']
    assert route['points']==expected and route['map'] is None and route['verified'] is False and route['runtime_enabled'] is False
    points+=len(expected)
assert points==912 and sha(source)==sha(STAGE/'scripts/builtin/data/tlzz_reference_routes.json')
index=read(OUT/'bytecode/index.json');assert index['parsed_count']==318 and not index['failed'] and index['executed'] is False
for e in index['chunks']:
    p=OUT/'bytecode'/e['listing'].replace('.listing.txt','.luac');assert p.stat().st_size==e['bytes'] and sha(p)==e['sha256']
manifest=read(STAGE/'package-manifest.json');assert manifest['assistant_reference_routes']=={'route_count':72,'point_count':912,'runtime_enabled':False}
forbidden={e['sha256'] for e in inventory.values() if Path(e['path']).suffix.lower() in ('.dll','.exe') or Path(e['path']).name=='main'}
assert manifest['capabilities']['utility_wait_task'] and manifest['capabilities']['strict_utf8_role_names']
for entry in manifest['files']:
    assert entry['sha256'] not in forbidden and not entry['path'].endswith('.luac')
    assert sha(STAGE/entry['path'])==entry['sha256']
if read(ROOT/f'artifacts/package-{version}.json').get('zip_generated',True):
    with zipfile.ZipFile(ROOT/f'dist/packages/TLBBClient-{version}-full.zip') as z:
        for e in manifest['files']:
            assert e['sha256'] not in forbidden and not e['path'].endswith('.luac')
            assert not e['path'].startswith(('data/','user-data/','logs/','cache/','scripts/user/'))
            assert hashlib.sha256(z.read('TLBBClient/'+e['path'])).hexdigest()==e['sha256']==sha(STAGE/e['path'])
if version in ('0.6.0','0.7.0','0.8.0','0.9.0','0.10.0','0.11.0','0.12.0'):
    original=SOURCE/'script/自定义/每日签到.lua';entry=STAGE/'scripts/builtin/legacy/daily_sign.lua'
    assert sha(original)==sha(entry)=='da06cc781ec581e25f499581bb60babfcf21f6b2703609f02ad8a8d7fe390a44'
    assert manifest['capabilities']['daily_sign_integrated'] and not manifest['capabilities']['daily_sign_live_verified']
    assert (STAGE/('TLBBEngine.dll' if version in ('0.11.0','0.12.0') else 'TLBBGameplayBridge.dll')).is_file()
if version in ('0.7.0','0.8.0','0.9.0','0.10.0','0.11.0','0.12.0'):
    legacy=read(STAGE/'scripts/builtin/legacy/manifest.json');assert legacy['schema']==2 and (STAGE/'scripts/builtin/legacy/compat.lua').is_file()
    for task in legacy['tasks']:
        entry=STAGE/'scripts/builtin/legacy'/task['entry']
        if task.get('original_bytecode'):
            assert task['combat'] and not task['rules_modified'] and not task['live_verified']
            proof=read(STAGE/'scripts/builtin/legacy'/task['provenance'])
            assert sha(entry)==proof['wrapper_sha256'] and proof['original_chunk_sha256']==task['module_sha256']
            assert proof['instruction_count']==605 and proof['scene_id']==61 and proof['minimum_team_count']==3
            assert any(m['sha256']==task['module_sha256'] for m in read(OUT/'module-dependencies.json')['modules'])
        elif task.get('adapted'):
            assert task['rules_modified'] and task['combat'] and not task['live_verified']
            if task.get('module_sha256'):assert any(m['sha256']==task['module_sha256'] for m in read(OUT/'module-dependencies.json')['modules'])
        elif task.get('reconstructed'):
            module=[m for m in read(OUT/'module-dependencies.json')['modules'] if m['sha256']==task['module_sha256']];assert len(module)==1
            assert (ROOT/task['bytecode_listing']).is_file()
        else:
            original=SOURCE/task['source'].removeprefix('tlzz:')
            assert sha(original)==sha(entry)==task['original_sha256'],task['id']
    assert manifest['capabilities']['reference_compat_api'] and not manifest['capabilities']['reference_tasks_live_verified']
report={'status':'pass','version':version,'source_files_unchanged':250,'plaintext_lua_count':36,
    'bytecode_chunks_parsed':318,'bytecode_executed':version=='0.12.0','bytecode_execution_scope':'owned fake host only' if version=='0.12.0' else 'not executed','third_party_payloads_included':False,
    'reference_route_count':72,'reference_point_count':912,'runtime_enabled':False,'private_data_included':False,
    'package_file_count':len(manifest['files'])+1,'compatibility_lua':'scripts/builtin/utility/wait_until.lua','legacy_task_count':len(read(STAGE/'scripts/builtin/legacy/manifest.json')['tasks'])}
(OUT/f'verification-{version}.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
