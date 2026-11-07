"""Import usable 天龙小蜜 text scripts from 新建文件夹/小蜜文本 as program tasks (adapter xiaomi_text_v1).

The source folder is never modified. Every unique script is classified:
- excluded: encrypted (cannot be reviewed), licence / time locked, deletion, 商会 / 上架 / 交易, shutdown, file or
  shell access, or calling something modules/xiaomi_api.lua does not implement (the reason is recorded);
- imported: the 小蜜 dialect keywords (计次循环 ... 执行 ... 结束) become plain Lua, the script is written to
  scripts/legacy/xiaomi/xm_<sha8>.lua with xiaomi_api loaded first, and it gets a manifest and catalog entry.
docs/XIAOMI_SCRIPT_MAP.md lists every script and its outcome. Idempotent: replaces only its own entries.
Usage: import-xiaomi-scripts.py [--report-only]
"""
from pathlib import Path
import collections, hashlib, importlib.util, json, re, subprocess, sys

ROOT = Path(__file__).resolve().parents[1]
_spec = importlib.util.spec_from_file_location('undump', Path(__file__).resolve().parent / 'inspect-lua54-chunks.py')
undump = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(undump)
SRC = ROOT / '新建文件夹/小蜜文本'
OUT = ROOT / 'scripts/legacy/xiaomi'
API = ROOT / 'scripts/legacy/modules/xiaomi_api.lua'
LUA = ROOT / '.tools/build/environment-smoke/lua.exe'
TEMP = ROOT / '.tools/temp/xiaomi'

LUA_STD = set('if elseif while for and or not return function print tonumber tostring type pairs ipairs next select assert error '
              'pcall xpcall setmetatable getmetatable rawget rawset rawequal unpack load loadstring collectgarbage until end repeat'.split())
# Reasons a script stays out, checked on the code with comments removed (strings kept).
RULES = [
    ('删除类（按要求不接入）', r'自动清包|DelBagItem|DelFriend|销毁|DiscardBag|Destroy|专业清包|物品清理|清包|CallFun\s*\(\s*5\s*,'),
    ('关机 / 重启 / 下线类', r'关机|重启电脑|ShutDown|QuitApplication|自动下线'),
    ('商会 / 鬼市上架 / 摆摊 / 抢购（按要求不接入）', r'商会|上架|摆摊|收购|抢购|钱庄'),
    ('交易给其他角色', r'交易|接收交易|WeiXin_TL7665'),
    ('含授权或时间锁，需原作者授权', r'时间已到|到期|联系QQ|联系qq|激活码|授权|卡密|机器码'),
    ('读写本机文件或执行系统命令', r'os\.execute|io\.open|io\.popen|dofile|ofile'),
    ('含授权或时间锁，需原作者授权', r'os\.time\s*\(\s*\)\s*[<>]=?\s*\d{9,}'),
    ('动态生成代码，无法审查', r'loadstring\s*\(|(?<![\w.])load\s*\('),
    ('批量操作其他玩家（加好友等）', r'AddFriend|加好友'),
]
KNOWN_MAPS = set(re.findall(r'\["([^"]+)"\]=\d+', re.search(r'local scenes=\{(.*?)\}', API.read_text(encoding='utf-8')).group(1)))
KNOWN_INFO = {3, 6, 7, 8, 11, 12, 16, 17, 26, 45, 46, 52, 57}
KNOWN_BUILTINS = {'同步游戏时间', '洛阳加血', '强制出副本', '修理装备'}  # builtins table in xiaomi_api
# Script globals that are read but never assigned, where nil is the documented "no filter / no exclusion".
NIL_OPTIONS = {'ID顾虑', '名称过滤', '模糊名称', '不存物品', '横扫乾坤技能ID'}
# Applied to the file name as well: an action named in the title must not slip in through helper calls.
NAME_RULES = [
    ('删除类（按要求不接入）', r'删|销毁|清理|清包|拆解|淬解'),
    ('关机 / 重启 / 下线类', r'关机|重启|下线'),
    ('商会 / 鬼市上架 / 摆摊 / 抢购（按要求不接入）', r'商会|上架|摆摊|收购|抢|比价'),
    ('批量操作其他玩家（加好友等）', r'加好友|好友'),
    ('不是脚本或内容为空', r'接口说明|使用说明|坐标数据|中转站|联系微信|^!+$'),
]
ENCRYPTED = re.compile(r'loadstring\(\(function|load\(\(function|key\s*=\s*"\d+"\s*local')


