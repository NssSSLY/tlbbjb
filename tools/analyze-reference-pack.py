"""Static local reference audit. Never load DLLs, run payloads, or read account/log values."""
from pathlib import Path, PurePosixPath
import argparse
import collections
import hashlib
import json
import re
import struct
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/reference-mtx'


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def decode(data):
    for encoding in ('utf-8-sig', 'gb18030', 'utf-16'):
        try:
            return data.decode(encoding), encoding
        except UnicodeError:
            pass
    raise ValueError('Unrecognized text encoding')


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def pe_summary(path):
    data = path.read_bytes()
    if data[:2] != b'MZ':
        return {'format': 'not_pe'}
    pe = struct.unpack_from('<I', data, 0x3c)[0]
    if data[pe:pe+4] != b'PE\0\0':
        return {'format': 'invalid_pe'}
    machine, count, timestamp = struct.unpack_from('<HHI', data, pe+4)
    optional = pe+24
    size = struct.unpack_from('<H', data, pe+20)[0]
    magic = struct.unpack_from('<H', data, optional)[0]
    dirs = optional + (112 if magic == 0x20b else 96)
    sections = []
    for i in range(min(count, 96)):
        at = optional+size+40*i
        virtual, rva, raw_size, raw = struct.unpack_from('<IIII', data, at+8)
        sections.append({'name': data[at:at+8].rstrip(b'\0').decode('ascii', errors='replace'),
                         'rva': rva, 'raw': raw, 'bytes': raw_size, 'virtual_bytes': virtual})

    def offset(rva):
        for section in sections:
            if section['rva'] <= rva < section['rva']+section['bytes']:
                at = section['raw']+rva-section['rva']
                if at >= len(data):
                    break
                return at
        raise ValueError('Unmapped RVA')

    def string(rva):
        at = offset(rva)
        end = data.find(b'\0', at, min(at+1024, len(data)))
        if end < 0:
            raise ValueError('Unbounded PE name')
        return data[at:end].decode('ascii', errors='replace')

    exports, imports = [], []
    try:
        export_rva = struct.unpack_from('<I', data, dirs)[0]
        if export_rva:
            at = offset(export_rva)
            names_count = struct.unpack_from('<I', data, at+24)[0]
            names = struct.unpack_from('<I', data, at+32)[0]
            for i in range(min(names_count, 4096)):
                exports.append(string(struct.unpack_from('<I', data, offset(names)+4*i)[0]))
        import_rva = struct.unpack_from('<I', data, dirs+8)[0]
        if import_rva:
            at = offset(import_rva)
            for i in range(256):
                original, _, _, name_rva, first = struct.unpack_from('<IIIII', data, at+20*i)
                if not any((original, name_rva, first)):
                    break
                width = 8 if magic == 0x20b else 4
                fmt = '<Q' if width == 8 else '<I'
                thunk = offset(original or first)
                functions = []
                for j in range(8192):
                    entry = struct.unpack_from(fmt, data, thunk+width*j)[0]
                    if not entry:
                        break
                    if not entry & (1 << (width*8-1)):
                        functions.append(string(entry+2))
                imports.append({'library': string(name_rva), 'functions': functions})
    except (ValueError, struct.error):
        pass  # Packed/import-less modules are still inventoried; no loader is used.
    return {'format': 'pe', 'architecture': {0x14c: 'x86', 0x8664: 'x64'}.get(machine, hex(machine)),
            'coff_timestamp': timestamp, 'sections': sections, 'exports': exports, 'imports': imports,
            'lua_bytecode_signatures': data.count(b'\x1bLua'),
            'lua_function_tokens': sorted({x.decode() for x in re.findall(rb'\blua[A-Za-z0-9_]{1,70}\b', data)})[:200]}


def archive_names(path):
    result = subprocess.run(['tar', '-tf', str(path)], capture_output=True, timeout=20, check=True)
    text, encoding = decode(result.stdout)
    names = [x.strip().replace('\\', '/') for x in text.splitlines() if x.strip()]
    if len(names) > 10000:
        raise ValueError('Archive entry limit')
    for name in names:
        p = PurePosixPath(name)
        if p.is_absolute() or '..' in p.parts or ':' in name:
            raise ValueError('Unsafe archive path')
    return names, encoding


