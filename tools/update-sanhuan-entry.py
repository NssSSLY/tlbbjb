"""Register the explicit three-stage dungeon flows; preserve unrelated tasks."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def settings(old):
    fields = [
        {'key': '老三环' if old else 'dungeon_team_count', 'label': '最低队伍人数（副本至少 3 人）',
         'type': 'number', 'min': 0 if old else 3, 'max': 6, 'default': 3},
        {'key': 'dungeon_rounds', 'label': '完成轮数', 'type': 'number', 'min': 1, 'max': 20, 'default': 1},
        {'key': 'dungeon_wait_seconds', 'label': '队伍 / 状态等待（秒）', 'type': 'number', 'min': 5, 'max': 180, 'default': 45},
        {'key': 'dungeon_battle_seconds', 'label': '每轮战斗超时（秒）', 'type': 'number', 'min': 30, 'max': 3600, 'default': 1200},
    ]
    if not old:
        fields += [
            {'key': 'enter_option', 'label': '入场选项（留空自动匹配）', 'type': 'text', 'default': ''},
            {'key': 'sanhuan_route', 'label': '巡点坐标（留空读取任务坐标）', 'type': 'text', 'default': ''},
            {'key': 'sanhuan_exit_npc', 'label': '离场 NPC（留空读取返回坐标）', 'type': 'text', 'default': ''},
            {'key': 'leave_option', 'label': '离场选项原文', 'type': 'text', 'default': ''},
        ]
    return fields


def main():
    for relative in ('scripts/legacy/manifest.json', 'design/task-catalog.json'):
        path = ROOT / relative
        original = path.read_text(encoding='utf-8-sig')
        document = json.loads(original)
        tasks = document['tasks']
        for old, task_id in ((True, 'dungeon_00320005'), (False, 'dungeon_new_sanhuan')):
            item = next((t for t in tasks if t['id'] == task_id), None)
            if item is None:
                item = {'id': task_id}
                tasks.append(item)
            for key in ('original_token', 'framework', 'generic_original', 'module_sha256', 'planned_origin',
                        'original_bytecode', 'original_library_tokens', 'plan_feature', 'plan_priority'):
                item.pop(key, None)
            item.update(name='除匪首力破三关' if old else '剑荡三环除妖魔', category='副本',
                        requires_resident=True, supported_engines=['游戏内 Lua'], combat=True,
                        timeout_seconds=7200, rules_modified=True, reconstructed=True, live_verified=False,
                        validation_contract='dungeon_flow_v1', adapter='dungeon_flow_v1', risks=[])
            if relative.startswith('scripts/'):
                item.update(entry='dungeons/sanhuan_old.lua' if old else 'dungeons/sanhuan_new.lua',
                            source='local:explicit_sanhuan_flow',
                            reference_source='tlzz:00320005' if old else 'official:201504/qingmang + user:何悦(295,68)')
            else:
                item.update(family='legacy', aliases=['老三环', '苏州三环'] if old else ['新三环', '楼兰三环', '炎魔山'],
                            adapter_status='integrated_pending_live', settings=settings(old),
                            source_scope='明文阶段流程：检查任务、组队、入场、按进度战斗、交付和离场。' +
                            ('使用本机三才峡谷进度面板及原路线。' if old else
                             '优先读取任务目标坐标；无任务坐标时需配置巡点路线和离场方式。'))
        updated = json.dumps(document, ensure_ascii=False, indent=2) + '\n'
        if updated != original:
            backup = ROOT / 'artifacts/sanhuan-2026-10-28/before' / relative
            backup.parent.mkdir(parents=True, exist_ok=True)
            if not backup.exists():
                backup.write_text(original, encoding='utf-8')
            path.write_text(updated, encoding='utf-8')


if __name__ == '__main__':
    main()
