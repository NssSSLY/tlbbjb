"""Send Home/End only to our hash-checked fixture window; never a real game."""
from pathlib import Path
import ctypes as c
from ctypes import wintypes as w
import hashlib
import json
import os
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/".tools/pythonpkgs"))
import psutil
out=ROOT/"artifacts/native-hotkeys-0.3"
out.mkdir(parents=True,exist_ok=True)
exe=ROOT/"dist/TLBBClient-0.3.0/TLBB.exe"
fixture=ROOT/"artifacts/binding-fixtures-0.3"
game_exe=fixture/"Bin64/Game.exe"
assert (fixture/".owned-binding-fixture").is_file()
assert hashlib.sha256(game_exe.read_bytes()).digest()==hashlib.sha256((ROOT/".tools/build/client/TLBBFixture.exe").read_bytes()).digest()
u=c.WinDLL('user32',use_last_error=True)
k=c.WinDLL('kernel32',use_last_error=True)
u.GetForegroundWindow.restype=w.HWND
u.GetWindowThreadProcessId.argtypes=[w.HWND,c.POINTER(w.DWORD)];u.GetWindowThreadProcessId.restype=w.DWORD
u.SetForegroundWindow.argtypes=[w.HWND];u.ShowWindow.argtypes=[w.HWND,c.c_int]
u.AttachThreadInput.argtypes=[w.DWORD,w.DWORD,w.BOOL]
u.BringWindowToTop.argtypes=[w.HWND]
u.GetWindow.argtypes=[w.HWND,w.UINT];u.GetWindow.restype=w.HWND
u.PostMessageW.argtypes=[w.HWND,w.UINT,w.WPARAM,w.LPARAM]
u.GetClassNameW.argtypes=[w.HWND,w.LPWSTR,c.c_int]
u.IsWindowVisible.argtypes=[w.HWND]
callback_type=c.WINFUNCTYPE(w.BOOL,w.HWND,w.LPARAM)
u.EnumWindows.argtypes=[callback_type,w.LPARAM]
u.PeekMessageW.argtypes=[c.POINTER(w.MSG),w.HWND,w.UINT,w.UINT,w.UINT]

def windows(pid):
    found=[]
    @callback_type
    def callback(hwnd,_):
        value=w.DWORD();u.GetWindowThreadProcessId(hwnd,c.byref(value))
        if value.value==pid and u.IsWindowVisible(hwnd):found.append(hwnd)
        return True
    u.EnumWindows(callback,0)
    return found

def wait(predicate,seconds=6):
    start=time.monotonic()
    while time.monotonic()-start<seconds:
        if predicate():return True
        time.sleep(.05)
    return bool(predicate())

def press(hwnd,key):
    name=c.create_unicode_buffer(128);u.GetClassNameW(hwnd,name,128)
    assert name.value=='TLBBClientOwnedFixture','Refuse keyboard input to any non-fixture window'
    u.ShowWindow(hwnd,9)
    message=w.MSG();u.PeekMessageW(c.byref(message),None,0,0,0)
    front=u.GetForegroundWindow();thread=u.GetWindowThreadProcessId(front,None)
    own=k.GetCurrentThreadId()
    attached=thread!=own and u.AttachThreadInput(own,thread,True)
    try:u.BringWindowToTop(hwnd);u.SetForegroundWindow(hwnd)
    finally:
        if attached:u.AttachThreadInput(own,thread,False)
    assert wait(lambda:u.GetForegroundWindow()==hwnd,2),'Desktop denied focus; no keys were sent'
    time.sleep(.25)
    assert u.GetForegroundWindow()==hwnd
    u.keybd_event(key,0,0,0);u.keybd_event(key,0,2,0)

environment=os.environ.copy()
environment['PATH']=str(Path(os.environ['SystemRoot'])/'System32')+';'+os.environ['SystemRoot']
host=game=None
report={'scope':'physical Home/End on owned test window only','real_game_tested':False,'gameplay_actions_sent':0}
try:
    with (out/'stderr.log').open('wb') as err:
        host=subprocess.Popen([str(exe),'--game-root',str(fixture),'--data-root',str(out/'data'),'--diagnostics',str(out/'live.json')],env=environment,stdout=subprocess.DEVNULL,stderr=err,creationflags=subprocess.CREATE_NO_WINDOW)
        assert wait(lambda:bool(windows(host.pid))),'Launcher did not open'
        game=subprocess.Popen([str(game_exe)],creationflags=subprocess.CREATE_NO_WINDOW)
        assert wait(lambda:bool(windows(game.pid))),'Fixture did not open'
        hwnd=windows(game.pid)[0]
        def workers():
            try:return [p for p in psutil.Process(host.pid).children(recursive=True) if '--worker' in p.cmdline()]
            except psutil.Error:return []
        assert not workers(),'Unexpected prior binding'
        press(hwnd,0x24)
        assert wait(lambda:len(workers())==1),'Home did not create a Worker for the unbound foreground fixture'
        worker=workers()[0].pid
        assert wait(lambda:any(u.GetWindow(window,4)==hwnd for window in windows(host.pid))),'Game-owned panel did not open'
        press(hwnd,0x23)
        assert wait(lambda:not workers()),'End did not release the target Worker'
        assert game.poll() is None,'End closed the fixture game'
        report.update(status='pass',home_binds_previously_unbound=True,end_releases_worker=True,game_remains_running=True,physical_hotkeys_verified=True,worker_pid=worker,exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest())
except Exception as error:
    report.update(status='fail',failure=str(error),physical_hotkeys_verified=False)
    if (out/'live.json').exists():report['diagnostics']=json.loads((out/'live.json').read_text(encoding='utf-8-sig'))
finally:
    if game and game.poll() is None:
        for hwnd in windows(game.pid):u.PostMessageW(hwnd,0x10,0,0)
        try:game.wait(timeout=3)
        except subprocess.TimeoutExpired:game.terminate();game.wait()
    if host and host.poll() is None:
        # Only the process this verifier created, after the Worker was stopped.
        host.terminate();host.wait(timeout=3)
(out/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
if report['status']!='pass':raise SystemExit(1)
