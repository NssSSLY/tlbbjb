"""Record the current named stops of original-script tasks in tests/data/original-task-gaps.json.

Reads the diagnostic reports the self-tests write to TLBB_DUNGEON_DIAGNOSTIC_DIR (default .tools/temp/diag)
and adds, per task, the first error line without its "file:line:" prefix. Review each new entry: only a
real, named gap belongs here; a fixture shortcoming is fixed in the fixture instead. The tests fail on any
unlisted stop and on a listed gap that no longer happens.
"""
from pathlib import Path
import json, os, re, sys

ROOT = Path(__file__).resolve().parents[1]
GAPS = ROOT / 'tests/data/original-task-gaps.json'
REPORTS = Path(os.environ.get('TLBB_DUNGEON_DIAGNOSTIC_DIR', ROOT / '.tools/temp/diag'))
SECTIONS = {'all-generic-startup.json': 'sweep', 'requested-dungeon-start-diagnostics.json': 'diagnostics',
            'full-team-dungeon-diagnostics.json': 'diagnostics', 'sanshen-inside-diagnostics.json': 'diagnostics'}


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    gaps = json.loads(GAPS.read_text(encoding='utf-8')) if GAPS.exists() else {}
    for name, section in SECTIONS.items():
        path = REPORTS / name
        if not path.exists():
            continue
        table = gaps.setdefault(section, {})
        rows = json.loads(path.read_text(encoding='utf-8'))['results']
        if section == 'sweep':
            # The sweep covers every task: entries for tasks that no longer stop are dropped.
            for row in rows:
                key = row['task'] + ('#原脚本' if row.get('alternative') else '')
                if not (row.get('error') or row.get('preparation_error') or row.get('start_error')) and row.get('state') != 5:
                    table.pop(key, None)
        for row in rows:
            error = row.get('error') or row.get('preparation_error') or row.get('start_error') or ''
            if not error and row.get('state') != 5:
                continue
            key = row['task'] + ('#原脚本' if row.get('alternative') else '')
            line = re.sub(r'^(original_generic_host|task|\?):-?\d+: ', '', error.split('\n')[0])
            line = re.sub(r'(original_generic_host|task):\d+: ', '', line)[:80]
            if table.get(key) != line:
                print(section, key, '->', line)
                table[key] = line
    GAPS.write_text(json.dumps(gaps, ensure_ascii=False, indent=1, sort_keys=True) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
