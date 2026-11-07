"""Exercise the bridge exclusively against a process created by this test."""
from pathlib import Path
import ctypes as C
import json
import os
import subprocess
import time

ROOT=Path(__file__).resolve().parents[1]
EXE=ROOT/'.tools/build/client/TLBB.exe'
OUT=ROOT/'artifacts/adapter-research'
env=os.environ.copy()
fixture=subprocess.Popen([str(EXE),'--bridge-fixture'],env=env,
                         creationflags=subprocess.CREATE_NO_WINDOW)
records=[]
try:
    time.sleep(0.4)
    cases=[('own_thread_probe',['--native-probe'],True),
           ('fixture_move_refused',['--native-move','--x','1','--y','1'],False),
           ('wrong_process_identity_refused',['--native-probe','--created','1'],False)]
    for name,options,success in cases:
        file=OUT/f'test-{name}.json'
        result=subprocess.run([str(EXE),*options,'--target-pid',str(fixture.pid),
                               '--bridge-test-target','--report',str(file)],env=env,
                              timeout=10,creationflags=subprocess.CREATE_NO_WINDOW)
        report=json.loads(file.read_text(encoding='utf-8'))
        assert report['success']==success,(name,report)
        assert report['game_actions_issued']==0,(name,report)
        assert (result.returncode==0)==success,(name,result.returncode)
        if success:
            assert report['target_thread']==report['executed_thread']!=0
        records.append(dict(name=name,status='pass',report=report))
    assert fixture.poll() is None,'Bridge changed fixture lifecycle'
finally:
    if fixture.poll() is None:
        thread=records[0]['report']['target_thread'] if records else None
        if thread:
            user=C.WinDLL('user32',use_last_error=True)
            user.PostThreadMessageW.argtypes=[C.c_ulong,C.c_uint,C.c_size_t,C.c_ssize_t]
            user.PostThreadMessageW(thread,0x12,0,0)
        try:fixture.wait(timeout=3)
        except subprocess.TimeoutExpired:
            fixture.kill();fixture.wait(timeout=3)
    assert fixture.poll() is not None
report=dict(status='pass',fixture_pid=fixture.pid,fixture_exited=True,
            scope='Owned fixture only; no game hook or action',checks=records)
(OUT/'bridge-owned-test.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
