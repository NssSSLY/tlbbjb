"""Verify the packaged native app without developer PATH or real game interaction."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import uuid

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/".tools/pythonpkgs"))
import psutil
exe=Path(sys.argv[1]) if len(sys.argv)>1 else ROOT/"dist/TLBBClient-0.15.0/TLBB.exe"
out=ROOT/"artifacts/native-ui-0.15.0"
out.mkdir(parents=True,exist_ok=True)
fixture=ROOT/"artifacts/binding-fixtures-0.15.0"
(fixture/"Bin64").mkdir(parents=True,exist_ok=True)
owned=ROOT/".tools/build/client-0.15.0/TLBBFixture.exe"
shutil.copy2(owned,fixture/"Bin64/Game.exe")
shutil.copy2(owned,fixture/"Launch.exe")
shutil.copy2(owned,fixture/"Launch.bin")
(fixture/".owned-binding-fixture").write_text("TLBBClient-owned-window-fixture",encoding="ascii")
env=os.environ.copy()
project_temp=ROOT/".tools/temp"
project_temp.mkdir(parents=True,exist_ok=True)
env["TEMP"]=env["TMP"]=str(project_temp)
env["PATH"]=os.pathsep.join([str(Path(os.environ["SystemRoot"])/"System32"),os.environ["SystemRoot"]])
env.pop("QT_PLUGIN_PATH",None)
env.pop("QT_QPA_PLATFORM_PLUGIN_PATH",None)

def run(args,timeout=45):
    result=subprocess.run([str(exe),*map(str,args)],env=env,capture_output=True,timeout=timeout,creationflags=subprocess.CREATE_NO_WINDOW)
    if result.returncode:
        raise RuntimeError(f"Native client exited {result.returncode}: "+result.stderr.decode(errors="replace")[:800])
    return result

run(["--assets-report",out/"assets.json"])
assets=json.loads((out/"assets.json").read_text(encoding="utf-8"))
assert assets["loose_scripts"] and not assets["mounted"]
# Loose rule files must equal the project's sources.
stage=exe.parent
assets["files"]=[]
for path in sorted((ROOT/"scripts").rglob("*")):
    rel=path.relative_to(ROOT/"scripts").as_posix()
    if not path.is_file() or rel.startswith("user/") or "__pycache__" in rel or (rel.startswith("original-library/") and rel.endswith(".bin")):continue
    packed=stage/"scripts/builtin"/rel
    digest=hashlib.sha256(path.read_bytes()).hexdigest()
    assert packed.is_file() and hashlib.sha256(packed.read_bytes()).hexdigest()==digest,rel
    assets["files"].append({"path":"scripts/builtin/"+rel,"bytes":path.stat().st_size,"sha256":digest})
catalog=ROOT/"design/task-catalog.json"
assert (stage/"scripts/tasks/catalog.json").read_bytes()==catalog.read_bytes()
assets["files"].append({"path":"tasks/catalog.json","bytes":catalog.stat().st_size,"sha256":hashlib.sha256(catalog.read_bytes()).hexdigest()})
# The full self-tests read the built-in resource bundle, which only the development executable mounts.
core_exe=ROOT/".tools/build/client-0.15.0/TLBB.exe"
result=subprocess.run([str(core_exe),"--self-test",str(ROOT),str(out/"core-tests.json")],capture_output=True,timeout=400,creationflags=subprocess.CREATE_NO_WINDOW)
assert result.returncode==0,"Core self-tests failed"
run(["--login-self-test","--project-root",ROOT,"--report",out/"login-tests.json"])
# An earlier run leaves a deliberately protected fixture account on disk. Each run
# needs its own fake data directory so that account cannot affect a later launch test.
data_root=out/("owned-data-"+uuid.uuid4().hex[:12])
assert data_root.resolve().is_relative_to(ROOT.resolve()) and not data_root.exists()
args=[str(exe),"--ui-self-test","--fixture-root",str(fixture),"--game-root",str(fixture),"--data-root",str(data_root),"--report",str(out/"verification.json")]
samples=[]
with (out/"stderr.log").open("wb") as err:
    process=subprocess.Popen(args,env=env,stdout=subprocess.DEVNULL,stderr=err,creationflags=subprocess.CREATE_NO_WINDOW)
    start=time.monotonic()
    while process.poll() is None:
        if time.monotonic()-start>50:
            process.terminate()
            raise RuntimeError("Native binding verification timed out")
        try:
            p=psutil.Process(process.pid)
            memory=p.memory_info()
            children=p.children(recursive=True)
            samples.append({"seconds":round(time.monotonic()-start,2),"host_working_set":memory.rss,"host_private":getattr(memory,"private",memory.vms),"child_count":len(children),"host_handles":p.num_handles()})
        except psutil.Error:
            pass
        time.sleep(.1)
    assert process.returncode==0,f"Native UI process crashed after tests: {process.returncode}"
native=json.loads((out/"verification.json").read_text(encoding="utf-8-sig"))
core=json.loads((out/"core-tests.json").read_text(encoding="utf-8-sig"))
login=json.loads((out/"login-tests.json").read_text(encoding="utf-8-sig"))
assert native["passed"] and native["remaining_sessions"]==0
assert core["status"]=="pass"
assert login["status"]=="pass"
run(["--ui-smoke",out/"launcher-native.png","--data-root",out/"smoke-data","--report",out/"launcher-smoke.json"])
report={"status":"pass","exe":str(exe),"sha256":hashlib.sha256(exe.read_bytes()).hexdigest(),"developer_path_removed":True,"core_test_count":core["passed_count"],"native_ui_check_count":len(native["checks"]),"native_ui_process_exit":process.returncode,"native_hotkeys_verified_on_owned_fixtures":native["native_hotkey_input_verified_on_owned_fixtures"],"real_game_tested":False,"gameplay_actions_sent":0,"host_working_set_peak":max(s["host_working_set"] for s in samples),"host_private_peak":max(s["host_private"] for s in samples),"sampling_duration_seconds":samples[-1]["seconds"],"long_duration_performance_tested":False}
report["engine_sha256"]=hashlib.sha256((exe.parent/"TLBBEngine.dll").read_bytes()).hexdigest()
report["runtime_sha256"]=hashlib.sha256((exe.parent/"TLBBRuntime.dll").read_bytes()).hexdigest()
report["resident_fixture"]=json.loads((ROOT/"artifacts/resident-benchmark-0.15.0.json").read_text(encoding="utf-8"))
report["resident_engine_live_tested"]=False
report["resources"]=assets
(out/"resource-samples.json").write_text(json.dumps(samples,indent=2)+"\n",encoding="utf-8")
(ROOT/"artifacts/release-verification-0.15.0.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print(json.dumps(report,ensure_ascii=False))
