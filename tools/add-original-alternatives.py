"""Give each rewritten task (adapter tlzz_compat_v1) the option to run its original script instead.

For every rewritten task whose manifest `source` names an original script, the manifest entry gets
`original_alternative` (token, framework modules, risks, data files) and the catalog gets the
setting `run_original_source` plus the original script's own parameters that the task does not
already have. At run time the worker swaps in the generic original-source entry when the setting
is on (applyOriginalSourceChoice). Idempotent: previous alternatives and their settings are
replaced. Originals that fight, or that fall under the user's exclusions, get no alternative.
"""
from pathlib import Path
import collections, importlib.util, json, re, subprocess, sys

ROOT = Path(__file__).resolve().parents[1]
TOOLS = Path(__file__).resolve().parent
LUA = ROOT / '.tools/build/environment-smoke/lua.exe'
TEMP = ROOT / '.tools/temp/original-alternatives'
TAG = 'original_alternative'


def load(name, file):
    spec = importlib.util.spec_from_file_location(name, TOOLS / file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


gen = load('generic', 'import-original-generic.py')
undump = load('undump', 'inspect-lua54-chunks.py')


def compiled_proto(path):
    """Parse a plain-source original by compiling it; the analysis needs code and constants only."""
    TEMP.mkdir(parents=True, exist_ok=True)
    src, dst = TEMP / 'in.lua', TEMP / 'out.luac'
    src.write_bytes(path.read_text(encoding='utf-8').encode('gb18030'))
    script = f"local f=assert(loadfile([[{src}]],'t')) local o=io.open([[{dst}]],'wb') o:write(string.dump(f,true)) o:close()"
    subprocess.run([str(LUA), '-e', script], check=True, capture_output=True)
    return undump.Chunk(dst.read_bytes(), 0).parse()


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    library = json.loads(gen.LIB.read_text(encoding='utf-8'))
    sources = json.loads((ROOT / 'scripts/original-source/index.json').read_text(encoding='utf-8'))['modules']
    modules = library['modules']
    by_name = {m['name']: m for m in modules}
    info = {m['name']: gen.scan(p) + (p,) for m in modules if (p := gen.proto(m['token']))}
    framework_defs = collections.defaultdict(set)
    for m in modules:
        if m['group'] == '系统' and m['name'] in info:
            for n in info[m['name']][1]:
                framework_defs[n].add(m['name'])
    ours = gen.compat_defined()

    def closure(uses, defs, literal):
        need, seen = set(), set()
        for n in uses - defs - gen.STD - ours:
            need |= framework_defs.get(n, set())
        need |= set(literal)
        queue = list(need)
        while queue:
            current = queue.pop()
            if current in seen or current not in info:
                continue
            seen.add(current)
            u, d = info[current][0], info[current][1]
            for n in u - d - gen.STD - ours:
                for f in framework_defs.get(n, set()) - need:
                    need.add(f); queue.append(f)
            for lm in by_name[current]['literal_modules']:
                lm = lm.removesuffix('.lua')
                if lm in by_name and lm not in need:
                    need.add(lm); queue.append(lm)
        # Entry scripts (thhelp/thcheckteam/login) end in their own main loop; complete-original-frameworks.py
        # then completes and orders the lists.
        return [m['name'] for m in modules if m['name'] in need and m['name'] not in ('thhelp', 'thcheckteam', 'login')]

    locate = {}
    for m in modules:
        locate[f"dfz64.dll/{m['group']}/{m['name']}"] = (m, None)
    for c in library['custom_sources']:
        locate[f"script/{c['group']}/{c['name'].split('·', 1)[-1]}"] = (c, ROOT / 'scripts/original-source' / sources[c['token']]['path'])

    ini = gen.defaults()
    manifest_path, catalog_path = gen.LEGACY / 'manifest.json', ROOT / 'design/task-catalog.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
    ui = {t['id']: t for t in catalog['tasks']}
    added, skipped = [], []
    for task in manifest['tasks']:
        task.pop(TAG, None)
        if task['id'] in ui:
            ui[task['id']]['settings'] = [s for s in ui[task['id']].get('settings', []) if s.get('source') != TAG]
        if task.get('adapter') != 'tlzz_compat_v1':
            continue
        key = task.get('source', '').removeprefix('tlzz:').removesuffix('.lua')
        if key not in locate:
            skipped.append((task['id'], '没有对应原脚本')); continue
        m, plain = locate[key]
        name = m['name'].split('·', 1)[-1]
        if gen.EXCLUDE.search(name):
            skipped.append((task['id'], '属用户排除类')); continue
        text_path = ROOT / 'scripts/original-source' / sources[m['token']]['path']
        missing = sorted({n.removesuffix('.lua') for n in re.findall(r'LoadScript\(\s*"([^"]+)"', text_path.read_text(encoding='utf-8'))}
                         - set(by_name) - {c['name'].split('·', 1)[-1] for c in library['custom_sources']})
        if missing:
            skipped.append((task['id'], '原脚本载入的模块在原程序中不存在：' + '、'.join(missing))); continue
        if plain is None:
            uses, defs, strings, p = info[m['name']]
            literal = [lm.removesuffix('.lua') for lm in m['literal_modules'] if lm.removesuffix('.lua') in by_name]
        else:
            p = compiled_proto(plain)
            uses, defs, strings = gen.scan(p)
            # Plain scripts name the modules they LoadScript as string constants.
            literal = sorted({s.removesuffix('.lua') for s in strings if s.removesuffix('.lua') in by_name}) if 'LoadScript' in uses else []
        framework = closure(uses, defs, literal)
        text = ' '.join(strings) + ' ' + ' '.join(uses)
        # Framework modules pull in daguai/skill transitively; only the script's own calls decide.
        combat = bool(uses & gen.COMBAT)
        if combat:
            skipped.append((task['id'], '原脚本会战斗，改写版不战斗')); continue
        risks = [r for r, pattern in gen.RISKS.items() if pattern.search(text)]
        data_files = [f for f, (original, names) in gen.DATA_FILES.items() if f'{original}.lua' in strings or uses & names]
        alternative = {'original_token': m['token'], 'module_sha256': m['original_sha256'], 'framework': framework,
                       'risks': risks, 'combat': False, 'source': key}
        if data_files:
            alternative['data_files'] = data_files
        task[TAG] = alternative
        entry = ui.get(task['id'])
        if entry is None:
            skipped.append((task['id'], '界面目录没有此任务')); task.pop(TAG); continue
        present = {s['key'] for s in entry.get('settings', [])}
        risk_text = '、'.join(gen.RISK_TEXT[r] for r in risks)
        extra = [{'key': 'run_original_source', 'type': 'bool', 'default': False, 'source': TAG,
                  'label': '用原脚本源码执行（原程序同名脚本，完成条件未核验' + (f'；需打开{risk_text}' if risks else '') + '）'}]
        for k, (kind, label) in gen.settings_of(p).items():
            if k in present:
                continue
            title = k if not k.isascii() else (f'{label}（{k}）' if isinstance(label, str) and label and label != k else k)
            raw = ini.get(k)
            if kind == 'bool':
                setting = {'key': k, 'label': '原脚本：' + title, 'type': 'bool', 'default': raw == '1'}
            elif kind in ('number', 'select'):
                try:
                    value = int(float(raw)) if raw not in (None, '') else 0
                except ValueError:
                    value = 0
                setting = {'key': k, 'label': '原脚本：' + title + ('（选项序号，从 0 开始）' if kind == 'select' else ''),
                           'type': 'number', 'default': value, 'min': -1, 'max': 999999999}
            else:
                setting = {'key': k, 'label': '原脚本：' + title + ('（多项用空格分隔）' if kind == 'list' else ''), 'type': 'text', 'default': raw or ''}
            setting['source'] = TAG
            extra.append(setting)
        entry['settings'] = entry.get('settings', []) + extra
        added.append((task['id'], name, len(framework), risks, len(extra) - 1))
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(len(added), 'alternatives;', len(skipped), 'skipped')
    for row in skipped:
        print('  skip', *row)


if __name__ == '__main__':
    main()
