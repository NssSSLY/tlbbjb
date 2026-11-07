"""Complete the framework module lists of generic original tasks (and rewritten tasks' original alternatives).

The lists were first computed while every resident module counted as "provided by this program", so modules
whose functions only those (never loaded) modules defined were left out: 76 tasks failed loading common
(it LoadScripts json) and others reached nil CDG / SplitString / Array2Text. This recomputes each closure
with import-original-generic.py's corrected rule and stores the union with the existing list, never removing
a module. Idempotent; edits only the framework fields.
"""
from pathlib import Path
import collections, importlib.util, json, sys

ROOT = Path(__file__).resolve().parents[1]
# Entry scripts of the reference program (they end by running their own main loop): never task dependencies.
ENTRY_SCRIPTS = {'thhelp', 'thcheckteam', 'login'}
spec = importlib.util.spec_from_file_location('gen', Path(__file__).resolve().parent / 'import-original-generic.py')
gen = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gen)


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    lib = json.loads(gen.LIB.read_text(encoding='utf-8'))
    modules = lib['modules']
    by_name = {m['name']: m for m in modules}
    by_token = {m['token']: m for m in modules}
    info = {m['name']: gen.scan(p) + (p,) for m in modules if (p := gen.proto(m['token']))}
    defs = collections.defaultdict(set)
    for m in modules:
        if m['group'] == '系统' and m['name'] in info:
            for n in info[m['name']][1]:
                defs[n].add(m['name'])
    ours = gen.compat_defined()

    def closure(start):
        start = [n for n in start if n not in ENTRY_SCRIPTS]
        need, queue, seen = set(start), list(start), set()
        while queue:
            current = queue.pop()
            if current in seen or current not in info:
                continue
            seen.add(current)
            uses, own = info[current][0], info[current][1]
            for n in uses - own - gen.STD - ours:
                for f in defs.get(n, set()) - need - ENTRY_SCRIPTS:
                    need.add(f); queue.append(f)
            literal = [lm.removesuffix('.lua') for lm in by_name[current]['literal_modules']]
            # The index lists LoadScript targets only; CExec("json") in common.lua is a module name too.
            if uses & {'CExec', 'LoadScript'}:
                literal += [k.removesuffix('.lua') for k in info[current][2] if k.removesuffix('.lua') in by_name and by_name[k.removesuffix('.lua')]['group'] == '系统']
            for lm in literal:
                if lm in by_name and lm not in need and lm not in ENTRY_SCRIPTS:
                    need.add(lm); queue.append(lm)
        return need

    path = gen.LEGACY / 'manifest.json'
    manifest = json.loads(path.read_text(encoding='utf-8'))
    changed = []
    for task in manifest['tasks']:
        for record in (task, task.get('original_alternative')):
            if not record or 'framework' not in record:
                continue
            if record.get('original_token') not in by_token:  # plain-source custom script: close over its modules
                need = closure(record['framework'])
                kept = [m['name'] for m in modules if m['name'] in need and m['group'] == '系统'] + \
                       [m['name'] for m in modules if m['name'] in need and m['group'] != '系统']
                if kept != record['framework']:
                    record['framework'] = kept;changed.append((task['id'], 'custom closure'))
                continue
            if record is task and task.get('adapter') != 'original_generic_v1':
                continue
            own = by_token[record['original_token']]['name']
            need = closure([own] + record['framework']) - {own}
            # Framework (系统) modules first: a task module listed as a dependency runs top-level code that
            # needs them (一键交易 loads 交易给老板号, which calls common's HandleTextToNumber at load).
            merged = [m['name'] for m in modules if m['name'] in need and m['group'] == '系统'] + \
                     [m['name'] for m in modules if m['name'] in need and m['group'] != '系统']
            added = sorted(set(merged) - set(record['framework']))
            if merged != record['framework']:
                record['framework'] = merged
                changed.append((task['id'], added or 'reordered'))
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(len(changed), 'framework lists completed')
    for row in changed:
        print(' ', *row)


if __name__ == '__main__':
    main()
