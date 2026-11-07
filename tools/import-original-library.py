"""Build a compact, provenance checked library of all extracted original Lua.

Only string encoding changes. Importing a rule does not activate its game task.
The single supported new contract is explicitly registered below.
"""
from pathlib import Path
import importlib.util
import json
import argparse

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('feature_generator', ROOT / 'tools/update-feature-plan.py')
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)
rules = generator.rules
OUT = ROOT / 'artifacts/original-library-2026-10-27'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    source = json.loads((ROOT / 'artifacts/reference-tlzz/bytecode/index.json').read_text(encoding='utf-8'))
    records, shards, shard = [], [], bytearray()
    for meta in source['chunks']:
        audit, data = generator.audit_module(meta, True)
        token = audit['token']
        if len(shard) + len(data) > 1024 * 1024:
            shards.append(bytes(shard)); shard = bytearray()
        path = Path(meta['source'].replace('\\', '/'))
        records.append(dict(token=token, name=path.stem, group=path.parent.name, source=meta['source'],
            original_sha256=meta['sha256'], sha256=rules.sha(data), bytes=len(data),
            shard=f'rules-{len(shards):02d}.bin', offset=len(shard),
            instruction_sha256=audit['bytecode_proof']['original_instruction_sha256'],
            instructions=audit['bytecode_proof']['instruction_count'], rules_rewritten=False,
            numeric_and_control_flow_unchanged=True, globals=audit['global_dependencies'],
            literal_modules=audit['literal_module_loads'],
            direct_settings=[{k: v for k, v in field.items() if k != 'locations'} for field in audit['direct_config_reads']],
            configuration_coverage='partial',
            known_empty_stub=token == '002ac35d',
            runtime_contract='jinwen_inventory_v1' if token == '0043a061' else None))
        shard.extend(data)
    if shard: shards.append(bytes(shard))
    custom, custom_data, seen = [], bytearray(), {}
    base = ROOT / '满天星/天龙助手'
    for folder in [base / 'script', base / '更新包/script']:
        for path in sorted(folder.rglob('*.lua')):
            data = path.read_bytes(); digest = rules.sha(data)
            if digest in seen:
                seen[digest]['sources'].append(path.relative_to(ROOT).as_posix()); continue
            name = path.parent.name + '·' + path.stem
            record = dict(token=digest[:8], name=name, group=path.parent.name, source=path.relative_to(ROOT).as_posix(),
                sources=[path.relative_to(ROOT).as_posix()], original_sha256=digest, sha256=digest,
                bytes=len(data), shard='custom-sources.bin', offset=len(custom_data), format='source',
                rules_rewritten=False, numeric_and_control_flow_unchanged=True, literal_modules=[],
                direct_settings=[], configuration_coverage='not_analyzed', globals=[], runtime_contract=None)
            assert record['token'] not in {m['token'] for m in records + custom}
            custom.append(record); seen[digest] = record; custom_data.extend(data)
    assert len(custom_data) <= 1024 * 1024
    archive = dict(schema=1, source_sha256=source['source_sha256'], modules=records,
        custom_sources=custom,
        shards=[dict(file=f'rules-{n:02d}.bin', bytes=len(data), sha256=rules.sha(data)) for n, data in enumerate(shards)],
        rules_rewritten=False, automatically_enabled=False)
    assert len(records) == 318
    if args.write:
        directory = ROOT / 'scripts/original-library'; directory.mkdir(parents=True, exist_ok=True)
        for n, data in enumerate(shards): (directory / f'rules-{n:02d}.bin').write_bytes(data)
        (directory / 'custom-sources.bin').write_bytes(custom_data)
        (directory / 'index.json').write_text(json.dumps(archive, ensure_ascii=False, separators=(',', ':')) + '\n', encoding='utf-8')
        catalog_path = ROOT / 'design/task-catalog.json'; catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
        plan_path = ROOT / 'scripts/planning/feature-plan.json'; plan = json.loads(plan_path.read_text(encoding='utf-8'))
        manifest_path = ROOT / 'scripts/legacy/manifest.json'; manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        by_token = {m['token']: m for m in records}
        for task in catalog['tasks']:
            feature = next((f for f in plan['features'] if f['task_id'] == task['id']), None)
            if feature:
                task['original_library_tokens'] = feature['source_tokens']
                if task['id'] == 'pet_shop':
                    task['planning_blockers'] = ['提供的原 Lua 是空壳，仅打印执行完成；缺少实际抓宠与商会上架流程']
                    feature['blocked_by'] = task['planning_blockers']
        task = next(t for t in catalog['tasks'] if t['id'] == 'jinwen')
        task.update(family='legacy', planning_only=False, adapter_status='integrated_pending_live', requires_resident=True,
            original_token='0043a061', risks=['spend'], timeout_seconds=360,
            settings=[], source_scope='直接执行原 Lua；处理背包及锦囊现有金纹铜钱，保留原三次礼盒使用；逐次确认库存减少，无变化停止。')
        record = by_token['0043a061']
        declaration = dict(id='jinwen', name=task['name'], category=task['category'], entry='original/archive_entry.lua',
            adapter='original_archive_v1', original_token='0043a061', original_bytecode=True,
            rules_modified=False, reconstructed=False, requires_resident=True, runtime_enabled=True,
            original_chunk_sha256=record['original_sha256'], utf8_chunk_sha256=record['sha256'],
            validation_contract='jinwen_inventory_v1', timeout_seconds=360, live_verified=False)
        manifest['tasks'] = [t for t in manifest['tasks'] if t['id'] != 'jinwen'] + [declaration]
        feature = next(f for f in plan['features'] if f['id'] == 'jinwen')
        feature.update(status='integrated_pending_live', runtime_enabled=True, blocked_by=[], proposed_parameters=[])
        plan['library_import'] = dict(date='2026-10-27', modules=318, new_executable_tasks=1,
            contracts={'jinwen': 'jinwen_inventory_v1'}, real_game_tested=False)
        for path, document in [(catalog_path, catalog), (manifest_path, manifest), (plan_path, plan)]:
            path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    OUT.mkdir(parents=True, exist_ok=True)
    summary = dict(modules=len(records), custom_sources=len(custom), custom_source_occurrences=sum(len(m['sources']) for m in custom),
        shards=len(shards), bytes=sum(map(len, shards)), custom_source_bytes=len(custom_data),
        index_bytes=len(json.dumps(archive, ensure_ascii=False, separators=(',', ':')).encode('utf-8')),
        written=args.write, source_executed=False, new_executable_tasks=1 if args.write else 0,
        empty_stubs=[m['name'] for m in records if m['known_empty_stub']])
    (OUT / 'import.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(summary, ensure_ascii=False))


if __name__ == '__main__': main()
