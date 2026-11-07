"""Preserve the two daily claim tasks' original instructions and attach receipts."""
from pathlib import Path
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('rules', ROOT / 'tools/original-lua-rules.py')
rules = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rules)
TASKS = {
    'tlzz_rose_claim': ('0042cd40', 'rose'),
    'tlzz_flower_seed': ('0042d778', 'seed'),
}
manifest_path = ROOT / 'scripts/legacy/manifest.json'
catalog_path = ROOT / 'design/task-catalog.json'
manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
for identity, (token, kind) in TASKS.items():
    record = next(t for t in manifest['tasks'] if t['id'] == identity)
    ui = next(t for t in catalog['tasks'] if t['id'] == identity)
    reader, proto = rules.load(token)
    binary = reader.transcode(proto)
    proof = rules.check_transcode(reader, proto, binary)
    assert rules.sha(reader.data) == record['module_sha256']
    entry = f'original/daily/{kind}.lua'
    path = ROOT / 'scripts/legacy' / entry
    path.write_text('-- Original task control flow; host checks are in original_daily_host.lua.\n'
                    'LoadScript("original_daily_functions")\nLoadScript("original_daily_host")\n'
                    f'RunOriginalDaily("{kind}",function()\n'
                    '  local original=assert(load(' + rules.binary_literal(binary) + ',"@original/' + kind + '","b",_G))\n'
                    '  return original()\nend)\n', encoding='utf-8')
    proof.update(source=proto['source'], original_chunk_sha256=rules.sha(reader.data),
                 wrapper_sha256=rules.sha(path.read_bytes()), entry=entry, rules_rewritten=False, game_executed=False)
    proof_path = path.with_suffix('.provenance.json')
    proof_path.write_text(json.dumps(proof, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    record.update(entry=entry, original_bytecode=True, reconstructed=False, rules_modified=False,
                  host_api_adapted=True, requires_resident=True, validation_contract='original_daily_v1',
                  adapter='original_daily_v1', original_chunk_sha256=proof['original_chunk_sha256'],
                  utf8_chunk_sha256=proof['utf8_chunk_sha256'], original_instruction_sha256=proof['original_instruction_sha256'],
                  instruction_count=proof['instruction_count'], provenance=proof_path.relative_to(ROOT/'scripts/legacy').as_posix(),
                  differences='保留原规则；识别完成对话，状态不明不重复提交；满包停止')
    ui.update(requires_resident=True, validation_contract='original_daily_v1',
              source_scope='保留原 Lua 规则；读取完成对话并报告状态，领取无反馈停止不重复；背包满时提示整理。')
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('已接入原始规则与对话完成回执：领取波斯玫瑰、领取鲜花种子')
