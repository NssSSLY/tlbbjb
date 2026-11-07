"""Pack the app DLL, Qt and the compiler runtime into TLBBRuntime.dll, one resource the launcher unpacks once per version."""
from pathlib import Path
import argparse
import hashlib
import struct
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("source", type=Path, help="Folder holding TLBBApp.dll and what windeployqt put next to it")
parser.add_argument("output", type=Path, help="TLBBRuntime.dll to write")
parser.add_argument("--mingw", type=Path, required=True, help="MinGW root")
parser.add_argument("--work", type=Path, required=True, help="Folder for intermediate files")
args = parser.parse_args()

files = sorted(p for p in args.source.rglob("*") if p.is_file())
assert files and (args.source / "TLBBApp.dll").is_file(), "TLBBApp.dll is missing from the runtime folder"
body = bytearray(struct.pack("<I", len(files)))
digest = hashlib.sha256()
for file in files:
    name = file.relative_to(args.source).as_posix().encode("utf-8")
    data = file.read_bytes()
    digest.update(name); digest.update(data)
    body += struct.pack("<I", len(name)) + name + struct.pack("<Q", len(data)) + data
tag = digest.hexdigest()[:16].encode("ascii")

args.work.mkdir(parents=True, exist_ok=True)
blob = args.work / "runtime-pack.bin"
blob.write_bytes(b"TLBBPACK1\n" + tag + bytes(body))
rc = args.work / "runtime-pack.rc"
rc.write_text('1 RCDATA "runtime-pack.bin"\n', encoding="ascii")
stub = args.work / "runtime-pack.c"
stub.write_text("/* Resource-only library. */\nint __stdcall DllMainCRTStartup(void *a, unsigned long b, void *c) { (void)a; (void)b; (void)c; return 1; }\n", encoding="ascii")
obj = args.work / "runtime-pack.o"
bin_dir = args.mingw / "bin"
subprocess.run([str(bin_dir / "windres.exe"), "-i", rc.name, "-o", obj.name, "-O", "coff"], cwd=args.work, check=True)
subprocess.run([str(bin_dir / "gcc.exe"), "-shared", "-nostdlib", "-s", "-o", str(args.output), stub.name, obj.name], cwd=args.work, check=True)
print(args.output, args.output.stat().st_size, tag.decode())
