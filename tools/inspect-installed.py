"""Compare the real installed directory to the manifest and write a file listing."""
from pathlib import Path
import hashlib
import json
import sys
ROOT=Path(__file__).resolve().parents[1]
target=Path(sys.argv[1]).resolve()
manifest=json.loads((target/"data/package-manifest.json").read_text(encoding="utf-8"))
records=[]
for expected in manifest["files"]:
    file=target/expected["path"]
    assert file.is_file(),f"Missing installed file: {file.name}"
    assert hashlib.sha256(file.read_bytes()).hexdigest()==expected["sha256"],f"Hash mismatch: {file.name}"
    assert file.stat().st_size==expected["bytes"]
for file in sorted(target.rglob("*")):
    rel=file.relative_to(target).as_posix()
    records.append({"path":rel,"kind":"file" if file.is_file() else "directory","bytes":file.stat().st_size if file.is_file() else 0})
extras=[r["path"] for r in records if r["kind"]=="file" and r["path"] not in {x["path"] for x in manifest["files"]} and r["path"]!="data/package-manifest.json" and not r["path"].startswith("data/cache/")]
assert all(x.startswith("unins") for x in extras),f"Unexpected non-package files: {extras}"
for directory in ["data/profiles","data/logs","data/cache","scripts/user"]:
    assert (target/directory).is_dir(),directory
report={"status":"pass","installed_directory":str(target),"manifest_payload_files":len(manifest["files"])+1,"installer_added_files":extras,"all_payload_hashes_match":True,"entries":records}
(ROOT/"artifacts/installed-files-0.4.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
lines=["# 0.4.0 安装后文件清单","",f"实际安装目录：`{target}`","","全部发布文件与 manifest 的路径、大小和 SHA256 一致。以下为安装完成、应用首次运行前的实际目录。","","| 相对路径 | 类型 | 大小（字节） |","|---|---|---:|"]
lines.extend(f"| {r['path']} | {r['kind']} | {r['bytes']} |" for r in records)
(ROOT/"artifacts/安装后文件清单-0.4.md").write_text("\n".join(lines)+"\n",encoding="utf-8")
print(json.dumps({k:v for k,v in report.items() if k!="entries"},ensure_ascii=False))
