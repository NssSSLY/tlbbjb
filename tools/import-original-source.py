"""Copy the decompiled original scripts into the program as scripts/original-source/.

Source: 原脚本源码/ (tools/decompile-original.py output), which is never modified.
Output: scripts/original-source/<same path>.lua plus index.json mapping each original-library token
to its file. The resident engine compiles these files instead of the extracted bytecode shards.

Standard Lua 5.4 rejects non-ASCII identifiers and the program's generic identifier renaming would
change table keys and global names, breaking lookups by real strings (scene names in graph.lua,
the Chinese API that fnE2C defines as _ENV["等待"], ...). The copies therefore spell every such
name as the string the original bytecode uses:
  t.苏州 -> t["苏州"]    {洛阳 = v} -> {["洛阳"] = v}    等待(1000) -> _ENV["等待"](1000)
and give the few Chinese local variables ASCII names (LOCALS below).

Every copy is then compiled with Lua 5.4.9 and compared function by function with the original
bytecode: tree shape, parameters, upvalue counts, constants, and a histogram of semantic opcodes.
Any mismatch stops the import.
"""
from pathlib import Path
import collections, hashlib, importlib.util, json, re, subprocess, sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / '原脚本源码'
OUT = ROOT / 'scripts/original-source'
LUA = ROOT / '.tools/build/environment-smoke/lua.exe'
TEMP = ROOT / '.tools/temp/original-source'
LIBRARY = ROOT / 'scripts/original-library/index.json'
BYTECODE = ROOT / 'artifacts/reference-tlzz/bytecode'

# The only Chinese locals/parameters in the original scripts.
LOCALS = {'摆摊坐标': 'bt_pos', '运行摆摊时先取一次物品': 'bt_get_item_first',
          '脚本名': 'script_name', '开始时间': 'start_time', '结束时间': 'end_time'}

# Decompiler errors found by the structural comparison, corrected from the original bytecode.
PATCHES = {
    # SDQY_HuoDong: unluac closed the scope of strAll before its uses, so they read a global.
    # Bytecode (functions.lua, f77): the event list is checked only when no option was clicked,
    # the 30 s timeout is checked on every pass.
    'Script64/系统/functions.lua': [(
        '''        local strAll, nNum = GetNPCEventListAllItem()
      end
      if not (not string.find(strAll, "#{SDQY_141031_", nil, true) or string.find(strAll, "#{SDQY_141031_04}", nil, true) or string.find(strAll, "#{SDQY_141031_15}", nil, true) or string.find(strAll, "#{SDQY_141031_22}", nil, true) or string.find(strAll, "#{SDQY_141031_05}", nil, true)) or GetTickCount() - nTick > 30000 then
        break
      end
''',
        '''        local strAll, nNum = GetNPCEventListAllItem()
        if string.find(strAll, "#{SDQY_141031_", nil, true) and not string.find(strAll, "#{SDQY_141031_04}", nil, true) and not string.find(strAll, "#{SDQY_141031_15}", nil, true) and not string.find(strAll, "#{SDQY_141031_22}", nil, true) and not string.find(strAll, "#{SDQY_141031_05}", nil, true) then
          break
        end
      end
      if GetTickCount() - nTick > 30000 then
        break
      end
''', 'SDQY_HuoDong 中 strAll 作用域被反编译提前结束，按字节码移回 if 内')],
}

spec = importlib.util.spec_from_file_location('undump', Path(__file__).resolve().parent / 'inspect-lua54-chunks.py')
undump = importlib.util.module_from_spec(spec)
spec.loader.exec_module(undump)

OPS2 = ('==', '~=', '<=', '>=', '..', '::', '//', '<<', '>>')


def lex(s):
    """Yield (kind, text, start, end); comments and whitespace are skipped but positions kept."""
    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if s.startswith('--', i):
            m = re.match(r'--\[(=*)\[', s[i:i + 64])
            if m:
                j = s.find(']' + m.group(1) + ']', i)
                j = n if j < 0 else j + len(m.group(1)) + 2
            else:
                j = s.find('\n', i)
                j = n if j < 0 else j
            i = j
            continue
        m = re.match(r'\[(=*)\[', s[i:i + 64])
        if m:
            j = s.find(']' + m.group(1) + ']', i)
            j = n if j < 0 else j + len(m.group(1)) + 2
            yield 'str', s[i:j], i, j
            i = j
            continue
        if c in '"\'':
            j = i + 1
            while j < n and s[j] != c and s[j] != '\n':
                j += 2 if s[j] == '\\' else 1
            yield 'str', s[i:j + 1], i, j + 1
            i = j + 1
            continue
        if c.isdigit():
            j = i
            while j < n and (s[j].isalnum() or s[j] in '._' or (s[j] in '+-' and s[j - 1] in 'eEpP')):
                j += 1
            yield 'num', s[i:j], i, j
            i = j
            continue
        if c.isalpha() or c == '_' or ord(c) > 127:
            j = i
            while j < n and (s[j].isalnum() or s[j] == '_' or ord(s[j]) > 127):
                j += 1
            yield 'name', s[i:j], i, j
            i = j
            continue
        if c.isspace():
            i += 1
            continue
        w = 3 if s.startswith('...', i) else 2 if s[i:i + 2] in OPS2 else 1
        yield 'op', s[i:i + w], i, i + w
        i += w


