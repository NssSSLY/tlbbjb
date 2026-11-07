"""Version-locked, small read-only probe of statically identified world interface.

Does not scan heaps, execute remote code, allocate/write remote memory, or issue input.
"""
from pathlib import Path
import argparse
import ctypes as C
from ctypes import wintypes as W
import datetime as dt
import hashlib
import json
import struct

ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--pid',required=True,type=int)
args=parser.parse_args()
static=json.loads((ROOT/'artifacts/adapter-research/static-candidates.json').read_text(encoding='utf-8'))
expected=static['modules'][0]['sha256']
game=(ROOT.parent/'Bin64/Game.exe').resolve()
if hashlib.sha256(game.read_bytes()).hexdigest()!=expected:
    raise SystemExit('Game version changed; probe refused')
k=C.WinDLL('kernel32',use_last_error=True)
p=C.WinDLL('psapi',use_last_error=True)
k.OpenProcess.argtypes=[W.DWORD,W.BOOL,W.DWORD];k.OpenProcess.restype=W.HANDLE
k.CloseHandle.argtypes=[W.HANDLE];k.CloseHandle.restype=W.BOOL
k.ReadProcessMemory.argtypes=[W.HANDLE,C.c_void_p,C.c_void_p,C.c_size_t,C.POINTER(C.c_size_t)]
k.ReadProcessMemory.restype=W.BOOL
k.QueryFullProcessImageNameW.argtypes=[W.HANDLE,W.DWORD,W.LPWSTR,C.POINTER(W.DWORD)]
k.QueryFullProcessImageNameW.restype=W.BOOL
p.EnumProcessModulesEx.argtypes=[W.HANDLE,C.POINTER(C.c_void_p),W.DWORD,C.POINTER(W.DWORD),W.DWORD]
p.EnumProcessModulesEx.restype=W.BOOL
k.GetProcessTimes.argtypes=[W.HANDLE,C.POINTER(W.FILETIME),C.POINTER(W.FILETIME),C.POINTER(W.FILETIME),C.POINTER(W.FILETIME)]
k.GetProcessTimes.restype=W.BOOL
handle=k.OpenProcess(0x410,False,args.pid)
if not handle:
    raise C.WinError(C.get_last_error())
reads=0
try:
    path=C.create_unicode_buffer(32768); length=W.DWORD(len(path))
    if not k.QueryFullProcessImageNameW(handle,0,path,C.byref(length)):
        raise C.WinError(C.get_last_error())
    if Path(path.value).resolve()!=game:
        raise SystemExit('Unexpected target path')
    times=[W.FILETIME() for _ in range(4)]
    if not k.GetProcessTimes(handle,*[C.byref(x) for x in times]):
        raise C.WinError(C.get_last_error())
    token=(times[0].dwHighDateTime<<32)|times[0].dwLowDateTime
    modules=(C.c_void_p*1024)(); needed=W.DWORD()
    if not p.EnumProcessModulesEx(handle,modules,C.sizeof(modules),C.byref(needed),3):
        raise C.WinError(C.get_last_error())
    base=modules[0]
    def read(address,size):
        global reads
        if not 0x10000<=address<0x7fffffffffff or not 0<size<=8192:
            raise ValueError('Address/read bounds refused')
        buffer=C.create_string_buffer(size); actual=C.c_size_t()
        if not k.ReadProcessMemory(handle,address,buffer,size,C.byref(actual)) or actual.value!=size:
            raise C.WinError(C.get_last_error())
        reads+=size
        if reads>128*1024:
            raise ValueError('Probe byte budget exceeded')
        return buffer.raw
    def ptr(address): return struct.unpack('<Q',read(address,8))[0]
    world=ptr(base+0x105fbc8)
    vtable=ptr(world)
    funcs={hex(offset):ptr(vtable+offset) for offset in [0x80,0x110,0x118]}
    object_system=ptr(base+0x105ca30)
    player=ptr(object_system+0x108)
    coordinates=struct.unpack('<3f',read(player+0x4c,12))
    scene=ptr(world+0x127c8)
    scene_vtable=ptr(scene)
    scene_functions={hex(offset):ptr(scene_vtable+offset) for offset in [0,8,0x30]}
    scene_data=ptr(scene+0x18)
    scene_id=struct.unpack('<i',read(scene_data,4))[0]
    scene_string=scene+0xe0
    name_length,name_capacity=struct.unpack('<QQ',read(scene_string+0x10,16))
    if name_length>128:
        raise ValueError('Scene name length exceeds probe limit')
    name_address=ptr(scene_string) if name_capacity>=16 else scene_string
    scene_name=read(name_address,max(1,name_length)).rstrip(b'\0').decode('gb18030',errors='replace')
    input_system=ptr(base+0x105d608)
    input_vtable=ptr(input_system)
    move_function=ptr(input_vtable+0xa8)
    info=dict(captured_at=dt.datetime.now(dt.timezone(dt.timedelta(hours=8))).isoformat(),
              pid=args.pid,created_token=str(token),path=path.value,sha256=expected,
              module_base=hex(base),world=hex(world),vtable=hex(vtable),
              virtual_functions={key:dict(address=hex(value),rva=hex(value-base),
                                           bytes=read(value,96).hex()) for key,value in funcs.items()},
              object_system=hex(object_system),player=hex(player),
              candidate_position_xyz=list(coordinates),scene=hex(scene),
              scene_id=scene_id,scene_name=scene_name,input_system=hex(input_system),
              move_function=dict(address=hex(move_function),rva=hex(move_function-base),
                                 bytes=read(move_function,128).hex()),
              scene_head=read(scene,96).hex(),
              scene_virtual_functions={key:dict(address=hex(value),rva=hex(value-base),
                                                bytes=read(value,48).hex()) for key,value in scene_functions.items()},
              bytes_read=reads,game_actions_issued=0,position_validated=False)
    out=ROOT/'artifacts/adapter-research/world-probe.json'
    out.write_text(json.dumps(info,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(info,ensure_ascii=False,indent=2))
finally:
    k.CloseHandle(handle)
