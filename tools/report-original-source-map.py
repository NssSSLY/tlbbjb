"""Write docs/ORIGINAL_SOURCE_MAP.md: every original script and the program task that uses it.

Inputs: scripts/original-source/index.json, scripts/original-library/index.json,
scripts/legacy/manifest.json and design/task-catalog.json. Rerun after the manifest changes.
"""
from pathlib import Path
import collections, json, re, sys

ROOT = Path(__file__).resolve().parents[1]
EXCLUDE = re.compile(r'关机|删|销毁|拆解|淬解|抢购|商会|金币元宝互换|九州零点抢店|^抢(?!箱子)|^合成宝石$|^一键日常$')
ADAPTER = {
    'original_generic_v1': '原脚本源码直跑',
    'tlzz_compat_v1': '本程序改写',
    'original_daily_v1': '原日常规则（独立接口）',
    'original_archive_v1': '原脚本（存档接口）',
    'original_dungeon_v1': '原棋局规则',
    'dungeon_flow_v1': '独立副本流程',
    'sijue_flow_v1': '独立副本流程',
    'water_prison_v1': '独立副本流程',
    'yanzi_flow_v1': '独立副本流程',
    'shaoshi_flow_v1': '独立副本流程',
    'piaomiao_flow_v1': '独立副本流程',
    'bingsheng_flow_v1': '独立副本流程',
    'langhuan_flow_v1': '独立副本流程',
    'wangling_flow_v1': '独立副本流程',
    'sanshen_flow_v1': '独立副本流程',
    'guanshan_flow_v1': '独立副本流程',
    'yezhu_flow_v1': '独立副本流程',
    'mingwang_flow_v1': '独立副本流程',
    'tianbo_flow_v1': '独立副本流程',
    'fenghuang_flow_v1': '独立副本流程',
    'yijue_flow_v1': '独立副本流程',
    'juling_flow_v1': '独立副本流程',
    'tianjiang_flow_v1': '独立副本流程',
    'shimen_flow_v1': '独立副本流程',
    'short_flow_v1': '独立副本流程',
    'mazei_flow_v1': '独立副本流程',
    'zhuxian_flow_v1': '独立副本流程',
    'xinshou_flow_v1': '独立副本流程',
    'songliao_flow_v1': '独立副本流程',
    'chongwu_flow_v1': '独立副本流程',
    'shijian_flow_v1': '独立副本流程',
    'fanzei_flow_v1': '独立副本流程',
    'xiaoxiao_flow_v1': '独立副本流程',
    'jiaxue_flow_v1': '独立副本流程',
    'tuanzhan_flow_v1': '独立副本流程',
    'saodang_flow_v1': '独立副本流程',
    'suyuan_flow_v1': '独立副本流程',
    'chuhan_flow_v1': '独立副本流程',
    'xiaoaci_flow_v1': '独立副本流程',
    'xiakexing_flow_v1': '独立副本流程',
    'nixi_flow_v1': '独立副本流程',
    'cuju_flow_v1': '独立副本流程',
    'shuaxiang_flow_v1': '独立副本流程',
    'tianlong_flow_v1': '独立副本流程',
}
# Rewritten tasks that tools/add-original-alternatives.py could not offer the original for.
NO_ALTERNATIVE = {**{i: '原脚本载入的 fn扫荡副本 在原程序中不存在，不能切换' for i in (
    'tlzz_sweep_laosan', 'tlzz_sweep_sijue', 'tlzz_sweep_shaoshi', 'tlzz_sweep_yanzi', 'tlzz_sweep_sanshen',
    'tlzz_sweep_wangling', 'tlzz_sweep_fudi', 'tlzz_sweep_fudi_hard', 'tlzz_sweep_bingsheng', 'tlzz_sweep_piaomiao')},
    **{i: '原脚本载入的 fnInterface 在原程序中不存在，不能切换' for i in ('tlzz_gem_unbound', 'tlzz_gem_bound', 'tlzz_gem_mixed')},
    'tlzz_shop_get_money': '商会类，不提供原脚本切换'}
# Custom scripts without a task of the same name, checked one by one.
CUSTOM = {
    '[自定义] 接口说明': ('原接口说明', '说明文档，原程序也不执行；其中的中文接口（等待、输入屏幕文本、音乐报警等）本程序已按原名提供'),
    '兑换元宝票': ('缺原生接口', '调用原程序原生的 Player:YB2Ticket（元宝换元宝票，原 Lua 中没有定义），本程序未提供，暂不接入'),
    '古兰玉换宝石': ('同名任务覆盖', '只执行 LoadScript("古兰玉兑换宝石")，即任务 古兰玉兑换宝石（`tlzz_gulanyu`）'),
    '锦囊宝箱消化': ('按要求不接入', '含 DelBagItem(-1) 清理背包（删除物品）'),
    '等待到时间': ('同名任务覆盖', '与 等待到时间（原例）（`tlzz_wait_time`）相同，只是时刻写死为 00:05'),
    '自动组队(例)': ('原自定义示例', '调用 创建队伍 / 解散队伍 / 申请进组；这三个接口本程序尚未接入，运行会提示“该接口尚未接入”'),
}
DATA_USE = {'坐标刷马': 'mazei_pos', '坐标天降奇兽': 'tianjiang_pos', '坐标摆摊': 'baitan_pos', '坐标清剿九黎余孽': 'jiuli_pos'}


