"""Verify the direct-rule provenance and source/build tests; never builds packages."""
from pathlib import Path
import importlib.util,json,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('rules',ROOT/'tools/original-lua-rules.py')
rules=importlib.util.module_from_spec(spec);spec.loader.exec_module(rules)
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.file_digest(p.open('rb'),'sha256').hexdigest()
out=ROOT/'artifacts/original-combat-0.12.0'
reader,proto=rules.load('002b8890');converted=reader.transcode(proto);proof=read(ROOT/'scripts/legacy/original/qiju.provenance.json')
assert rules.check_transcode(reader,proto,converted)['original_instruction_sha256']==proof['original_instruction_sha256']
assert proof['numeric_and_control_flow_unchanged'] and proof['instruction_count']==605
assert proof['original_chunk_sha256']==rules.sha(reader.data)
assert proof['utf8_chunk_sha256']==rules.sha(converted) and proof['wrapper_sha256']==sha(ROOT/'scripts/legacy/original/qiju.lua')
# Derive the scene and team registers from actual closure captures, not nearby literals.
main=proto['children'][7];captures=dict(zip(main['upvalue_names'],main['upvalues']))
assert captures['m_fubenSceneID']==[1,3,0] and captures['m_teamCount']==[1,1,0]
initial={}
for word in proto['code']:
    opcode=rules.undump.OPS[word&127]
    if opcode=='CLOSURE':break
    if opcode=='LOADI':initial[(word>>7)&255]=((word>>15)&0x1ffff)-65535
assert initial[3]==61 and initial[1]==3
# Numeric tags are checked against a second, independent original rule's scene.
_,four=rules.load('002e1226');assert four['constants'][25]==291
assert all(isinstance(v,int) for v in [four['constants'][25],proto['children'][6]['constants'][1]])
inventory=read(out/'dungeon-config-inventory.json');assert inventory['count']==32
four_cfg=next(t for t in inventory['tasks'] if t['name']=='四绝庄')['configs']
assert any(c['section']=='四绝庄' and c['key']=='Boss2跑对角' for c in four_cfg)
catalog=read(ROOT/'design/task-catalog.json');task=next(t for t in catalog['tasks'] if t['id']=='zhenlong_combat')
assert task['original_bindings']=={'ZH/xzk190':'original_quick_mode'}
metadata=next(t for t in read(ROOT/'scripts/legacy/manifest.json')['tasks'] if t['id']=='zhenlong_combat')
assert metadata['original_bytecode'] and metadata['original_chunk_sha256']==proof['original_chunk_sha256']
assert metadata['module_sha256']==proof['original_chunk_sha256']
assert metadata['original_instruction_sha256']==proof['original_instruction_sha256']
helpers=read(out/'filter-provenance.json');assert len(helpers['functions'])==13
core=read(ROOT/'.tools/build/client-0.15.0/self-test.json');assert core['status']=='pass' and core['passed_count']>=43,core.get('failure')
assert all(any(name.startswith(prefix) for name in core['passed']) for prefix in ['original_qiju_bytecode','original_qiju_empty','original_qiju_entry','original_object_filters'])
report={'status':'pass','version':'0.15.0','core_checks':core['passed_count'],'dungeons_audited':32,'direct_original_dungeons':1,
    'original_helper_functions':13,'original_instructions':605,'scene_id':61,'minimum_team_count':3,
    'numeric_and_control_flow_unchanged':True,'original_rule_executed_on_fake_host':True,'real_game_tested':False,
    'installer_generated':(ROOT/'dist/packages/TLBBClient-0.15.0-Setup.exe').exists(),'zip_generated':(ROOT/'dist/packages/TLBBClient-0.15.0-full.zip').exists(),'lua_entry_sha256':proof['wrapper_sha256'],
    'built_exe_sha256':sha(ROOT/'.tools/build/client-0.15.0/TLBB.exe'),'built_engine_sha256':sha(ROOT/'.tools/build/client-0.15.0/TLBBEngine.dll')}
(ROOT/'artifacts/universal-runtime-0.15.0').mkdir(parents=True,exist_ok=True)
(ROOT/'artifacts/universal-runtime-0.15.0/original-rule-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