def read_text(path):
    raw = path.read_bytes()
    if raw.startswith(b'\x1bLua'):
        return None
    for enc in ('utf-8-sig', 'gb18030'):
        try:
            return raw.decode(enc).replace('\r\n', '\n')
        except UnicodeError:
            pass
    return None


def lex(s):
    """(kind, text, start, end) for code tokens; comments are skipped."""
    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if s.startswith('--', i):
            m = re.match(r'--\[(=*)\[', s[i:i + 40])
            if m:
                j = s.find(']' + m.group(1) + ']', i)
                i = n if j < 0 else j + len(m.group(1)) + 2
            else:
                j = s.find('\n', i)
                i = n if j < 0 else j
            continue
        m = re.match(r'\[(=*)\[', s[i:i + 40])
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
        if c.isalnum() or c == '_' or ord(c) > 127:
            j = i
            while j < n and (s[j].isalnum() or s[j] == '_' or ord(s[j]) > 127):
                j += 1
            yield 'name', s[i:j], i, j
            i = j
            continue
        if c.isspace():
            i += 1
            continue
        yield 'op', c, i, i + 1
        i += 1


KEYWORDS = {'如果': 'if', '则': 'then', '否则': 'else', '否则如果': 'elseif', '结束': 'end', '计次循环': 'for', '执行': 'do', '返回': 'return', '函数': 'function', '循环': 'while', '局部': 'local', '真': 'true', '假': 'false', '退出循环': 'break'}


def translate(text):
    """小蜜 dialect keywords to Lua, outside strings and comments only."""
    edits = [(a, b, KEYWORDS[v]) for kind, v, a, b in lex(text) if kind == 'name' and v in KEYWORDS]
    for a, b, new in reversed(edits):
        text = text[:a] + new + text[b:]
    return text


def code_of(text):
    """Text with comments removed and strings kept, for the exclusion rules."""
    out, last = [], 0
    for kind, v, a, b in lex(text):
        out.append(v)
    return ' '.join(out)


def calls_of(text):
    toks = [t for t in lex(text)]
    own, used = set(), set()
    for k, (kind, v, a, b) in enumerate(toks):
        if kind != 'name':
            continue
        prev = toks[k - 1][1] if k else ''
        nxt = toks[k + 1][1] if k + 1 < len(toks) else ''
        if prev == 'function':
            own.add(v)
        elif nxt == '=' and k + 2 < len(toks) and toks[k + 2][1] == 'function':
            own.add(v)
        elif nxt == '(' and prev not in ('.', ':') and not v[0].isdigit():
            used.add(v)
    return used - own - LUA_STD


def supported():
    """Global names defined by modules/xiaomi_api.lua and the payload core (compat.lua, resident.lua)."""
    names = set()
    for f in (API, ROOT / 'scripts/legacy/compat.lua', ROOT / 'scripts/legacy/resident.lua'):
        text = f.read_text(encoding='utf-8')
        names |= set(re.findall(r'^function ([^\s(.:]+)\s*\(', text, re.M)) | set(re.findall(r'^([^\s=.:(\-,]+)\s*=', text, re.M))
    return (names - {n for n in names if n.startswith('__')}) | {'Sleep', 'GetLuaValue', 'GetTickCount'}  # last three: VM natives


