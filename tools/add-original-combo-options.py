"""Give original-script dropdown settings their real options, taken from the original scripts themselves.

GetConfigCommbox returns {sel, text, data}; scripts read .text (map / item names). Without an option list the
setting was a bare index and the task stopped with "下拉配置缺少 text 映射". Each list below comes from the
script's own comparisons or tables (cited per entry); the default is the first option. Also ships the
reference program's route files (data\\坐标\\*.txt) used by 采集脚本. Idempotent.
"""
from pathlib import Path
import json, re, shutil, sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'scripts/original-source/Script64'  # program copies: Chinese keys spelled ["..."]
COORDS = ROOT / '满天星/天龙助手/data/坐标'


def read(rel):
    return (SRC / rel).read_text(encoding='utf-8')


def options():
    out = {}
    # 逆袭.lua: if "<map>" == m_actionScene ...
    out[('nixi', '逆袭地图')] = re.findall(r'"([^"]+)" == m_actionScene', read('活动/逆袭.lua'))
    # 属地马贼.lua: m_data.scenePos["<map>"] = {...}
    out[('orig_00378b88', '刷马地图')] = re.findall(r'm_data\.scenePos\["([^"]+)"\] =', read('常用/属地马贼.lua'))
    # 星落九野.lua: g_xljy_pos["<map>"] = {...}
    out[('xingluo', '采集地图')] = re.findall(r'g_xljy_pos\["([^"]+)"\] =', read('常用/星落九野.lua'))
    # 自动摆摊: twscene is looked up in 坐标摆摊's table (洛阳 / 苏州).
    out[('orig_0045d2b4', '摆摊地图')] = ['洛阳', '苏州']
    # 采集脚本: the text names a route file data\坐标\<text>.txt of the reference program.
    out[('gather_script', '采集地图')] = sorted(p.stem for p in COORDS.glob('*.txt'))
    # 庄园: m_data.option[<成熟时间 text> .. <type text>]; split each key into its two halves.
    for task, file, second in (('tlzz_manor_fish', '帮庄/庄园养鱼.lua', '播撒类型'), ('tlzz_manor_plant', '帮庄/庄园种植.lua', '树木类型'),
                               ('tlzz_manor_mine', '帮庄/庄园采矿.lua', '矿石类型')):
        text = read(file)
        body = text[text.index('m_data.option ='):]
        keys = re.findall(r'\["([^"]+)"\]\s*=', body[:body.index('\n}') + 2])
        firsts = list(dict.fromkeys(k[:2] for k in keys))
        seconds = list(dict.fromkeys(k[2:] for k in keys))
        assert all(f + s in keys for f in firsts for s in seconds), file
        out[(task, '成熟时间')] = firsts
        out[(task, second)] = seconds
    # 宝石兑换券: an empty name skips that grade; the script itself names only these two gems.
    gems = sorted(set(re.findall(r'"([^"]{2,5}石)"', read('功能/宝石兑换券.lua'))))
    out[('tlzz_gem_voucher', '宝石兑换券3级')] = [''] + gems
    out[('tlzz_gem_voucher', '宝石兑换券4级')] = [''] + gems
    return out


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    catalog_path = ROOT / 'design/task-catalog.json'
    catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
    tasks = {t['id']: t for t in catalog['tasks']}
    done = []
    for (task, key), choices in options().items():
        assert choices, (task, key)
        settings = tasks[task].setdefault('settings', [])
        field = next((s for s in settings if s['key'] == key), None)
        if field is None:
            field = {'key': key, 'label': key}
            if tasks[task].get('family') == 'legacy' and not tasks[task].get('generic_original'):
                field['source'] = 'original_alternative'; field['label'] = '原脚本：' + key
            settings.append(field)
        label = re.sub(r'（选项序号，从 0 开始）$', '', field.get('label', key))
        field.clear()
        field.update({'key': key, 'label': label, 'type': 'choice', 'choices': choices, 'default': choices[0]})
        if task.startswith('tlzz_'):
            field['source'] = 'original_alternative'
        done.append((task, key, len(choices)))
    catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    # Route files for 采集脚本, served read-only to the task (original_generic_host io.open).
    target = ROOT / 'scripts/legacy/data/coords'
    target.mkdir(parents=True, exist_ok=True)
    for p in COORDS.glob('*.txt'):
        (target / p.name).write_text(p.read_bytes().decode('gb18030').replace('\r\n', '\n'), encoding='utf-8')
    manifest_path = ROOT / 'scripts/legacy/manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    for t in manifest['tasks']:
        if t['id'] == 'gather_script':
            t['coord_files'] = True
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    for row in done:
        print(*row)


if __name__ == '__main__':
    main()
