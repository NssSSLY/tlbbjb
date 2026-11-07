"""Read-only, hash/path locked object-manager ABI probe; never writes a process."""
from pathlib import Path
import ctypes as C, struct, hashlib, json, argparse
from ctypes import wintypes as W
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--pid',type=int,required=True);a=p.parse_args()
game=ROOT.parent/'Bin64/Game.exe'
assert hashlib.sha256(game.read_bytes()).hexdigest()=='72f4898ee04d2e8a6d94ff6d45cdc183dfa655eae40c31ddc67dcc2099d9c00d'
k=C.WinDLL('kernel32',use_last_error=True);ps=C.WinDLL('psapi',use_last_error=True)
k.OpenProcess.argtypes=[W.DWORD,W.BOOL,W.DWORD];k.OpenProcess.restype=W.HANDLE
k.CloseHandle.argtypes=[W.HANDLE]
k.QueryFullProcessImageNameW.argtypes=[W.HANDLE,W.DWORD,W.LPWSTR,C.POINTER(W.DWORD)]
ps.EnumProcessModulesEx.argtypes=[W.HANDLE,C.POINTER(C.c_void_p),W.DWORD,C.POINTER(W.DWORD),W.DWORD]
k.ReadProcessMemory.argtypes=[W.HANDLE,C.c_void_p,C.c_void_p,C.c_size_t,C.POINTER(C.c_size_t)]
h=k.OpenProcess(0x410,False,a.pid);assert h
try:
    path=C.create_unicode_buffer(32768);n=W.DWORD(len(path));assert k.QueryFullProcessImageNameW(h,0,path,C.byref(n)) and Path(path.value).resolve()==game.resolve()
    ms=(C.c_void_p*1024)();n=W.DWORD();assert ps.EnumProcessModulesEx(h,ms,C.sizeof(ms),C.byref(n),3);base=ms[0]
    total=0
    def read(at,size):
        global total
        assert 0x10000<=at<0x7fffffffffff and 0<size<=4096 and total+size<=16384
        b=C.create_string_buffer(size);got=C.c_size_t();assert k.ReadProcessMemory(h,at,b,size,C.byref(got)) and got.value==size
        total+=size;return b.raw
    def ptr(at):return struct.unpack('<Q',read(at,8))[0]
    manager=ptr(base+0x105ca30);vtable=ptr(manager)
    out=dict(pid=a.pid,manager_head=read(manager,0x110).hex(),vtable_rva=hex(vtable-base),functions={hex(i):hex(ptr(vtable+i)-base) for i in range(0,0xb8,8)},bytes_read=total,game_actions_issued=0)
    (ROOT/'artifacts/combat-research/object-manager.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
    print(json.dumps({key:val for key,val in out.items() if key!='manager_head'}))
finally:k.CloseHandle(h)