def attribute_problem(text):
    """获取人物属性 yields name and school only: names bound to later results must stay unused, school must be text."""
    problem = []
    for line in re.findall(r'^[^\n]*=\s*获取人物属性\s*\(\s*\)', text, re.M):
        fields = [f.strip() for f in line.split('=')[0].replace('local', '').split(',')]
        problem += [f for f in fields[2:] if f and len(re.findall(r'(?<![\w\u4e00-\u9fff])' + re.escape(f) + r'(?![\w\u4e00-\u9fff])', re.sub(r'^[^\n]*获取人物属性[^\n]*$', '', text, flags=re.M)))]
        if len(fields) > 1 and re.search(re.escape(fields[1]) + r'\s*[=~]=\s*\d', text):
            problem.append(fields[1] + ' 按数字比较')
    return '、'.join(sorted(set(problem))[:4])


def object_problem(text):
    """遍历周围物品: only mode 1 is confirmed, and 类别 / 归属 / 怪物判断 / 头顶标注 must stay unused."""
    problem = sorted(set(re.findall(r'遍历周围物品\s*\(\s*([^,)\s]+)', text)) - {'1'})
    if problem:
        return '模式 ' + '、'.join(problem[:3])
    lines = re.findall(r'^[^\n]*=\s*遍历周围物品\s*\(', text, re.M)
    rest = re.sub(r'^[^\n]*遍历周围物品[^\n]*$', '', text, flags=re.M)
    used = set()
    for line in lines:
        fields = [f.strip() for f in line.split('=')[0].replace('local', '').split(',')]
        used |= {f for f in fields[6:] if f and re.search(r'(?<![\w])' + re.escape(f) + r'(?![\w])', rest)}
    return '字段 ' + '、'.join(sorted(used)[:4]) if used else ''


# 小蜜 returns 1 / 0 from these, so a bare truth test would always pass; say what the author meant.
_ONE_ZERO = r'窗口是否出现|窗口是否存在|对话NPC|对对话NPC|组队_是否组队'


def normalize(text):
    """`if 窗口是否出现(x) then` becomes `if 窗口是否出现(x)==1 then`, `not f(x)` becomes `f(x)~=1`."""
    pattern = r'(?<![\w])(if|elseif|while|and|or)(\s+)(not\s+)?(' + _ONE_ZERO + r')\s*\(([^()]*)\)(?!\s*(?:==|~=))'
    return re.sub(pattern, lambda m: f"{m[1]}{m[2]}{m[4]}({m[5]}){'~=1' if m[3] else '==1'}", text)


def mangle_for_check(text):
    """Stand-in for LegacyRunner::translateSource: non-ASCII identifiers become ASCII for a syntax check."""
    edits = []
    for kind, v, a, b in lex(text):
        if kind == 'name' and not v.isascii():
            edits.append((a, b, '_' + hashlib.md5(v.encode()).hexdigest()[:12]))
    for a, b, new in reversed(edits):
        text = text[:a] + new + text[b:]
    return text


STD = set('assert collectgarbage error getmetatable ipairs next pairs pcall print rawequal rawget rawlen rawset select setmetatable '
          'tonumber tostring type xpcall _G _VERSION string table math os coroutine utf8 _ENV'.split())
TABLES = ('Player', 'Bag', 'Pet', 'Target', 'Team', 'Skill', 'Raid')


def globals_of(text):
    """Exact global reads and writes from the compiled script; None when it does not compile."""
    names = {}
    edits = []
    for kind, v, a, b in lex(text):
        if kind == 'name' and not v.isascii():
            m = '_' + hashlib.md5(v.encode()).hexdigest()[:12]
            names[m] = v
            edits.append((a, b, m))
    code = text
    for a, b, new in reversed(edits):
        code = code[:a] + new + code[b:]
    TEMP.mkdir(parents=True, exist_ok=True)
    src, dst = TEMP / 'dump.lua', TEMP / 'dump.luac'
    src.write_bytes(code.encode('utf-8'))
    r = subprocess.run([str(LUA), '-e', f"local f=loadfile([[{src}]]) if not f then os.exit(1) end local o=io.open([[{dst}]],'wb') o:write(string.dump(f)) o:close()"], capture_output=True)
    if r.returncode:
        return None
    reads, writes = set(), set()
    def walk(p):
        K = p['constants']
        for w in p['code']:
            op = undump.OPS[w & 127]
            if op == 'GETTABUP' and (w >> 24) & 255 < len(K) and isinstance(K[(w >> 24) & 255], str):
                reads.add(K[(w >> 24) & 255])
            elif op == 'SETTABUP' and (w >> 16) & 255 < len(K) and isinstance(K[(w >> 16) & 255], str):
                writes.add(K[(w >> 16) & 255])
        for c in p['children']:
            walk(c)
    walk(undump.Chunk(dst.read_bytes(), 0).parse())
    return {names.get(n, n) for n in reads}, {names.get(n, n) for n in writes}


