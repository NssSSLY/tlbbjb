"""Check the deployed package without a developer PATH; never issue game actions."""
from pathlib import Path
import hashlib
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / ".tools" / "pythonpkgs"))
import psutil

exe = ROOT / "dist" / "TLBBClient" / "TLBB.exe"
artifacts = ROOT / "artifacts"
environment = os.environ.copy()
environment["PATH"] = os.pathsep.join([str(Path(os.environ["SystemRoot"]) / "System32"), os.environ["SystemRoot"]])
environment.pop("QT_PLUGIN_PATH", None)
environment.pop("QT_QPA_PLATFORM_PLUGIN_PATH", None)

def run(*args, timeout=20):
    result = subprocess.run([str(exe), *map(str, args)], env=environment, capture_output=True,
                            timeout=timeout, creationflags=subprocess.CREATE_NO_WINDOW)
    if result.returncode:
        raise RuntimeError(f"Client check failed ({result.returncode}): {result.stderr.decode(errors='replace')}")

run("--self-test", ROOT, artifacts / "client-packaged-self-test.json")
games = []
for process in psutil.process_iter(["pid", "exe"]):
    path = process.info.get("exe") or ""
    if path.replace("\\", "/").lower() in {"e:/game/tlbb/bin64/game.exe", "e:/game/tlbb/bin/game.exe"}:
        games.append(process.info["pid"])
ui = ["--ui-smoke", artifacts / "client-panel.png", "--report", artifacts / "client-ui-smoke.json"]
if games:
    run("--probe-binding", "--target-pid", games[0], "--game-root", "E:/game/tlbb", "--report", artifacts / "client-live-binding.json")
    ui.extend(["--probe-ui-binding", games[0]])
run(*ui)
tests = json.loads((artifacts / "client-packaged-self-test.json").read_text(encoding="utf-8-sig"))
panel = json.loads((artifacts / "client-ui-smoke.json").read_text(encoding="utf-8-sig"))
assert tests["status"] == "pass"
assert panel["resource_job_configured"]
if games:
    assert any(s["pid"] == games[0] and s["ready"] for s in panel["sessions"])
report = {
    "status": "pass", "exe": str(exe), "sha256": hashlib.sha256(exe.read_bytes()).hexdigest(),
    "isolated_package_test_count": tests["passed_count"], "ui": panel,
    "real_game_readonly_binding_tested": bool(games),
    "actual_game_movement_or_planting_tested": False,
    "scope": "Package verification and read-only live state; this verifier issues no actions. Native movement is tested separately.",
}
(artifacts / "client-verification.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(report, ensure_ascii=False, indent=2))