def fix(text):
    """Return (fixed text, list of fix descriptions)."""
    toks = list(lex(text))
    edits, notes, stack = [], collections.Counter(), []
    for k, (kind, v, a, b) in enumerate(toks):
        if kind == 'op' and v in '({[':
            stack.append(v)
        elif kind == 'op' and v in ')}]':
            stack.pop()
        if kind != 'name' or v.isascii():
            continue
        prev = toks[k - 1] if k else ('op', '', 0, 0)
        nxt = toks[k + 1] if k + 1 < len(toks) else ('op', '', 0, 0)
        if v in LOCALS:
            edits.append((a, b, LOCALS[v])); notes[f'局部变量 {v} → {LOCALS[v]}'] += 1
        elif prev[0] == 'op' and prev[1] == '.':
            edits.append((prev[2], b, f'["{v}"]')); notes[f'字段 .{v} → ["{v}"]'] += 1
        elif prev[0] == 'op' and prev[1] == ':':
            raise SystemExit(f'unsupported Chinese method call :{v}')
        elif nxt[:2] == ('op', '=') and stack and stack[-1] == '{' and prev[1] in ('{', ',', ';'):
            edits.append((a, b, f'["{v}"]')); notes[f'表键 {v} → ["{v}"]'] += 1
        elif prev[:2] in (('name', 'local'), ('name', 'function'), ('name', 'for')):
            raise SystemExit(f'unexpected Chinese declaration {v}; add it to LOCALS')
        else:
            edits.append((a, b, f'_ENV["{v}"]')); notes[f'全局名 {v} → _ENV["{v}"]'] += 1
    for a, b, new in reversed(edits):
        text = text[:a] + new + text[b:]
    return text, [f'{k}（{n} 处）' for k, n in notes.items()]


def drop_long_string_newline(text):
    count = 0
    for kind, v, a, b in reversed(list(lex(text))):
        if kind == 'str' and re.match(r'\[=*\[\n\n', v):
            cut = v.index('\n')
            text = text[:a + cut] + text[a + cut + 1:]
            count += 1
    return text, count


# Opcode families: register allocation and comparison direction may differ, semantics may not.
FAMILY = {}
for op in undump.OPS:
    if op in ('MOVE', 'LOADI', 'LOADF', 'LOADK', 'LOADKX', 'LOADFALSE', 'LFALSESKIP', 'LOADTRUE', 'LOADNIL', 'JMP',
              'TEST', 'TESTSET', 'MMBIN', 'MMBINI', 'MMBINK', 'EXTRAARG', 'VARARGPREP', 'CLOSE', 'NOT'):
        continue
    if op in ('EQ', 'LT', 'LE', 'EQK', 'EQI', 'LTI', 'LEI', 'GTI', 'GEI'):
        FAMILY[op] = 'CMP'
    elif op in ('RETURN', 'RETURN0', 'RETURN1'):
        FAMILY[op] = 'RETURN'
    elif op in ('CALL', 'TAILCALL'):
        FAMILY[op] = 'CALL'
    elif op in ('GETTABUP', 'GETTABLE', 'GETI', 'GETFIELD', 'SELF'):
        FAMILY[op] = 'GET'
    elif op in ('SETTABUP', 'SETTABLE', 'SETI', 'SETFIELD'):
        FAMILY[op] = 'SET'
    else:
        FAMILY[op] = re.sub(r'(I|K)$', '', op) if op not in ('SHRI', 'SHLI') else op[:3]


def fingerprint(p, path='main'):
    ops = collections.Counter(FAMILY[undump.OPS[w & 127]] for w in p['code'] if undump.OPS[w & 127] in FAMILY)
    ops.pop('RETURN', None)  # a trailing implicit return may be written out explicitly
    consts = collections.Counter(repr(c) for c in p['constants'] if c is not None and not isinstance(c, bool))
    out = [(path, p['params'], p['vararg'], len(p['upvalues']), len(p['children']), consts, ops)]
    for i, c in enumerate(p['children']):
        out += fingerprint(c, f'{path}.{i}')
    return out


