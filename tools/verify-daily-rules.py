"""Verify original daily-rule provenance and owned SDK cases; never package or play."""
from pathlib import Path
import hashlib,importlib.util,json,re

ROOT=Path(__file__).resolve().parents[1]
BUILD=ROOT/'.tools/build/client-0.15.0'
OUT=ROOT/'artifacts/npc-lua-compat-0.15.0'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.file_digest(p.open('rb'),'sha256').hexdigest()
spec=importlib.util.spec_from_file_location('rules',ROOT/'tools/original-lua-rules.py')
rules=importlib.util.module_from_spec(spec);spec.loader.exec_module(rules)
manifest=read(ROOT/'scripts/legacy/manifest.json')['tasks']
catalog={t['id']:t for t in read(ROOT/'design/task-catalog.json')['tasks']}
tokens={'tlzz_shitu_xinlianxin':('0042c956','shitu'),'tlzz_xingyun':('00429270','xingyun'),
        'tlzz_gulanyu':('003368ab','gulanyu'),'tlzz_rose_claim':('0042cd40','rose'),
        'tlzz_flower_seed':('0042d778','seed')}
proofs=[]
for task_id,(token,kind) in tokens.items():
    task=next(t for t in manifest if t['id']==task_id)
    reader,proto=rules.load(token);binary=reader.transcode(proto)
    expected=rules.check_transcode(reader,proto,binary)
    proof=read(ROOT/'scripts/legacy'/task['provenance'])
    entry=ROOT/'scripts/legacy'/task['entry']
    literal=re.findall(r'"((?:\\x[0-9a-fA-F]{2})+)"',entry.read_text(encoding='utf-8'))
    assert literal and b''.join(bytes.fromhex(part.replace('\\x','')) for part in literal)==binary
    assert proof['wrapper_sha256']==sha(entry)
    assert proof['original_chunk_sha256']==rules.sha(reader.data)==task['module_sha256']
    assert proof['utf8_chunk_sha256']==rules.sha(binary)==task['utf8_chunk_sha256']
    assert proof['original_instruction_sha256']==expected['original_instruction_sha256']==task['original_instruction_sha256']
    assert proof['numeric_and_control_flow_unchanged'] and not proof['rules_rewritten']
    assert task['original_bytecode'] and not task['reconstructed'] and not task['rules_modified']
    assert task['requires_resident'] and catalog[task_id]['requires_resident']
    assert task['validation_contract']==catalog[task_id]['validation_contract']=='original_daily_v1'
    proofs.append({'id':task_id,'instructions':proof['instruction_count'],'entry_sha256':sha(entry)})
reader,proto=rules.load('0049c027');functions=rules.bindings(proto)
shared=read(OUT/'shared-provenance.json')
module=ROOT/'scripts/legacy/modules/original_daily_functions.lua'
shared_source=['-- Original shared parsers; instruction trees are preserved.']
for proof in shared:
    expected=rules.check_transcode(reader,functions[proof['name']],reader.transcode(functions[proof['name']]))
    assert expected['original_instruction_sha256']==proof['original_instruction_sha256']
    shared_source.append('_G['+json.dumps(proof['name'])+']=assert(load('+rules.binary_literal(reader.transcode(functions[proof['name']]))+',"@original/'+proof['name']+'","b",_G))')
assert module.read_text(encoding='utf-8')=='\n'.join(shared_source)+'\n'
core=read(BUILD/'self-test.json')
assert core['status']=='pass' and 'original_daily_sdk_text_counts_limits_and_queue_progression' in core['passed']
assert 'task_lifecycle_requires_precheck_and_verified_terminal_receipt' in core['passed']
cases=read(OUT/'daily-task-cases.json')
assert cases['status']=='pass' and cases['case_count']>=20 and all(c['passed'] for c in cases['cases'])
for task_id in ('tlzz_shitu_xinlianxin','tlzz_xingyun','tlzz_gulanyu'):assert any(c['task']==task_id for c in cases['cases'])
snippets=read(BUILD/'gameplay-snippet-test.json');battle=read(BUILD/'battle-support-test.json')
report={'status':'pass','version':'0.15.0','original_tasks':proofs,'original_shared_functions':len(shared),
        'core_checks':core['passed_count'],'sdk_task_cases':cases['case_count'],
        'strict_daily_contracts':len(tokens),'sdk_tested_daily_contracts':3,'legacy_task_count':len(manifest),'other_task_contract_audit_complete':False,
        'numeric_and_control_flow_unchanged':True,'real_game_tested':False,
        'installer_generated':False,'zip_generated':False,
        'built_exe_sha256':sha(BUILD/'TLBB.exe'),'built_engine_sha256':sha(BUILD/'TLBBEngine.dll'),
        'bundle_sha256':sha(BUILD/'TLBBData.rcc'),'shared_original_functions_sha256':sha(module),
        'host_adapter_sha256':sha(ROOT/'scripts/legacy/modules/original_daily_host.lua'),
        'task_lifecycle_sha256':sha(ROOT/'scripts/legacy/task_lifecycle.lua'),
        'sdk_fixture':snippets,'battle_fixture':battle}
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['status','version','core_checks','sdk_task_cases','strict_daily_contracts','legacy_task_count','real_game_tested']},ensure_ascii=False))