def analyze(source):
    source = source.resolve(strict=True)
    files = sorted(p for p in source.rglob('*') if p.is_file())
    assert len(files) <= 5000 and sum(p.stat().st_size for p in files) <= 256*1024*1024
    assert not any(p.is_symlink() or getattr(p, 'is_junction', lambda: False)() for p in source.rglob('*'))
    baseline = {p.relative_to(source).as_posix(): sha(p) for p in files}
    inventory = [{'path': p.relative_to(source).as_posix(), 'bytes': p.stat().st_size,
                  'sha256': baseline[p.relative_to(source).as_posix()]} for p in files]
    binaries = [{'path': p.name, **pe_summary(p)} for p in files if p.suffix.lower() in ('.exe', '.dll')]
    config_schema = collections.Counter()
    for path in (source/'配置'/'普通').glob('*.xml'):
        assert path.stat().st_size < 1024*1024
        text, _ = decode(path.read_bytes())
        assert '<!DOCTYPE' not in text.upper() and '<!ENTITY' not in text.upper()
        tree = ET.fromstring(text)

        def walk(element, prefix=''):
            key = prefix+'/'+element.tag
            config_schema[key] += 1  # Only element names; never values or account identifiers.
            for child in element:
                walk(child, key)
        walk(tree)
    archives = []
    for path in source.glob('*.rar'):
        names, encoding = archive_names(path)
        entry = {'path': path.name, 'entries': names, 'listing_encoding': encoding}
        nested = [n for n in names if n.lower().endswith('.rar')]
        if len(nested) == 1 and path.stat().st_size <= 16*1024*1024:
            # Extract exactly one inert nested archive to project-local temp, never account files.
            result = subprocess.run(['tar', '-xOf', str(path), nested[0]], capture_output=True,
                                    timeout=20, check=True)
            assert len(result.stdout) <= 32*1024*1024
            temp_root = ROOT/'.tools/temp'
            temp_root.mkdir(parents=True, exist_ok=True)
            with tempfile.TemporaryDirectory(prefix='reference-static-', dir=temp_root) as directory:
                inner = Path(directory)/'reference.rar'
                inner.write_bytes(result.stdout)
                inner_names, inner_encoding = archive_names(inner)
                entry['nested'] = {'sha256': sha(inner), 'bytes': inner.stat().st_size,
                                   'entries': inner_names, 'listing_encoding': inner_encoding,
                                   'lua_sources': [n for n in inner_names if n.lower().endswith('.lua')]}
        archives.append(entry)
    routes = []
    for path in sorted((source/'坐标').glob('*.txt')):
        text, encoding = decode(path.read_bytes())
        points = []
        for number, line in enumerate(text.splitlines(), 1):
            if not line.strip():
                continue
            match = re.fullmatch(r'\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*', line)
            if not match:
                raise ValueError(f'Invalid coordinate: {path.name}:{number}')
            x, y = (float(v) for v in match.groups())
            assert 0 <= x <= 10000 and 0 <= y <= 10000
            points.append({'x': x, 'y': y, 'source_line': number})
        assert 1 <= len(points) <= 2048
        relative = path.relative_to(source).as_posix()
        routes.append({'id': 'mtx-'+hashlib.sha256(relative.encode()).hexdigest()[:16],
                       'name': path.stem, 'map': None, 'map_hint': '银皑雪原' if path.stem in ('雪原9矿', '雪原10矿') else path.stem,
                       'purpose': 'unclassified', 'verified': False, 'runtime_enabled': False,
                       'source': {'pack': 'mtxjb', 'path': relative, 'sha256': baseline[relative],
                                  'encoding': encoding}, 'points': points})
    route_data = {'schema': 1, 'id': 'mtx-reference-routes', 'runtime_enabled': False,
                  'routes': routes}
    sequences = collections.defaultdict(list)
    for route in routes:
        sequences[tuple((point['x'], point['y']) for point in route['points'])].append(route['name'])
    report = {'source_root': str(source), 'file_count': len(files), 'total_bytes': sum(p.stat().st_size for p in files),
              'extension_counts': dict(collections.Counter(p.suffix.lower() for p in files)),
              'scripts_directory_files': len(list((source/'脚本').rglob('*'))),
              'inventory': inventory, 'binaries': binaries, 'archives': archives,
              'configuration_schema': dict(config_schema), 'configuration_values_exported': False,
              'account_database_parsed': False, 'login_log_contents_parsed': False,
              'private_file_handling': 'hash_only', 'payloads_executed': 0,
              'route_count': len(routes), 'point_count': sum(len(r['points']) for r in routes),
              'identical_point_sequences': [names for names in sequences.values() if len(names) > 1],
              'source_unchanged': all(sha(source/name) == digest for name, digest in baseline.items())}
    assert report['source_unchanged']
    write(OUT/'analysis.json', report)
    write(ROOT/'scripts/data/reference_routes.json', route_data)
    print(json.dumps({key: report[key] for key in ['file_count','total_bytes','route_count','point_count',
                                                   'source_unchanged','payloads_executed']}, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT.parent/'mtxjb')
    analyze(parser.parse_args().source)