def compare(original, compiled):
    a, b = fingerprint(original), fingerprint(compiled)
    if len(a) != len(b):
        return [f'function count {len(a)} vs {len(b)}']
    problems = []
    for x, y in zip(a, b):
        if x[1:5] != y[1:5]:
            problems.append(f'{x[0]}: signature {x[1:5]} vs {y[1:5]}')
        if x[5] != y[5]:
            problems.append(f'{x[0]}: constants -{dict(x[5] - y[5])} +{dict(y[5] - x[5])}')
        if x[6] != y[6]:
            problems.append(f'{x[0]}: ops -{dict(x[6] - y[6])} +{dict(y[6] - x[6])}')
    return problems


def compile_dump(text, name):
    """Compile text (GBK-encoded, like the original) with Lua 5.4.9 and return the stripped dump."""
    TEMP.mkdir(parents=True, exist_ok=True)
    src, dst = TEMP / 'in.lua', TEMP / 'out.luac'
    src.write_bytes(text.encode('gb18030'))
    dst.unlink(missing_ok=True)
    script = f"local f,e=loadfile([[{src}]],'t') if not f then io.stderr:write(e) os.exit(1) end " \
             f"local o=io.open([[{dst}]],'wb') o:write(string.dump(f,true)) o:close()"
    r = subprocess.run([str(LUA), '-e', script], capture_output=True)
    if r.returncode != 0:
        raise SystemExit(f'{name}: syntax error: ' + r.stderr.decode('gb18030', 'replace'))
    return dst.read_bytes()


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    library = json.loads(LIBRARY.read_text(encoding='utf-8'))
    if OUT.exists():
        for f in OUT.rglob('*'):
            if f.is_file():
                f.unlink()
    entries, fixed, failures = {}, {}, {}
    records = [(m, None) for m in library['modules']] + [(None, c) for c in library['custom_sources']]
    for module, custom in records:
        m = module or custom
        if module:
            raw = (BYTECODE / f"{m['token']}.luac").read_bytes()
            original = undump.Chunk(raw, 0).parse()
            parts = original['source'].lstrip('@').split('\\')
            relative = Path(*parts[parts.index('Script64'):])
        else:
            original = None
            relative = Path(m['source']).relative_to('满天星/天龙助手')
        text = (SRC / relative).read_text(encoding='utf-8')
        body, notes = fix(text)
        for old, new, why in PATCHES.get(relative.as_posix(), []):
            if body.count(old) != 1:
                raise SystemExit(f'{relative}: patch target not found: {why}')
            body = body.replace(old, new)
            notes.append(why)
        compiled = compile_dump(body, str(relative))
        if original is not None:
            problems = compare(original, undump.Chunk(compiled, 0).parse())
            if problems and '[[\n\n' in body:
                # unluac writes one newline too many after an opening long bracket when the
                # string itself does not start with one; Lua drops only the first.
                trial, count = drop_long_string_newline(body)
                if not compare(original, undump.Chunk(compile_dump(trial, str(relative)), 0).parse()):
                    body, problems = trial, []
                    notes.append(f'长字符串开头多出的换行（{count} 处，反编译器输出问题）')
            if problems:
                failures[str(relative)] = problems
        if notes:
            first, rest = body.split('\n', 1) if body.startswith('--') else ('', body)
            body = (first + '\n' if first else '') + '-- 程序内副本修正（只改写法，键名与原字节码一致）：' + '；'.join(notes) + '\n' + rest
            fixed[relative.as_posix()] = notes
        target = OUT / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        data = body.encode('utf-8')
        target.write_bytes(data)
        entries[m['token']] = {'name': m['name'], 'group': m['group'], 'path': relative.as_posix(),
                               'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data),
                               'kind': 'decompiled' if module else 'plain'}
    if failures:
        for k, v in failures.items():
            print(k, *v[:6], sep='\n  ')
        raise SystemExit(f'{len(failures)} files differ structurally from the original bytecode')
    index = {'schema': 1, 'kind': 'tlbb_original_source', 'origin': '原脚本源码 (tools/decompile-original.py)',
             'verification': 'Lua 5.4.9 compile + per-function structural comparison with the original bytecode',
             'modules': entries, 'fixed': fixed}
    (OUT / 'index.json').write_text(json.dumps(index, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
    print(len(entries), 'scripts;', len(fixed), 'with spelling fixes;', 'all structurally equal to the original bytecode')
    for k, v in fixed.items():
        print(' ', k, '：', '；'.join(v))


if __name__ == '__main__':
    main()
