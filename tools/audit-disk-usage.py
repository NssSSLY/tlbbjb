"""Read-only metadata scan; save findings only in the E-drive project."""
import ctypes
import argparse
import datetime as dt
import heapq
import json
import os
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--root', default='C:\\')
parser.add_argument('--report', default='disk-usage-audit.json')
options = parser.parse_args()
if Path(options.report).name != options.report or not options.report.endswith('.json'):
    raise SystemExit('Report must be a JSON filename inside project artifacts')
SINCE = dt.datetime(2026, 10, 23, 19, 0).timestamp()
DAY = dt.datetime(2026, 10, 23).timestamp()
started = time.time()
dirs, large, recent, errors, skipped = {}, [], [], [], []
get_size = ctypes.WinDLL('kernel32', use_last_error=True).GetCompressedFileSizeW
get_size.argtypes = [ctypes.c_wchar_p, ctypes.POINTER(ctypes.c_ulong)]
get_size.restype = ctypes.c_ulong

def stamp(value):
    return dt.datetime.fromtimestamp(value).astimezone().isoformat(timespec='seconds')

def scan(path):
    total = count = new = today = changed = 0
    try:
        with os.scandir(path) as entries:
            for e in entries:
                try:
                    s = e.stat(follow_symlinks=False)
                    if getattr(s, 'st_file_attributes', 0) & 0x400:
                        skipped.append(e.path)
                        continue
                    if e.is_dir(follow_symlinks=False):
                        a, b, c, d, f = scan(e.path)
                        total += a; count += b; new += c; today += d; changed += f
                        continue
                    n = s.st_size
                    born = getattr(s, 'st_birthtime', s.st_ctime)
                    total += n; count += 1
                    new += n if born >= SINCE else 0
                    today += n if born >= DAY else 0
                    changed += n if s.st_mtime >= SINCE else 0
                    if n >= 32 * 1024**2:
                        hi = ctypes.c_ulong()
                        low = get_size(e.path, ctypes.byref(hi))
                        allocated = (hi.value << 32) | low
                        if low == 0xffffffff and ctypes.get_last_error():
                            allocated = None
                        item = dict(path=e.path, bytes=n, allocated_bytes=allocated,
                                    created=stamp(born), modified=stamp(s.st_mtime))
                        large.append(item)
                        if born >= DAY or s.st_mtime >= SINCE:
                            recent.append(item)
                except OSError as exc:
                    errors.append(dict(path=e.path, error=str(exc)))
    except OSError as exc:
        errors.append(dict(path=str(path), error=str(exc)))
    dirs[str(path)] = dict(bytes=total, files=count, created_since_bytes=new,
                           created_today_bytes=today, modified_since_bytes=changed)
    return total, count, new, today, changed

scan(options.root)
print('Primary scan complete', round(time.time()-started, 1), 'seconds', flush=True)
scan(str(ROOT))
# Keep the evidence compact instead of retaining every small system directory.
kept_dirs = {p:v for p,v in dirs.items()
             if len(Path(p).parts) <= 4 or v['bytes'] >= 128*1024**2
             or (p.lower().startswith('c:\\users\\liqia')
                 and len(Path(p).parts) <= 8 and v['bytes'] >= 1024**2)
             or p.lower().startswith(str(ROOT).lower()) and len(Path(p).parts) <= 6}
report = dict(scanned_at=stamp(time.time()), since=stamp(SINCE),
    elapsed_seconds=round(time.time()-started, 1),
    notes=['File lengths are logical sizes; hardlinks may be counted more than once.',
           'Reparse points were skipped. Inaccessible directories are listed.',
           'Creation times and current file sizes are not a historical growth baseline.'],
    directories=kept_dirs, large_files=sorted(large, key=lambda x:x['bytes'], reverse=True),
    recent_large_files=sorted(recent, key=lambda x:x['bytes'], reverse=True),
    errors=errors, skipped_reparse_points=skipped)
out = ROOT/'artifacts'/options.report
out.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(dict(report=str(out), elapsed_seconds=report['elapsed_seconds'],
    files=dirs[options.root]['files'], errors=len(errors), skipped=len(skipped),
    largest=report['large_files'][:12], recent=report['recent_large_files'][:20]),
    ensure_ascii=False, indent=2), flush=True)
