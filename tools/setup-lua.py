"""Download the pinned Lua source into this workspace; no global installation."""
from pathlib import Path
import hashlib
import json
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
VERSION = "5.4.9"
EXPECTED = "2335b6c582a52654f94612bf10d2f4672805d05329aa6568b1d8cd9e5c6fb8e6"
URL = f"https://www.lua.org/ftp/lua-{VERSION}.tar.gz"
archive = ROOT / ".tools" / "downloads" / f"lua-{VERSION}.tar.gz"
archive.parent.mkdir(parents=True, exist_ok=True)
if not archive.exists():
    with urllib.request.urlopen(URL, timeout=60) as response:
        payload = response.read(2 * 1024 * 1024)
    archive.write_bytes(payload)
actual = hashlib.sha256(archive.read_bytes()).hexdigest()
if actual != EXPECTED:
    raise SystemExit(f"Lua checksum mismatch: {actual}")
destination = ROOT / ".tools" / "src"
destination.mkdir(parents=True, exist_ok=True)
with tarfile.open(archive, "r:gz") as package:
    package.extractall(destination, filter="data")
print(json.dumps({"version": VERSION, "url": URL, "sha256": actual,
                  "source": str(destination / f"lua-{VERSION}")}, indent=2))
