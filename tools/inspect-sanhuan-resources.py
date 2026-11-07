"""Read bounded active game text blocks for the two three-stage dungeons."""
from pathlib import Path
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts' / 'sanhuan-2026-10-28' / 'resources'
TERMS = re.compile(r'剑荡三环|炎魔山|三才峡谷|何悦|钱宏宇|王阎|洪棘妖王|火焰妖魔|Sancai|3HUAN|Quest_Button_Continue|Quest_Button_Accept|LuaCancelRide|DispelBuffByIndex|GetMountID', re.I)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rows = []
    for archive in ('Interface.axp', 'Config.axp'):
        path = ROOT.parent / 'Data' / archive
        before = path.stat()
        with path.open('rb') as stream:
            header = stream.read(40)
            fields = struct.unpack('<10I', header)
            offset, count = fields[4:6]
            assert fields[0] == 0x4B505841 and count < 100000
            assert offset + count * 12 <= before.st_size
            stream.seek(offset)
            nodes = list(struct.iter_unpack('<3I', stream.read(count * 12)))
            budget = 256 * 1024 * 1024
            for index, (start, size, flags) in enumerate(nodes):
                if not flags & 0x80000000 or not 0 < size <= 2 * 1024 * 1024:
                    continue
                assert start >= 40 and start + size <= before.st_size
                stream.seek(start)
                prefix = stream.read(min(size, 256))
                if b'\0' in prefix or not any(marker in prefix for marker in
                        (b'--', b'function ', b'<?xml', b'<Window', b' = ', b'\t= ', b'\r\n')):
                    continue
                if size > budget:
                    break
                budget -= size
                stream.seek(start)
                data = stream.read(size)
                if b'\0' in data[:128]:
                    continue
                source = data.decode('gb18030', errors='replace')
                if not TERMS.search(source):
                    continue
                hits = []
                lines = source.splitlines()
                for number, line in enumerate(lines, 1):
                    if TERMS.search(line):
                        hits.append({'line': number, 'text': line[:1200]})
                target = f'{Path(archive).stem}-{index}.txt'
                (OUT / target).write_text(source, encoding='utf-8')
                rows.append({'archive': archive, 'block': index, 'offset': start,
                             'bytes': size, 'sha256': hashlib.sha256(data).hexdigest(),
                             'file': target, 'hits': hits[:150]})
        after = path.stat()
        assert (before.st_size, before.st_mtime_ns) == (after.st_size, after.st_mtime_ns)
    (OUT / 'index.json').write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding='utf-8')
    for row in rows:
        print(row['file'], row['bytes'], json.dumps(row['hits'][:3], ensure_ascii=False))


if __name__ == '__main__':
    main()
