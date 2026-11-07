"""Verify all preserved rules and current offline build/UI evidence. No packages."""
from pathlib import Path
from datetime import datetime, timezone
import importlib.util
import json
import hashlib
import shutil
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/original-library-2026-10-27'
BUILD=ROOT/'.tools/build/client-0.15.0'
UI=ROOT/'artifacts/universal-runtime-0.15.0/native-ui'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    spec=importlib.util.spec_from_file_location('rules',ROOT/'tools/original-lua-rules.py')
    rules=importlib.util.module_from_spec(spec);spec.loader.exec_module(rules)
    directory=ROOT/'scripts/original-library';index=read(directory/'index.json')
    assert len(index['modules'])==318 and len(index['custom_sources'])==36
    for module in index['modules']:
        original,proto=rules.load(module['token']);data=original.transcode(proto)
        proof=rules.check_transcode(original,proto,data)
        raw=(directory/module['shard']).read_bytes()[module['offset']:module['offset']+module['bytes']]
        assert data==raw and rules.sha(data)==module['sha256']
        assert rules.sha(original.data)==module['original_sha256']
        assert proof['original_instruction_sha256']==module['instruction_sha256']
        assert proof['numeric_and_control_flow_unchanged'] and not module['rules_rewritten']
    for module in index['custom_sources']:
        raw=(directory/module['shard']).read_bytes()[module['offset']:module['offset']+module['bytes']]
        assert rules.sha(raw)==module['sha256']==module['original_sha256']
        for path in module['sources']:assert (ROOT/path).read_bytes()==raw
    for shard in index['shards']:assert sha(directory/shard['file'])==shard['sha256']
    assert sum(len(m['sources']) for m in index['custom_sources'])==72
    assert next(m for m in index['modules'] if m['token']=='002ac35d')['known_empty_stub']
    manifest=read(ROOT/'scripts/legacy/manifest.json')['tasks']
    previous=read(OUT/'before/scripts/legacy/manifest.json')['tasks']
    assert len(manifest)==len(previous)+1 and len({t['id'] for t in manifest})==len(manifest)
    current_existing=[dict(t) for t in manifest if t['id']!='jinwen']
    for i,t in enumerate(current_existing):
        if t['id'] in ('tlzz_rose_claim','tlzz_flower_seed'):
            before=next(x for x in previous if x['id']==t['id'])
            assert all(t[k]==before[k] for k in ('id','name','category','source','module_sha256','timeout_seconds','live_verified'))
            assert t['original_bytecode'] and t['requires_resident'] and t['validation_contract']=='original_daily_v1'
            current_existing[i]=dict(before)
            continue
        if t['id']=='tlzz_keju':
            assert t.pop('supported_engines',None)==['外部兼容']
        if t['id'] in ('tlzz_sweep_yanzi','tlzz_sweep_sijue'):
            assert t.pop('requires_resident',None) is True
            assert t.pop('validation_contract',None)=='original_sweep_v1'
    assert current_existing==previous
    entry=next(t for t in manifest if t['id']=='jinwen')
    assert entry['original_bytecode'] and not entry['rules_modified'] and not entry['reconstructed']
    assert entry['validation_contract']=='jinwen_inventory_v1' and entry['original_token']=='0043a061'
    assert not any(t['id']=='pet_shop' for t in manifest)
    plan=read(ROOT/'scripts/planning/feature-plan.json')
    assert [f['id'] for f in plan['features'] if f['runtime_enabled']]==['jinwen','zhenlong_combat']
    catalog=read(ROOT/'design/task-catalog.json')['tasks'];by_id={t['id']:t for t in catalog}
    assert len(by_id)==len(catalog)==240 and 'luoyang_move' not in by_id
    for identity in plan['priority_task_order']:assert by_id[identity]['planning_only']
    assert by_id['jinwen']['family']=='legacy' and not by_id['jinwen']['planning_only']
    assert by_id['jinwen']['risks']==['spend'] and not by_id['jinwen']['settings']
    resources=read(UI/'resource-index.json');assert resources['mounted'] and not resources['compressed']
    assert len(resources['files'])==229 and resources['bundle_bytes']<8*1024*1024
    for asset in resources['files']:
        name=asset['path'];source=ROOT/('design/task-catalog.json' if name=='tasks/catalog.json' else name.replace('scripts/builtin/','scripts/',1))
        assert sha(source)==asset['sha256'] and source.stat().st_size==asset['bytes']
    for name in ['TLBB.exe','TLBBEngine.dll','TLBBData.rcc']:
        assert sha(BUILD/name)==sha(UI/'owned-compact-runtime'/name)
    cases=ET.parse(OUT/'ctest.xml').getroot();assert len(cases.findall('.//testcase'))==5 and not cases.findall('.//failure')
    tests={}
    for name in ['self-test','battle-support-test','gameplay-snippet-test','login-test','login-api-test']:
        tests[name]=read(BUILD/(name+'.json'));shutil.copy2(BUILD/(name+'.json'),OUT/(name+'.json'))
    assert tests['self-test']['status']=='pass' and not tests['self-test']['failure']
    assert tests['battle-support-test']['passed'] and not tests['battle-support-test']['failures']
    for name in ['gameplay-snippet-test','login-test','login-api-test']:assert tests[name]['status']=='pass'
    ui=read(UI/'verification.json');assert ui['passed'] and ui['remaining_sessions']==0 and not ui['real_game_tested'] and ui['gameplay_actions_sent']==0
    for name in ['verification.json','resource-index.json','original-library.png']:
        shutil.copy2(UI/name,OUT/('ui-'+name))
    changed=[]
    for old in sorted((OUT/'before').rglob('*')):
        if old.is_file():
            relative=old.relative_to(OUT/'before');changed.append(dict(path=relative.as_posix(),before_sha256=sha(old),after_sha256=sha(ROOT/relative)))
    report=dict(status='pass',created_at=datetime.now(timezone.utc).isoformat(),version='0.15.0',
        original_bytecode_modules=318,plain_source_files=36,plain_source_occurrences=72,
        numeric_and_control_flow_unchanged=True,new_executable_tasks=['jinwen'],empty_stubs=['pet_shop'],
        ctest_targets=5,core_checks=tests['self-test']['passed_count'],native_ui_checks=len(ui['checks']),
        game_sdk_checks=tests['gameplay-snippet-test']['checks'],battle_cases=len(tests['battle-support-test']['checks']),
        login_checks=len(tests['login-test']['checks']),bundled_assets=len(resources['files']),bundle_bytes=resources['bundle_bytes'],
        original_rule_executed_on_fake_host=True,real_game_tested=False,long_running_multi_game_tested=False,
        native_hotkeys_verified_on_owned_fixtures=ui['native_hotkey_input_verified_on_owned_fixtures'],
        third_party_dll_executed=False,installer_generated=False,zip_generated=False,
        changed_sources=changed,binaries=[dict(path=str(BUILD/name),bytes=(BUILD/name).stat().st_size,sha256=sha(BUILD/name)) for name in ['TLBB.exe','TLBBEngine.dll','TLBBData.rcc']])
    (OUT/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k not in ['changed_sources','binaries']},ensure_ascii=False,indent=2))

if __name__=='__main__':main()
