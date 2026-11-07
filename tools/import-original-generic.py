"""Register remaining original tasks for generic execution (adapter original_generic_v1).

Each task runs its original bytecode unchanged in the resident game Lua. The original framework
modules it needs are listed per task; settings come from the task's own ReadConfig*/GetConfig*
calls, labelled with the field name the script stores them under, defaults from Default.ini.
Excluded: the other line's explicit P0 priority tasks (strict adapters), stubs, shop rushing /
商会 / deletion / dismantling / shutdown, and modules that already have a task.

Do not rerun over the current manifest/catalog: generic entries were hand-tuned afterwards
(settings, combat, framework lists), and newer resident modules shadow framework names so the
closure comes out smaller. Edit individual entries instead, or append new ones with
`--add id,id`, which leaves every existing entry untouched.
"""
from pathlib import Path
import collections, configparser, json, re, sys

ROOT = Path(__file__).resolve().parents[1]
LEGACY = ROOT / 'scripts/legacy'
LIB = ROOT / 'scripts/original-library/index.json'
PROTO = ROOT / 'artifacts/reference-tlzz/bytecode'
INI = ROOT / '满天星/天龙助手/data/Default.ini'
OPS = ('MOVE LOADI LOADF LOADK LOADKX LOADFALSE LFALSESKIP LOADTRUE LOADNIL GETUPVAL SETUPVAL GETTABUP GETTABLE GETI GETFIELD '
       'SETTABUP SETTABLE SETI SETFIELD NEWTABLE SELF ADDI ADDK SUBK MULK MODK POWK DIVK IDIVK BANDK BORK BXORK SHRI SHLI ADD SUB MUL '
       'MOD POW DIV IDIV BAND BOR BXOR SHL SHR MMBIN MMBINI MMBINK UNM BNOT NOT LEN CONCAT CLOSE TBC JMP EQ LT LE EQK EQI LTI LEI GTI '
       'GEI TEST TESTSET CALL TAILCALL RETURN RETURN0 RETURN1 FORLOOP FORPREP TFORPREP TFORCALL TFORLOOP SETLIST CLOSURE VARARG '
       'VARARGPREP EXTRAARG').split()
STD = set('assert collectgarbage dofile error getmetatable ipairs load loadfile next pairs pcall print rawequal rawget rawlen rawset '
          'require select setmetatable tonumber tostring type xpcall _G _VERSION string table math os io coroutine utf8 debug package _ENV'.split())
EXCLUDE = re.compile(r'关机|删|销毁|拆解|淬解|抢购|商会|金币元宝互换|九州零点抢店|^抢(?!箱子)|^合成宝石$|^一键日常$')
READERS = {'ReadConfigInt': 'number', 'ReadConfigBool': 'bool', 'ReadConfigText': 'text', 'GetConfigInt': 'number',
           'GetConfigBool': 'bool', 'GetConfigCommbox': 'select', 'GetConfigList': 'list', 'GetConfigListCtrlEx': 'list',
           'GetItemConfigText': 'text'}
COMBAT = {'Skill', 'skilllib', 'JinGongFarSkill', 'FubenRunSafe', 'FubenTrapRun', 'TargetAttack', 'EnumAttackObj', 'FastSkill',
          'WuDiSkill', 'StopAttack', 'CUseSkillByID', 'DieRelive', 'FuBenCheckDie'}
RISKS = {'spend': re.compile(r'Buy|购买|兑换|合成|修理|升级|点金|雕琢|雇佣'),
         'sell': re.compile(r'Sell|出售|卖出|卖给'),
         'transfer': re.compile(r'Exchange|交易|摆摊|寄售|PlayerShop|收购|Stall')}
CATEGORY = {'任务': '日常', '日常': '日常', '活动': '限时', '帮庄': '生活', '功能': '生活', '物品': '生活', '其他': '工具', '常用': '野外', '副本': '副本'}
RISK_TEXT = {'spend': '允许支付', 'sell': '允许出售', 'transfer': '允许交易'}