def base(s):
    return s.replace('\\', '/').split('/')[-1].removesuffix('.lua')


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    sources = json.loads((ROOT / 'scripts/original-source/index.json').read_text(encoding='utf-8'))
    library = json.loads((ROOT / 'scripts/original-library/index.json').read_text(encoding='utf-8'))
    manifest = json.loads((ROOT / 'scripts/legacy/manifest.json').read_text(encoding='utf-8'))['tasks']
    catalog = {t['id']: t for t in json.loads((ROOT / 'design/task-catalog.json').read_text(encoding='utf-8'))['tasks']}
    by_token, by_name = collections.defaultdict(set), collections.defaultdict(set)
    for t in manifest:
        if t.get('original_token'):
            by_token[t['original_token']].add(t['id'])
        for k in ('source', 'reference_source'):
            if t.get(k):
                by_name[base(t[k])].add(t['id'])
    for c in catalog.values():
        for r in c.get('source_refs', []):
            by_name[base(r)].add(c['id'])
        for tk in c.get('original_library_tokens', []):
            by_token[tk].add(c['id'])
    entries = {t['id']: t for t in manifest}
    framework_users = collections.Counter(n for t in manifest for n in t.get('framework', []))
    data_users = collections.defaultdict(list)
    for t in manifest:
        for d in t.get('data_files', []):
            data_users[d].append(t['id'])
    groups = {m['token']: m['group'] for m in library['modules'] + library['custom_sources']}
    rows, counts = collections.defaultdict(list), collections.Counter()
    for token, s in sorted(sources['modules'].items(), key=lambda kv: kv[1]['path']):
        name = s['name'].split('·', 1)[-1]
        ids = sorted(by_token.get(token, set()) | by_name.get(name, set()))
        runnable = [i for i in ids if i in entries]
        fixes = '；'.join(sources['fixed'].get(s['path'], []))
        group = groups[token]
        if runnable:
            t = entries[runnable[0]]
            kind = ADAPTER.get(t.get('adapter'), '本程序任务')
            task = '、'.join(f"{catalog.get(i, {}).get('name', entries[i]['name'])}（`{i}`）" for i in runnable)
            if t.get('adapter') == 'tlzz_compat_v1':
                task += '；设置“用原脚本源码执行”可改跑原脚本' if 'original_alternative' in t else '；' + NO_ALTERNATIVE.get(t['id'], '无原脚本切换')
        elif group == '系统':
            kind, task = '原框架模块', f"被 {framework_users[name]} 个直跑任务载入" if framework_users[name] else '未被直跑任务引用'
        elif group == '数据':
            key = DATA_USE.get(name)
            users = data_users.get(key, [])
            kind = '原数据'
            task = ('坐标随任务预载：' + '、'.join(f'`{u}`' for u in users)) if users else ('科举题库（`scripts/legacy/data/keju_bank.lua`）' if name == '科举' else '暂无已接入任务读取')
        elif EXCLUDE.search(name):
            kind, task = '按要求不接入', '删除 / 关机 / 商会 / 抢购 / 拆解类'
        elif group == '自定义':
            kind, task = CUSTOM[name]
        else:
            kind, task = '未接入', '—'
        counts[kind] += 1
        rows[s['path'].split('/')[0] + '/' + s['path'].split('/')[1]].append((s['path'], kind, task, fixes))
    lines = ['# 原脚本源码对接表', '',
             '由 `python tools/report-original-source-map.py` 生成。程序内副本在 `scripts/original-source/`，与 `原脚本源码/` 一一对应（原目录不改）；'
             '运行时由程序编译这些源码后送入游戏内 Lua，不再使用提取的字节码分片。每个反编译文件在导入时都与原字节码逐函数比对（`tools/import-original-source.py`）。', '',
             '| 类别 | 数量 |', '|---|---|']
    lines += [f'| {k} | {v} |' for k, v in counts.most_common()]
    lines += ['', '“原脚本源码直跑”：任务直接执行该脚本；“本程序改写 / 独立流程”：同名任务由本程序重写，原脚本作对照；“原框架模块”：被直跑任务按需载入。', '']
    for folder in sorted(rows):
        lines += [f'## {folder}', '', '| 脚本 | 类别 | 程序中的任务 / 用途 | 程序内副本修正 |', '|---|---|---|---|']
        for path, kind, task, fixes in rows[folder]:
            lines.append(f"| `{path.split('/', 2)[-1]}` | {kind} | {task} | {fixes or '—'} |")
        lines.append('')
    out = ROOT / 'docs/ORIGINAL_SOURCE_MAP.md'
    out.write_text('\n'.join(lines), encoding='utf-8')
    print(out, dict(counts))


if __name__ == '__main__':
    main()
