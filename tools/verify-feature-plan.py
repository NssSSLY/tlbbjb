"""Audit the feature roadmap, preserved source rules and current offline evidence.

Does not run a game or third-party DLL and does not generate release packages.
Run after building and running CTest plus verify-development.py.
"""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import shutil
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/feature-plan-2026-10-26'
BUILD = ROOT / '.tools/build/client-0.15.0'
UI = ROOT / 'artifacts/universal-runtime-0.15.0/native-ui'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    spec = importlib.util.spec_from_file_location('feature_plan', ROOT / 'tools/update-feature-plan.py')
    generator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(generator)
    plan = read(ROOT / 'scripts/planning/feature-plan.json')
    catalog = read(ROOT / 'design/task-catalog.json')['tasks']
    before = read(OUT / 'before/design/task-catalog.json')['tasks']
    tasks = {t['id']: t for t in catalog}
    features = {f['id']: f for f in plan['features']}
    assert len(tasks) == len(catalog) == 241
    assert len(features) == len(plan['features']) == 88
    assert plan['requested_group_count'] == len(generator.REQUESTS) == 56
    assert plan['source_dungeon_count'] == 32
    assert plan['new_executable_tasks'] == 0 and not plan['source_executed']
    assert plan['priority_task_order'] == generator.PRIORITY_ORDER

    old_ids = {t['id'] for t in before}
    assert old_ids.issubset(tasks)
    preserved_runtime = []
    for old in before:
        if old.get('adapter_status') in ('integrated_pending_live', 'verified_luoyang_nearby', 'adapted'):
            current = tasks[old['id']]
            for key, value in old.items():
                if key == 'aliases':
                    assert set(value).issubset(current.get(key, []))
                else:
                    assert current.get(key) == value, (old['id'], key)
            assert not current.get('planning_only')
            preserved_runtime.append(old['id'])
    assert tasks['plant'] == next(t for t in before if t['id'] == 'plant')
    manifest_ids = {t['id'] for t in read(ROOT / 'scripts/legacy/manifest.json')['tasks']}
    for identity in generator.PRIORITY_ORDER:
        task = tasks[identity]
        assert task['planning_only'] and task['plan_priority'] == 'P0'
        assert identity not in manifest_ids
        assert task['planning_blockers']
        assert all(s['key'].startswith('plan_') and s['planning_only'] for s in task['settings'])
    for identity, feature in features.items():
        if not feature['runtime_enabled']:
            assert tasks[identity]['planning_only']
    enabled = [f['id'] for f in features.values() if f['runtime_enabled']]
    subsequent = plan.get('library_import', {})
    expected_enabled = {'zhenlong_combat'} | set(subsequent.get('contracts', {}))
    assert set(enabled) == expected_enabled

    source_index = read(ROOT / 'artifacts/reference-tlzz/bytecode/index.json')
    source_modules = {Path(m['listing']).stem.replace('.listing', ''): m for m in source_index['chunks']}
    assert plan['source_dll_sha256'] == source_index['source_sha256']
    assert len(plan['modules']) == 104
    staged = []
    for module in plan['modules']:
        token = module['token']
        source = ROOT / f'artifacts/reference-tlzz/bytecode/{token}.luac'
        assert sha(source) == module['source_sha256'] == source_modules[token]['sha256']
        actual, data = generator.audit_module(source_modules[token], 'resource' in module)
        assert actual == module, token
        if data is not None:
            path = ROOT / 'scripts/planning' / module['resource']
            assert path.read_bytes() == data
            assert sha(path) == module['resource_sha256']
            assert module['bytecode_proof']['numeric_and_control_flow_unchanged']
            staged.append(token)
        assert module['configuration_coverage'] == 'partial'
        assert module['indirect_configuration_keys_unknown']
        assert not module['original_rules_rewritten'] and not module['runtime_enabled']
    assert len(staged) == 11

    assets = read(UI / 'resource-index.json')
    assert assets['mounted'] and not assets['compressed'] and not assets['overrides']
    assert 216 <= len(assets['files']) <= 256
    for asset in assets['files']:
        relative = asset['path']
        source = ROOT / ('design/task-catalog.json' if relative == 'tasks/catalog.json'
                         else relative.replace('scripts/builtin/', 'scripts/', 1))
        assert source.is_file() and source.stat().st_size == asset['bytes']
        assert sha(source) == asset['sha256'], relative
    assert assets['bundle_sha256'] == sha(BUILD / 'TLBBData.rcc')
    for filename in ('TLBB.exe', 'TLBBEngine.dll', 'TLBBData.rcc'):
        assert sha(BUILD / filename) == sha(UI / 'owned-compact-runtime' / filename)

    tests = {}
    for name in ('self-test', 'battle-support-test', 'gameplay-snippet-test', 'login-test', 'login-api-test'):
        path = BUILD / (name + '.json')
        tests[name] = read(path)
        shutil.copy2(path, OUT / path.name)
    assert not tests['self-test']['failure']
    assert tests['battle-support-test']['passed'] and not tests['battle-support-test']['failures']
    assert tests['gameplay-snippet-test']['status'] == 'pass'
    assert tests['login-test']['status'] == 'pass' and tests['login-api-test']['status'] == 'pass'
    suites = ET.parse(OUT / 'ctest.xml').getroot()
    cases = suites.findall('.//testcase')
    assert len(cases) == 5 and not suites.findall('.//failure') and not suites.findall('.//error')
    ui = read(UI / 'verification.json')
    assert ui['passed'] and ui['remaining_sessions'] == 0 and ui['gameplay_actions_sent'] == 0
    assert not ui['real_game_tested'] and not ui['real_login_tested']
    for name in ('verification.json', 'resource-index.json', 'feature-plan.png', 'priority-parameters.png'):
        shutil.copy2(UI / name, OUT / ('ui-' + name))
    changed = []
    for source in sorted((OUT / 'before').rglob('*')):
        if source.is_file():
            relative = source.relative_to(OUT / 'before')
            current = ROOT / relative
            changed.append(dict(path=relative.as_posix(), before_sha256=sha(source), after_sha256=sha(current)))
    report = dict(
        status='pass', created_at=datetime.now(timezone.utc).isoformat(), development_version='0.15.0',
        requested_groups=56, source_dungeon_entries=32, planned_features=88,
        catalog_before=len(before), catalog_current=len(catalog), priority_tasks=generator.PRIORITY_ORDER,
        verified_source_modules=104, staged_original_modules=staged,
        direct_configuration_reads=sum(len(m['direct_config_reads']) for m in plan['modules']),
        configuration_coverage='partial; indirect and dynamic keys remain unknown',
        existing_adapter_metadata_preserved=preserved_runtime, existing_plant_preview_preserved=True,
        enabled_plan_entries=enabled, planning_batch_new_executable_tasks=0,
        subsequent_new_executable_tasks=subsequent.get('new_executable_tasks', 0),
        ctest_targets=len(cases), core_checks=len(tests['self-test']['passed']),
        battle_sdk_cases=len(tests['battle-support-test']['checks']),
        game_sdk_checks=tests['gameplay-snippet-test']['checks'],
        login_checks=len(tests['login-test']['checks']), native_ui_checks=len(ui['checks']),
        native_hotkeys_verified_on_owned_fixtures=ui['native_hotkey_input_verified_on_owned_fixtures'],
        bundled_assets_verified=len(assets['files']), bundle_bytes=assets['bundle_bytes'],
        source_executed=False, real_game_tested=False, installer_generated=False, zip_generated=False,
        changed_sources=changed,
        binaries=[dict(path=str(BUILD / name), bytes=(BUILD / name).stat().st_size,
                       sha256=sha(BUILD / name)) for name in ('TLBB.exe', 'TLBBEngine.dll', 'TLBBData.rcc')])
    (OUT / 'verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({key: value for key, value in report.items()
                      if key not in ('changed_sources', 'binaries', 'existing_adapter_metadata_preserved')}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
