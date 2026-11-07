"""Preserve the supplied daily rules; only transcode their GBK strings to UTF-8."""
from pathlib import Path
import hashlib, importlib.util, json
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('rules',ROOT/'tools/original-lua-rules.py')
rules=importlib.util.module_from_spec(spec);spec.loader.exec_module(rules)
TASKS={'tlzz_shitu_xinlianxin':('0042c956','shitu'),'tlzz_xingyun':('00429270','xingyun'),
       'tlzz_gulanyu':('003368ab','gulanyu')}
def main():
    manifest_path=ROOT/'scripts/legacy/manifest.json'
    manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
    for task in manifest['tasks']:
        if task['id'] not in TASKS:continue
        token,kind=TASKS[task['id']];reader,p=rules.load(token);binary=reader.transcode(p)
        proof=rules.check_transcode(reader,p,binary)
        entry=f'original/daily/{kind}.lua';path=ROOT/'scripts/legacy'/entry;path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text('-- Original task control flow; host checks are in original_daily_host.lua.\n'
            'LoadScript("original_daily_functions")\nLoadScript("original_daily_host")\n'
            f'RunOriginalDaily("{kind}",function()\n'
            '  local original=assert(load('+rules.binary_literal(binary)+',"@original/'+kind+'","b",_G))\n'
            '  return original()\nend)\n',encoding='utf-8')
        proof.update(source=p['source'],original_chunk_sha256=rules.sha(reader.data),
            wrapper_sha256=rules.sha(path.read_bytes()),entry=entry,rules_rewritten=False,game_executed=False)
        proof_path=path.with_suffix('.provenance.json');proof_path.write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        task.update(entry=entry,original_bytecode=True,reconstructed=False,rules_modified=False,host_api_adapted=True,
            requires_resident=True,validation_contract='original_daily_v1',adapter='original_daily_v1',
            original_chunk_sha256=proof['original_chunk_sha256'],utf8_chunk_sha256=proof['utf8_chunk_sha256'],
            original_instruction_sha256=proof['original_instruction_sha256'],instruction_count=proof['instruction_count'],
            provenance=proof_path.relative_to(ROOT/'scripts/legacy').as_posix(),
            differences='原任务指令未改；宿主增加前置状态、数量 / 上限核对、兑换回执等待与失败停止')
    manifest_path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    reader,p=rules.load('0049c027');functions=rules.bindings(p);source=['-- Original shared parsers; instruction trees are preserved.'];proofs=[]
    for name in ['SplitString','Text2Table','FindTableFieldValue']:
        f=functions[name];assert f['upvalue_names'] in ([],['_ENV']);binary=reader.transcode(f)
        proof=rules.check_transcode(reader,f,binary);proof['name']=name;proofs.append(proof)
        source.append('_G['+json.dumps(name)+']=assert(load('+rules.binary_literal(binary)+',"@original/'+name+'","b",_G))')
    (ROOT/'scripts/legacy/modules/original_daily_functions.lua').write_text('\n'.join(source)+'\n',encoding='utf-8')
    out=ROOT/'artifacts/npc-lua-compat-0.15.0';out.mkdir(parents=True,exist_ok=True)
    (out/'shared-provenance.json').write_text(json.dumps(proofs,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'direct_original_tasks':list(TASKS),'original_shared_functions':len(proofs),'game_executed':False},ensure_ascii=False))
if __name__=='__main__':main()