def methods_of():
    """Player:Foo / Bag.Foo this program defines."""
    out = set()
    for f in (API, ROOT / 'scripts/legacy/compat.lua', ROOT / 'scripts/legacy/resident.lua'):
        text = f.read_text(encoding='utf-8')
        out |= {a + '.' + b for a, b in re.findall(r'^\s*function (\w+)[.:](\w+)\s*\(', text, re.M)}
        out |= {a + '.' + b for a, b in re.findall(r'^\s*(\w+)\.(\w+)\s*=', text, re.M)}
    return out


def method_gaps(text, known):
    """Calls on this program's Player/Bag/... tables, outside game-Lua strings, that nothing defines."""
    toks = list(lex(text))
    out = set()
    for k in range(len(toks) - 3):
        if toks[k][0] == 'name' and toks[k][1] in TABLES and toks[k + 1][1] in ('.', ':') and toks[k + 2][0] == 'name' and toks[k + 3][1] == '(':
            name = toks[k][1] + '.' + toks[k + 2][1]
            if name not in known:
                out.add(name)
    return out


def syntax_error(text):
    TEMP.mkdir(parents=True, exist_ok=True)
    path = TEMP / 'check.lua'
    path.write_bytes(mangle_for_check(text).encode('utf-8'))
    r = subprocess.run([str(LUA), '-e', f"local f,e=loadfile([[{path}]]) if not f then io.stderr:write(e) os.exit(1) end"], capture_output=True)
    return r.stderr.decode('utf-8', 'replace').split('check.lua')[-1][:120] if r.returncode else None


CATEGORY = [('副本', r'副本|BOSS|boss|四绝|燕子|缥缈|王陵|三神|福地|地宫|宋辽'), ('活动', r'活动|嘉年华|飒踏|领奖|风云录'), ('养成', r'养成|洗|升级|精通|王权|神器|龙纹|暗器|令牌|武魂|真元|雕纹|打造|宝鉴|子女|经脉|侠印|上宝石|强化|神鼎|秘籍|无字谱'), ('任务', r'任务|主线|练级|起号|1-|师门')]
# Direct game calls (LUA_Call, GetLuaValue, lua) cannot be classified one by one, so they count as possible spending.
RISKS = {'spend': r'元宝|金币|交子|购买|买入|修理|洛阳加血|LuoYangRestore|BulkBuy|BuyItem|NpcShop|花费|LUA_Call|LUA调用|GetLuaValue|(?<![\w.])lua\s*\(','sell': r'出售|卖出|BagSell|SellItem', 'transfer': r'Exchange|邮寄', 'offline': r'小退|大退|ExitGame',
         'item': r'右键使用物品|使用物品|UseItem|取出物品|存物品|Bank_|穿装备|脱装备'}
RISK_TEXT = {'spend': '允许支付', 'sell': '允许出售', 'transfer': '允许交易', 'offline': '允许下线', 'item': '允许物品处理'}