# Original script/数据 coordinate files, shipped UTF-8 under scripts/legacy/data/.
# A task needs one when it names the file (GetUserScriptPath) or reads its globals.
DATA_FILES = {
    'mazei_pos': ('坐标刷马', {'g_MaZeiPos'}),
    'tianjiang_pos': ('坐标天降奇兽', set()),
    'baitan_pos': ('坐标摆摊', {'g_BtPos', 'g_BtStartGetItem'}),
    'jiuli_pos': ('坐标清剿九黎余孽', set()),
}


def proto(token):
    path = PROTO / f'{token}.json'
    return json.loads(path.read_text(encoding='utf-8')) if path.exists() else None


def walk(p, fn):
    fn(p)
    for c in p['children']:
        walk(c, fn)


def scan(p):
    uses, defs, strings = set(), set(), set()
    def one(f):
        K = f['constants']
        for k in K:
            if isinstance(k, str):
                strings.add(k)
        for w in f['code']:
            op = OPS[w & 127]
            if op in ('GETTABUP', 'SETTABUP'):
                key = (w >> 24) & 255 if op == 'GETTABUP' else (w >> 16) & 255
                if key < len(K) and isinstance(K[key], str):
                    (uses if op == 'GETTABUP' else defs).add(K[key])
    walk(p, one)
    return uses, defs, strings


def settings_of(p):
    found = collections.OrderedDict()
    def one(f):
        K, code, regs = f['constants'], f['code'], {}
        for i, w in enumerate(code):
            op = OPS[w & 127]; a = (w >> 7) & 255; c = (w >> 24) & 255; bx = (w >> 15) & 0x1ffff
            if op == 'GETTABUP' and c < len(K) and isinstance(K[c], str):
                regs[a] = ('g', K[c]); continue
            if op == 'LOADK' and bx < len(K):
                regs[a] = ('k', K[bx]); continue
            if op == 'CALL':
                r, sec, key = regs.get(a), regs.get(a + 1), regs.get(a + 2)
                if r and r[0] == 'g' and r[1] in READERS and key and key[0] == 'k' and isinstance(key[1], str):
                    label = None
                    for w2 in code[i + 1:i + 4]:
                        op2 = OPS[w2 & 127]; b2 = (w2 >> 16) & 255; c2 = (w2 >> 24) & 255; k2 = (w2 >> 15) & 1
                        if op2 in ('SETFIELD', 'SETTABUP') and not k2 and c2 == a and b2 < len(K) and isinstance(K[b2], str):
                            label = K[b2]; break
                    if key[1] not in found:
                        found[key[1]] = (READERS[r[1]], label)
            regs.pop(a, None)
    walk(p, one)
    return found


def defaults():
    parser = configparser.RawConfigParser(strict=False)
    parser.optionxform = str
    parser.read_string(INI.read_bytes().decode('gb18030'))
    out = {}
    for section in parser.sections():
        for k, v in parser.items(section):
            out[k] = v
    return out


def compat_defined():
    names = set('Sleep GetTickCount GetLuaValue host log'.split())
    # Only what a generic task actually has loaded: the payload core plus the generic host and the
    # modules it loads itself. Other resident modules (dungeon flows, ...) are not present and must
    # not hide original framework functions of the same name.
    files = [LEGACY / 'compat.lua', LEGACY / 'resident.lua', LEGACY / 'task_lifecycle.lua', LEGACY / 'combat.lua'] +         [LEGACY / 'modules' / f'{n}.lua' for n in ('original_generic_host', 'original_config', 'original_filters')]
    for f in files:
        s = f.read_text(encoding='utf-8', errors='ignore')
        names |= set(re.findall(r'^\s*function\s+([A-Za-z_]\w*)\s*\(', s, re.M))
        names |= set(re.findall(r'^\s*function\s+([A-Za-z_]\w*)[.:]', s, re.M))
        names |= set(re.findall(r'^([A-Za-z_]\w*)\s*=', s, re.M))
        names |= set(re.findall(r'_G\["([A-Za-z_]\w*)"\]', s))
    return names


