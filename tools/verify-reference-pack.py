"""Verify imported reference data, source preservation, and release/package boundaries."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'artifacts/reference-mtx'
STAGE = ROOT/'dist/TLBBClient-0.5.3'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def verify(skip_package, version):
    global STAGE
    STAGE=ROOT/f'dist/TLBBClient-{version}'
    audit = read(OUT/'analysis.json')
    source = Path(audit['source_root']).resolve(strict=True)
    inventory = {entry['path']: entry for entry in audit['inventory']}
    current_names={p.relative_to(source).as_posix() for p in source.rglob('*') if p.is_file()}
    changed=[name for name,entry in inventory.items() if not (source/name).is_file() or sha(source/name)!=entry['sha256']]
    added=sorted(current_names-set(inventory))
    # The supplied old client can update its private logs/configs after the original audit.
    # Those are never imported. Keep their drift in the report; coordinates and payloads
    # must still match the original audit rather than silently regenerating provenance.
    def mutable_private(name):
        return name.startswith(('日志/','配置/')) or name=='数据/用户数据.mdb'
    assert all(mutable_private(name) for name in changed+added), 'Reference coordinates or payloads changed; review required'
    imported = ROOT/'scripts/data/reference_routes.json'
    data = read(imported)
    assert data['schema'] == 1 and data['runtime_enabled'] is False
    assert len(data['routes']) == audit['route_count'] == 38
    point_count = 0
    source_paths = set()
    for route in data['routes']:
        origin = route['source']
        assert origin['pack'] == 'mtxjb' and origin['path'] not in source_paths
        assert origin['path'].startswith('坐标/') and '..' not in origin['path']
        source_paths.add(origin['path'])
        assert origin['sha256'] == inventory[origin['path']]['sha256']
        assert route['map'] is None and route['purpose'] == 'unclassified'
        assert route['verified'] is False and route['runtime_enabled'] is False
        lines = (source/origin['path']).read_bytes().decode(origin['encoding']).splitlines()
        expected = []
        for index, line in enumerate(lines, 1):
            if not line.strip():
                continue
            match = re.fullmatch(r'\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*', line)
            assert match
            x, y = map(float, match.groups())
            expected.append({'x': x, 'y': y, 'source_line': index})
        assert route['points'] == expected, f"Order, line or coordinate changed: {origin['path']}"
        point_count += len(expected)
    assert point_count == audit['point_count'] == 1094
    assert sha(imported) == sha(STAGE/'scripts/builtin/data/reference_routes.json')
    release = read(ROOT/f'artifacts/release-verification-{version}.json')
    assert release['status'] == 'pass' and release['sha256'] == sha(STAGE/'TLBB.exe')
    expected_core,expected_ui={'0.4.3':(12,17),'0.5.0':(18,23),'0.5.2':(18,23),'0.5.3':(18,23),'0.5.4':(20,23),'0.6.0':(24,23),'0.7.0':(28,23),'0.8.0':(28,23),'0.9.0':(28,23),'0.10.0':(33,24),'0.11.0':(39,24),'0.12.0':(43,24)}[version]
    assert release['core_test_count'] == expected_core and release['native_ui_check_count'] == expected_ui
    native = read(ROOT/f'artifacts/native-ui-{version}/verification.json')
    assert native['passed'] and any('38 reference routes' in check for check in native['checks'])
    result = {'status': 'pass', 'version': version, 'route_count': len(data['routes']),
              'point_count': point_count, 'coordinates_order_and_lines_match': True,
              'source_all_files_unchanged': not changed and not added,
              'source_coordinate_files_unchanged': True, 'source_files_checked': len(inventory),
              'private_reference_files_changed': changed, 'private_reference_files_added': added,
              'private_reference_changes_imported': False,
              'third_party_payloads_executed': 0, 'account_database_parsed': False,
              'login_log_contents_parsed': False, 'private_file_handling': 'hash_only',
              'reference_routes_executable': False,
              'gameplay_actions_sent': 0, 'exe_sha256': release['sha256'],
              'dataset_sha256': sha(imported), 'package_checked': False,
              'identical_point_sequences': audit['identical_point_sequences']}
    if not skip_package:
        manifest = read(STAGE/'package-manifest.json')
        assert manifest['version'] == version
        assert manifest['reference_routes'] == {'route_count': 38, 'point_count': 1094, 'runtime_enabled': False}
        forbidden = {entry['sha256'] for entry in audit['inventory'] if Path(entry['path']).suffix.lower() in ('.exe','.dll')}
        archive = ROOT/f'dist/packages/TLBBClient-{version}-full.zip'
        package_receipt=read(ROOT/f'artifacts/package-{version}.json')
        has_zip=package_receipt.get('zip_generated',True)
        for entry in manifest['files']:
            relative=entry['path']
            assert not any(relative.startswith(prefix) for prefix in ('data/','logs/','cache/','scripts/user/','user-data/'))
            assert entry['sha256'] not in forbidden and sha(STAGE/relative)==entry['sha256']
        if has_zip:
            with zipfile.ZipFile(archive) as bundle:
                actual = {name for name in bundle.namelist() if not name.endswith('/')}
                expected = {'TLBBClient/'+entry['path'] for entry in manifest['files']} | {'TLBBClient/package-manifest.json'}
                assert actual == expected
                for entry in manifest['files']:
                    relative = entry['path']
                    assert not any(relative.startswith(prefix) for prefix in ('data/', 'logs/', 'cache/', 'scripts/user/', 'user-data/'))
                    assert entry['sha256'] not in forbidden
                    assert hashlib.sha256(bundle.read('TLBBClient/'+relative)).hexdigest() == entry['sha256']
                    assert sha(STAGE/relative) == entry['sha256']
                assert bundle.read('TLBBClient/scripts/builtin/data/reference_routes.json') == imported.read_bytes()
        installer = ROOT/f'dist/packages/TLBBClient-{version}-Setup.exe'
        installer_report = read(ROOT/f'artifacts/installer-build-{version}.json')
        assert installer_report['SHA256'].lower() == sha(installer)
        assert installer_report['ExecutableSHA256'].lower() == release['sha256']
        result.update(package_checked=True, package_file_count=len(manifest['files'])+1,
                      zip=str(archive) if has_zip else None, zip_sha256=sha(archive) if has_zip else None, installer=str(installer),
                      installer_sha256=sha(installer), private_data_included=False,
                      third_party_binaries_included=False, installation_tested=False)
        text = [f'# {version} 软件包文件清单', '',
                '仅包含程序、运行库、内置 Lua、参考坐标资料和说明。未执行安装器；安装器与 ZIP 使用相同发布目录。', '',
                '| 文件 | 字节数 | SHA256 |', '| --- | ---: | --- |']
        for entry in manifest['files']:
            text.append(f"| {entry['path']} | {entry['bytes']} | {entry['sha256']} |")
        text += ['', '安装后另有 Inno 生成的卸载文件；data/、scripts/user/、logs/、cache/ 初始为空，升级时保留用户数据。', '']
        (ROOT/f'artifacts/软件包文件清单-{version}.md').write_text('\n'.join(text),encoding='utf-8')
    (OUT/f'verification-{version}.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--skip-package',action='store_true')
    parser.add_argument('--version',choices=['0.4.3','0.5.0','0.5.2','0.5.3','0.5.4','0.6.0','0.7.0','0.8.0','0.9.0','0.10.0','0.11.0','0.12.0'],default='0.12.0')
    args=parser.parse_args()
    verify(args.skip_package,args.version)