def stem_of(path):
    name = re.sub(r'\.(lua|txt)$', '', path.name, flags=re.I).strip()
    name = re.sub(r'(\s*[\(（]\d+[\)）])+\s*$', '', name)                 # "(1)" copies
    name = re.sub(r'^(\[参\]?|[0-9]+|[A-Za-z](?=[\u4e00-\u9fff])|!+)', '', name)  # ordering prefixes
    return name.strip() or path.stem


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    report_only = '--report-only' in sys.argv
    ours = supported() | {'Player', 'Bag'}
    known_methods = methods_of()
    existing = {}
    for t in json.loads((ROOT / 'design/task-catalog.json').read_text(encoding='utf-8'))['tasks']:
        if not t.get('xiaomi_text') and not t.get('planning_only'):
            existing[t['name']] = t['id']
    uniq = collections.OrderedDict()
    unreadable = []
    for p in sorted(SRC.rglob('*')):
        if not p.is_file() or p.suffix.lower() not in ('.lua', '.txt'):
            continue
        text = read_text(p)
        if text is None:
            unreadable.append(p)
            continue
        h = hashlib.sha256(text.encode('utf-8')).hexdigest()
        uniq.setdefault(h, {'text': text, 'paths': []})['paths'].append(p)
    rows, blocked = [], collections.Counter()
    for h, item in uniq.items():
        text, path = item['text'], item['paths'][0]
        rel = path.relative_to(SRC).as_posix()
        reason, detail = None, ''
        if ENCRYPTED.search(text):
            reason = '加密脚本，无法审查'
        elif not calls_of(translate(text)):
            reason = '不是脚本或内容为空'
        else:
            if re.search(r'^\[参|未完成|测试', path.name):
                reason, detail = '作者标注为参考 / 未完成 / 测试', path.name
            for why, pattern in NAME_RULES:
                m = None if reason else re.search(pattern, stem_of(path))
                if m:
                    reason, detail = why, '文件名：' + m.group(0)
                    break
            code = code_of(text)
            for why, pattern in RULES:
                if reason:
                    break
                m = re.search(pattern, code)
                if m:
                    reason, detail = why, m.group(0)
            if not reason and stem_of(path) in existing:
                reason, detail = '程序已有同名任务', existing[stem_of(path)]
            if not reason and re.search(r'LoadScript\s*\(|CExec\s*\(', code):
                reason, detail = '依赖未随脚本提供的模块', ' '.join(re.findall(r'(?:LoadScript|CExec)\s*\(\s*\S+', code)[:2])
        translated = None
        if reason is None:
            translated = normalize(translate(text))
            found = globals_of(translated)
            used = (found[0] - found[1] - STD - NIL_OPTIONS) if found else calls_of(translated)
            missing = sorted((used - ours) | method_gaps(translated, known_methods))
            builtins = re.findall(r'执行功能\s*\(\s*([^)]*?)\s*\)', code_of(translated))
            unknown = sorted({b.strip('"\' ') for b in builtins} - KNOWN_BUILTINS)
            if unknown and not missing:
                reason, detail = '执行功能尚未接入', '、'.join(unknown[:6])
                blocked.update('执行功能:' + u for u in unknown)
            if missing:
                reason, detail = '调用了尚未接入的接口', '、'.join(missing[:6])
                blocked.update(missing)
            elif not reason:
                # Literal arguments the API would refuse at run time.
                maps = set(re.findall(r'跨图寻路\s*\(\s*"([^"]+)"', translated)) - KNOWN_MAPS
                codes = {int(n) for n in re.findall(r'获取人物信息\s*\(\s*(\d+)\s*\)', translated)} - KNOWN_INFO
                attribute = attribute_problem(translated)
                objects = object_problem(translated)
                if objects:
                    reason, detail = '周围对象用法未核对', objects
                elif attribute:
                    reason, detail = '使用了读不到的人物属性', attribute
                elif maps:
                    reason, detail = '地图尚未核对场景编号', '、'.join(sorted(maps)[:5])
                elif codes:
                    reason, detail = '获取人物信息编号含义未核对', '、'.join(str(n) for n in sorted(codes))
        if reason is None:
            err = syntax_error(translated)
            if err:
                reason, detail = '语法错误', err
        rows.append({'hash': h, 'rel': rel, 'copies': len(item['paths']), 'reason': reason, 'detail': detail, 'text': translated, 'stem': stem_of(path)})
    # One task per name: the largest version; smaller same-name versions are recorded.
    best = {}
    for r in rows:
        if r['reason'] is None:
            cur = best.get(r['stem'])
            if cur is None or len(r['text']) > len(cur['text']):
                best[r['stem']] = r
    for r in rows:
        if r['reason'] is None and best[r['stem']] is not r:
            r['reason'], r['detail'] = '同名的较小版本', best[r['stem']]['rel']
    counts = collections.Counter(r['reason'] or '已接入' for r in rows)
    print('unique', len(rows), 'unreadable', len(unreadable))
    for k, n in counts.most_common():
        print(n, k)
    print('top missing:', ' '.join(f'{k}:{n}' for k, n in blocked.most_common(60)))
    if report_only:
        return
    write_outputs(rows, unreadable)


