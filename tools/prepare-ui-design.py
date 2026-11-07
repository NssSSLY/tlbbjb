"""Validate current design fragments against the canonical task catalog."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / "design/prototype/tlbb-session-panel.html"
fragment = source.read_text(encoding="utf-8")
catalog = json.loads((ROOT / "design/task-catalog.json").read_text(encoding="utf-8"))
tasks = catalog["tasks"]
assert len({t["id"] for t in tasks}) == len(tasks), "Duplicate task IDs"
assert {t["category"] for t in tasks} == {"副本", "日常", "限时", "生活", "野外", "工具"}
assert [t["id"] for t in tasks if t["adapter_status"] != "unadapted"] == ["luoyang_move"]
known_refs = {f"S{i:02}" for i in range(1, 16)} | {"user", "local:0.2"}
assert all(set(t["source_refs"]) <= known_refs for t in tasks)
for filename in ["tlbb-session-panel.html", "tlbb-launcher.html"]:
    document = ROOT / "design/prototype" / filename
    markup = document.read_text(encoding="utf-8")
    assert not re.search(r"<!doctype|<(?:html|head|body)(?:\s|>)", markup, re.I)
    assert not re.search(r"\b(?:fetch|XMLHttpRequest|WebSocket)\s*\(", markup)
    assert not re.search(r'''(?:src|href)\s*=\s*["']https?://''', markup, re.I)
    assert document.stat().st_size < 1_000_000
panel_tasks = json.loads(re.search(r'<script id="sp-task-data" type="application/json">(.*?)</script>', fragment, re.S).group(1))
canonical = {t["id"]: t for t in tasks}
assert len({t["id"] for t in panel_tasks}) == len(panel_tasks)
assert all(t["id"] in canonical and t["name"] == canonical[t["id"]]["name"] for t in panel_tasks)
assert set(t["id"] for t in panel_tasks) == set(canonical)
assert not re.search(r"<header\b|class=\"[^\"]*(?:role-list|role-sidebar)", fragment)
example = json.loads((ROOT / "design/role-profile.example.json").read_text(encoding="utf-8"))
assert example["logistics"]["destroy"]["enabled"] is False
assert example["identity"]["credential_ref"] is None
assert all(n["task_id"] in {t["id"] for t in tasks} for n in example["queue"])
launcher = json.loads((ROOT / "design/launcher-profile.example.json").read_text(encoding="utf-8"))
unknown = launcher["accounts"][0]["destinations"][0]
assert unknown["characters"] == [] and unknown["roster_state"] == "unknown"
assert all(a["credential_ref"] is None and a["login_name"] is None for a in launcher["accounts"])
assert launcher["runtime"]["auto_start_tasks_after_login"] is False
report = {"catalog_tasks": len(tasks), "categories": 6, "panel_task_count": len(panel_tasks), "panel_bytes": source.stat().st_size, "profile_examples_valid": True, "layout_revision": "0.3-r2"}
out = ROOT / "artifacts/ui-design-r2"
out.mkdir(parents=True, exist_ok=True)
(out / "static-verification.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, ensure_ascii=False))