def main():
    # --add id,id: append just these catalog tasks as generic entries and leave every existing entry alone.
    add = set(sys.argv[sys.argv.index('--add') + 1].split(',')) if '--add' in sys.argv else None
    lib = json.loads(LIB.read_text(encoding='utf-8'))
    modules = lib['modules']
    by_name = {m['name']: m for m in modules}
    info = {}
    for m in modules:
        p = proto(m['token'])
        if p:
            info[m['name']] = scan(p) + (p,)
    framework_defs = collections.defaultdict(set)
    for m in modules:
        if m['group'] == '系统' and m['name'] in info:
            for n in info[m['name']][1]:
                framework_defs[n].add(m['name'])
    ours = compat_defined()

    def closure(name):
        need, queue, seen = set(), [name], set()
        while queue:
            current = queue.pop()
            if current in seen or current not in info:
                continue
            seen.add(current)
            uses, defs = info[current][0], info[current][1]
            for n in uses - defs - STD - ours:
                need |= framework_defs.get(n, set())
            for lm in by_name[current]['literal_modules']:
                lm = lm.removesuffix('.lua')
                if lm in by_name:
                    need.add(lm); queue.append(lm)
        need.discard(name)
        order = [m['name'] for m in modules if m['name'] in need]
        return order

    ini = defaults()
    manifest_path, catalog_path = LEGACY / 'manifest.json', ROOT / 'design/task-catalog.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
    plan = json.loads((ROOT / 'scripts/planning/feature-plan.json').read_text(encoding='utf-8'))
    priority = set(plan.get('priority_task_order', []))
    if add is None:
        manifest['tasks'] = [t for t in manifest['tasks'] if t.get('adapter') != 'original_generic_v1']
    elif add & {t['id'] for t in manifest['tasks']}:
        raise SystemExit('already in the manifest: ' + ', '.join(sorted(add & {t['id'] for t in manifest['tasks']})))
    taken = set()
    for t in manifest['tasks']:
        taken.add(t.get('source', '').replace('\\', '/').split('/')[-1].removesuffix('.lua'))
    for t in catalog['tasks']:
        if t.get('planning_only') or t.get('generic_original'):
            continue
        for r in t.get('source_refs', []):
            taken.add(r.replace('\\', '/').split('/')[-1].removesuffix('.lua'))
    if add is None:
        catalog['tasks'] = [t for t in catalog['tasks'] if not (t.get('generic_original') and not t.get('planned_origin'))]
    planned = {}
    for t in catalog['tasks']:
        if t.get('planning_only') or t.get('planned_origin'):
            for token in t.get('original_library_tokens', [])[:1]:
                planned[token] = t

    added = []
    for m in modules:
        name, group, token = m['name'], m['group'], m['token']
        if group in ('系统', '数据') or m.get('known_empty_stub') or EXCLUDE.search(name) or name not in info:
            continue
        existing = planned.get(token)
        if add is not None:
            if existing is None or existing['id'] not in add:
                continue
        elif existing is None and name in taken:
            continue
        if add is None and existing is not None and (existing['id'] in priority or EXCLUDE.search(existing['name'])):
            continue
        uses, defs, strings, p = info[name]
        framework = closure(name)
        # The two Sashen variants call CDG methods which resolve Skill through
        # a module upvalue; static global dependency discovery misses this edge.
        if token in {'002bb430', '002fd257'} and 'skill' not in framework:
            framework.append('skill')
        text = ' '.join(strings) + ' ' + ' '.join(uses)
        data_files = [file for file, (original, names) in DATA_FILES.items()
                      if f'{original}.lua' in strings or uses & names]
        risks = [r for r, pattern in RISKS.items() if pattern.search(text)]
        combat = bool(uses & COMBAT) or bool({'daguai', 'skill'} & set(framework))
        timeout = 3600 if combat or group == '副本' else 1800
        settings = []
        for key, (kind, label) in settings_of(p).items():
            if re.search(r'[^\x00-\x7f]', key):
                title = key  # GetConfig* names are already the original page's wording
            else:
                title = label if isinstance(label, str) and label and label != key else key
                title = f'{title}（{key}）' if title != key else key
            raw = ini.get(key)
            if kind == 'bool':
                settings.append({'key': key, 'label': title, 'type': 'bool', 'default': raw == '1'})
            elif kind in ('number', 'select'):
                try:
                    value = int(float(raw)) if raw not in (None, '') else 0
                except ValueError:
                    value = 0
                suffix = '（选项序号，从 0 开始）' if kind == 'select' else ''
                settings.append({'key': key, 'label': title + suffix, 'type': 'number', 'default': value, 'min': -1, 'max': 999999999})
            else:
                suffix = '（多项用空格分隔）' if kind == 'list' else ''
                settings.append({'key': key, 'label': title + suffix, 'type': 'text', 'default': raw or ''})
        scope = (f'原脚本直跑：在游戏内执行原程序「{name}」的 Lua（指令未改）'
                 + (f'，同时载入原框架模块 {"、".join(framework)}' if framework else '')
                 + '；本程序已有的移动、对话、仓库等接口优先使用本程序实现；原程序设置页的参数按原键名列在下方，默认值取自原程序默认配置；'
                 '完成条件未单独核验，结束后按“失败处理”继续下一项')
        if risks:
            scope += '；含' + '、'.join(RISK_TEXT[r].removeprefix('允许') for r in risks) + '类操作，需要打开' + '、'.join(f'“{RISK_TEXT[r]}”' for r in risks)
        if data_files:
            scope += '；坐标取自原程序数据文件 ' + '、'.join(DATA_FILES[f][0] for f in data_files) + '，可在 安装目录/overrides/scripts/builtin/legacy/data/ 下放同名文件覆盖'
        if combat:
            scope += '；会战斗，使用技能页的技能'
        identity = existing['id'] if existing is not None else f'orig_{token}'
        record = {'id': identity, 'name': existing['name'] if existing is not None else name,
                  'category': existing['category'] if existing is not None else CATEGORY.get(group, '工具'),
                  'entry': 'original/generic_task.lua', 'source': f'tlzz:dfz64.dll/{group}/{name}.lua',
                  'module_sha256': m['original_sha256'], 'original_token': token, 'framework': framework,
                  'adapter': 'original_generic_v1', 'requires_resident': True, 'original_bytecode': True,
                  'rules_modified': False, 'reconstructed': False, 'timeout_seconds': timeout, 'live_verified': False,
                  'risks': risks, 'combat': combat}
        if data_files:
            record['data_files'] = data_files
        manifest['tasks'].append(record)
        ui = existing if existing is not None else {'id': identity, 'name': name, 'aliases': [], 'category': record['category'],
                                                      'source_refs': [f'tlzz:@..\\tlzs\\Script64\\{group}\\{name}.lua'],
                                                      'original_library_tokens': [token]}
        if existing is None:
            catalog['tasks'].append(ui)
        else:
            ui['planned_origin'] = True
        for alias in ('天龙助手', '原脚本直跑'):
            if alias not in ui.setdefault('aliases', []):
                ui['aliases'].append(alias)
        for key in ('planning_only', 'planning_blockers', 'methods', 'requires'):
            ui.pop(key, None)
        ui.update(family='legacy', adapter_status='integrated_pending_live', source_scope=scope, timeout_seconds=timeout,
                  requires_resident=True, generic_original=True, risks=risks, settings=settings, combat=combat)
        if not combat:
            ui.pop('combat', None)
        added.append((identity, name, len(framework), risks, combat))
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(len(added), 'generic tasks;', len(manifest['tasks']), 'manifest;', len(catalog['tasks']), 'catalog')
    for row in added:
        print(*row)


if __name__ == '__main__':
    main()