def write_outputs(rows, unreadable):
    OUT.mkdir(parents=True, exist_ok=True)
    for f in OUT.glob('*.lua'):
        f.unlink()
    manifest_path, catalog_path = ROOT / 'scripts/legacy/manifest.json', ROOT / 'design/task-catalog.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
    manifest['tasks'] = [t for t in manifest['tasks'] if t.get('adapter') != 'xiaomi_text_v1']
    catalog['tasks'] = [t for t in catalog['tasks'] if not t.get('xiaomi_text')]
    for r in rows:
        if r['reason'] is not None:
            continue
        identity = 'xm_' + r['hash'][:8]
        entry = f'xiaomi/{identity}.lua'
        text = r['text']
        risks = [k for k, pattern in RISKS.items() if re.search(pattern, text)]
        header = f"-- 来自 新建文件夹/小蜜文本/{r['rel']}（小蜜文本，方言关键字已转为 Lua）\nLoadScript(\"xiaomi_api\") XiaomiRequire({json.dumps(risks)[1:-1].join('{}')})\n"
        (OUT / f'{identity}.lua').write_text(header + text, encoding='utf-8')
        category = next((c for c, pattern in CATEGORY if re.search(pattern, r['stem'])), '工具')
        scope = f"小蜜文本：执行原脚本 {r['rel']}；小蜜接口由本程序实现；完成条件未单独核验，结束后按“失败处理”继续下一项"
        if risks:
            scope += '；含' + '、'.join(RISK_TEXT[k].removeprefix('允许') for k in risks) + '类操作，需要打开' + '、'.join(f'“{RISK_TEXT[k]}”' for k in risks)
        name = r['stem']
        manifest['tasks'].append({'id': identity, 'name': name, 'category': category, 'entry': entry, 'source': f"xiaomi:{r['rel']}",
                                  'module_sha256': r['hash'], 'adapter': 'xiaomi_text_v1', 'requires_resident': True, 'rules_modified': False,
                                  'reconstructed': False, 'timeout_seconds': 1800, 'live_verified': False, 'risks': risks, 'combat': False})
        catalog['tasks'].append({'id': identity, 'name': name, 'aliases': ['小蜜文本'], 'category': category, 'family': 'legacy', 'xiaomi_text': True, 'adapter_status': 'integrated_pending_live',
                                 'source_refs': [f"xiaomi:{r['rel']}"], 'source_scope': scope, 'timeout_seconds': 1800, 'requires_resident': True, 'risks': risks, 'settings': []})
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    counts = collections.Counter(r['reason'] or '已接入' for r in rows)
    lines = ['# 小蜜文本对接表', '', '由 `python tools/import-xiaomi-scripts.py` 生成。来源 `新建文件夹/小蜜文本`，原目录未改；目录中的 exe、压缩包未运行、未解压。', '',
             f'共 {len(rows)} 个不同脚本（重复副本已合并）。', '', '| 结果 | 数量 |', '|---|---|']
    lines += [f'| {k} | {v} |' for k, v in counts.most_common()]
    lines += ['', '## 明细', '', '| 脚本 | 结果 | 说明 |', '|---|---|---|']
    for r in sorted(rows, key=lambda x: (x['reason'] is not None, x['reason'] or '', x['rel'])):
        lines.append(f"| `{r['rel']}` | {r['reason'] or '已接入 `xm_' + r['hash'][:8] + '`'} | {str(r['detail']).replace('|', '/')} |")
    (ROOT / 'docs/XIAOMI_SCRIPT_MAP.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
