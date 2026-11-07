"""Summarize current task entry, completion and scheduler evidence without playing."""
from pathlib import Path
from datetime import datetime, timezone
import collections
import hashlib
import json
import re
import shutil
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/task-audit-2026-10-27'
BUILD=ROOT/'.tools/build/client-0.15.0'
UI=ROOT/'artifacts/universal-runtime-0.15.0/native-ui'
def read(path):return json.loads(path.read_text(encoding='utf-8-sig'))
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    entry_audit=read(OUT/'entry-audit.json');assert entry_audit['passed'] and entry_audit['registered_entries']==136
    entries={e['id']:e for e in entry_audit['entries']};assert len(entries)==136
    catalog=read(ROOT/'design/task-catalog.json')['tasks'];manifest=read(ROOT/'scripts/legacy/manifest.json')['tasks']
    assert {t['id'] for t in manifest}==set(entries)
    rows=[]
    for task in catalog:
        identity=task['id'];audit=entries.get(identity);planning=task.get('planning_only',False)
        if audit:
            assert not planning and audit['entry_loaded']
            contract=audit['completion_validation']
            readiness='入口装载通过；完成状态仍待逐项核验' if contract=='script_return_only' else '入口与专用完成检查已接入；实机待验收'
        elif identity=='wait':readiness='时间等待入口；离线调度验收通过';contract='wait_condition'
        elif identity=='plant':readiness='仅流程预演；真实种植未接入';contract='preview_only'
        else:readiness='待适配；队列前检拒绝';contract='not_executable'
        rows.append(dict(id=identity,name=task['name'],category=task['category'],readiness=readiness,
            planning_only=planning,engine=audit['engine'] if audit else '',entry=audit['entry'] if audit else '',
            completion=contract,known_blockers=task.get('planning_blockers',[]),live_task_completed_in_this_audit=False))
    assert len(rows)==240 and not any(r['id']=='luoyang_move' for r in rows) and next(r for r in rows if r['id']=='shimen')['completion']=='not_executable'
    neutral=[]
    for line in (ROOT/'.tools/temp/tlbb-task-sweep.txt').read_text(encoding='utf-8').splitlines():
        fields=line.split('\t');neutral.append(dict(id=fields[0],outcome=fields[1],details=fields[2:]))
    assert len(neutral)==122 and all(not n['outcome'].startswith(('timeout','load:','receipt','exception:')) for n in neutral)
    neutral_finished=sum(n['outcome'].startswith('finished@') for n in neutral)
    neutral_stopped=sum(n['outcome'].startswith('failed:') for n in neutral)
    versions=[]
    for header,symbol,filename in [('include/live_layout.hpp','imageSha256','Game.exe'),('include/login_protocol.hpp','luaPlusSha256','LuaPlus.dll'),('include/login_protocol.hpp','ceguiSha256','CEGUIBase.dll')]:
        source=(ROOT/header).read_text(encoding='utf-8');expected=re.search(r'\b'+symbol+r'\[\]\s*=\s*"([0-9a-f]{64})"',source).group(1)
        path=ROOT.parent/'Bin64'/filename;actual=sha(path);assert expected==actual
        versions.append(dict(file=str(path),sha256=actual,expected=expected,matched=True))
    core=read(BUILD/'self-test.json');assert core['status']=='pass' and not core['failure']
    for required in ['all_registered_task_entries_compile_with_supported_engines','sequential_completion_unknown_limit_and_failure_policies',
                     'original_daily_sdk_text_counts_limits_and_queue_progression','resident_original_archive_task_inventory_receipts_and_no_replay']:
        assert required in core['passed']
    ctest=ET.parse(OUT/'ctest.xml').getroot();assert len(ctest.findall('.//testcase'))==5 and not ctest.findall('.//failure')
    ui=read(UI/'verification.json');assert ui['passed'] and ui['remaining_sessions']==0 and ui['gameplay_actions_sent']==0
    assert any('Bare Lua return' in text for text in ui['checks']) and any('later script' in text for text in ui['checks'])
    sdk=read(BUILD/'gameplay-snippet-test.json');battle=read(BUILD/'battle-support-test.json');daily=read(ROOT/'artifacts/npc-lua-compat-0.15.0/daily-task-cases.json')
    assert sdk['status']=='pass' and battle['passed'] and daily['status']=='pass'
    assets=read(UI/'resource-index.json');assert assets['mounted'] and assets['bundle_bytes']<8*1024*1024
    for asset in assets['files']:
        source=ROOT/('design/task-catalog.json' if asset['path']=='tasks/catalog.json' else asset['path'].replace('scripts/builtin/','scripts/',1))
        assert sha(source)==asset['sha256']
    for filename in ['TLBB.exe','TLBBEngine.dll','TLBBData.rcc']:
        assert sha(BUILD/filename)==sha(UI/'owned-compact-runtime'/filename)
    for filename in ['self-test.json','gameplay-snippet-test.json','battle-support-test.json','login-test.json','login-api-test.json']:
        shutil.copy2(BUILD/filename,OUT/filename)
    shutil.copy2(UI/'verification.json',OUT/'ui-verification.json');shutil.copy2(UI/'resource-index.json',OUT/'resource-index.json')
    shutil.copy2(ROOT/'artifacts/npc-lua-compat-0.15.0/daily-task-cases.json',OUT/'daily-task-cases.json')
    shutil.copy2(ROOT/'.tools/temp/tlbb-task-sweep.txt',OUT/'neutral-world-results.txt')
    result=dict(status='pass_with_functional_gaps',created_at=datetime.now(timezone.utc).isoformat(),version='0.15.0',
        catalog_entries=len(rows),registered_entries=len(manifest),visible_registered_tasks=len(manifest)-1,
        resident_entries=entry_audit['resident_entries'],external_entries=entry_audit['external_entries'],
        largest_resident_package_bytes=entry_audit['largest_resident_package_bytes'],strict_contract_tasks=[t['id'] for t in manifest if t.get('validation_contract')],
        completion_categories=dict(collections.Counter(t['completion_validation'] for t in entries.values())),
        unverified_business_tasks=sum(t['completion']=='script_return_only' for t in rows),
        shimen_callable=False,all_dungeons_and_activities_verified=False,sequential_scheduler_offline_verified=True,
        neutral_world=dict(tested=len(neutral),returned=neutral_finished,stopped_with_reason=neutral_stopped,confirms_task_achievement=False),
        fixed=['non-combat entry preflight','unverified completion no longer labels success or deletes timed drafts','exam engine uses its complete external question bank'],
        ctest_targets=5,core_checks=core['passed_count'],native_ui_checks=len(ui['checks']),sdk_checks=sdk['checks'],battle_cases=len(battle['checks']),daily_sdk_cases=daily['case_count'],
        native_hotkeys_verified_on_owned_fixtures=ui['native_hotkey_input_verified_on_owned_fixtures'],
        game_version_checks=versions,bundled_assets=len(assets['files']),real_game_tested=False,installer_generated=False,zip_generated=False,
        tasks=rows,neutral_world_results=neutral,
        changed_sources=[dict(path=str(p.relative_to(OUT/'before')).replace('\\','/'),before_sha256=sha(p),after_sha256=sha(ROOT/p.relative_to(OUT/'before'))) for p in sorted((OUT/'before').rglob('*')) if p.is_file()],
        binaries=[dict(path=str(BUILD/name),sha256=sha(BUILD/name)) for name in ['TLBB.exe','TLBBEngine.dll','TLBBData.rcc']])
    (OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    columns=['id','name','category','readiness','engine','entry','completion']
    (OUT/'task-readiness.tsv').write_text('\t'.join(columns)+'\n'+'\n'.join('\t'.join(str(row.get(k,'')) for k in columns) for row in rows)+'\n',encoding='utf-8-sig')
    print(json.dumps({k:v for k,v in result.items() if k not in ['tasks','neutral_world_results','changed_sources','binaries','game_version_checks']},ensure_ascii=False,indent=2))

if __name__=='__main__':main()
