"""Record verified local versions, source hashes, and resource availability."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import json
import os
import platform
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / ".tools"
sys.path.insert(0, str(TOOLS / "pythonpkgs"))
import psutil

def sha(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()

def command(path, *args):
    environment = os.environ.copy()
    environment["PATH"] = os.pathsep.join([str(mingw / "bin"), str(qt / "bin"), environment.get("PATH", "")])
    result = subprocess.run([str(path), *args], capture_output=True, text=True, check=True, env=environment, timeout=20)
    return (result.stdout or result.stderr).strip()

qt = TOOLS / "Qt" / "6.8.3" / "mingw_64"
mingw = TOOLS / "Qt" / "Tools" / "mingw1310_64"
smoke = json.loads((ROOT / "artifacts" / "environment-smoke.json").read_text(encoding="utf-8-sig"))
deployed = json.loads((ROOT / "artifacts" / "environment-deployment.json").read_text(encoding="utf-8-sig"))
ctest = ET.parse(ROOT / "artifacts" / "environment-ctest.xml").getroot()
memory = psutil.virtual_memory()
distributions = sorted((d.metadata["Name"], d.version) for d in importlib.metadata.distributions(path=[str(TOOLS / "pythonpkgs")]))
(ROOT / "tools" / "environment-requirements.lock.txt").write_text(
    "".join(f"{name}=={version}\n" for name, version in distributions), encoding="utf-8")
archive_hashes = [{"path": str(p.relative_to(ROOT)), "bytes": p.stat().st_size, "sha256": sha(p)}
                  for p in sorted((TOOLS / "downloads").rglob("*")) if p.is_file()]
source_files = [p for p in sorted((ROOT / "tools").rglob("*")) if p.is_file() and p.suffix in {".ps1", ".py", ".cpp", ".txt", ".ui"}]
tool_bytes = sum(p.stat().st_size for p in TOOLS.rglob("*") if p.is_file())
report = {
    "status": "ready_for_external_windows_client",
    "captured_at": datetime.now(timezone.utc).isoformat(),
    "workspace": str(ROOT), "os": platform.platform(),
    "logical_processors": psutil.cpu_count(), "physical_memory_gib": round(memory.total / 2**30, 2),
    "available_memory_gib": round(memory.available / 2**30, 2),
    "workspace_disk_free_gib": round(psutil.disk_usage(str(ROOT)).free / 2**30, 2),
    "local_tools_bytes": tool_bytes,
    "versions": {
        "cmake": command(TOOLS / "cmake" / "bin" / "cmake.exe", "--version").splitlines()[0],
        "ninja": command(TOOLS / "ninja" / "ninja.exe", "--version"),
        "gcc": command(mingw / "bin" / "gcc.exe", "-dumpfullversion"),
        "gcc_target": command(mingw / "bin" / "gcc.exe", "-dumpmachine"),
        "qt": command(qt / "bin" / "qmake.exe", "-query", "QT_VERSION"),
        "lua": smoke["lua_version"], "setup_python": sys.version.split()[0], "aqtinstall": "3.3.0",
    },
    "ctest": {"tests": ctest.attrib.get("tests"), "failures": ctest.attrib.get("failures"), "time": ctest.attrib.get("time")},
    "smoke": smoke, "isolated_deployment": deployed,
    "archives": archive_hashes,
    "source_hashes": [{"path": str(p.relative_to(ROOT)), "sha256": sha(p)} for p in source_files],
    "reused_components": [
        {"name": "CMake", "source": r"E:\project\hua\.tools\cmake-4.4.4-windows-x86_64", "mode": "copied_into_this_workspace"},
        {"name": "Ninja", "source": r"E:\project\hua\.tools\ninja-1.13.2", "mode": "copied_into_this_workspace"},
    ],
    "system_changes": {"persistent_path_changed": False, "global_python_packages_installed": False,
                       "visual_studio_installed": False, "microsoft_windows_sdk_installed": False},
    "limits": [
        "No game process access or gameplay action occurred during build-environment tests.",
        "Widgets rendered without displaying a window on the user's interactive desktop.",
        "Job API test configures a limit but does not prove production enforcement or performance budgets.",
        "No MSVC ABI compatibility with the game's internal C++ classes is established.",
        "Vulkan/DXC/translation assets were not installed; they are unnecessary for the verified Widgets path.",
    ],
}
path = ROOT / "artifacts" / "build-environment.json"
path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"report": str(path), "status": report["status"], "versions": report["versions"],
                  "ctest": report["ctest"], "tools_gib": round(tool_bytes / 2**30, 2),
                  "physical_memory_gib": report["physical_memory_gib"],
                  "available_memory_gib": report["available_memory_gib"],
                  "disk_free_gib": report["workspace_disk_free_gib"]}, indent=2))
