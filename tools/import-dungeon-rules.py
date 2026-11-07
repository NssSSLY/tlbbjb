"""Import all supplied dungeon chunks as inactive resources; never execute them."""
from pathlib import Path
import argparse, hashlib, importlib.util, json

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('original_rules', ROOT/'tools/original-lua-rules.py')
rules = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rules)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    catalog = ROOT/'scripts/dungeons/catalog.json'
    document = json.loads(catalog.read_text(encoding='utf-8'))
    assert len(document['entries']) == 32
    total = 0
    for entry in document['entries']:
        reader, proto = rules.load(entry['source_token'])
        assert hashlib.sha256(reader.data).hexdigest() == entry['source_sha256']
        converted = reader.transcode(proto)
        proof = rules.check_transcode(reader, proto, converted)
        relative = f"original/{entry['source_token']}.luac"
        entry.update(resource=relative, resource_sha256=hashlib.sha256(converted).hexdigest(),
                     resource_bytes=len(converted), rules_rewritten=False,
                     bytecode_proof=proof)
        if args.write:
            path = catalog.parent/relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(converted)
        total += len(converted)
    if args.write:
        catalog.write_text(json.dumps(document, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({'modules':32,'bytes':total,'written':args.write,
        'source_executed':False,'new_tasks_enabled':0},ensure_ascii=False))

if __name__ == '__main__':
    main()
