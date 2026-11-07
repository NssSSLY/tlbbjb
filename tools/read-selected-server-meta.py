"""Read only public server-selection numeric fields from the verified local game."""
from pathlib import Path
import ctypes as c,ctypes.wintypes as w,hashlib,json,struct,sys
ROOT=Path(__file__).resolve().parents[1]
k=c.WinDLL('kernel32',use_last_error=True);p=c.WinDLL('psapi',use_last_error=True)
k.OpenProcess.argtypes=[w.DWORD,w.BOOL,w.DWORD];k.OpenProcess.restype=w.HANDLE
k.ReadProcessMemory.argtypes=[w.HANDLE,c.c_void_p,c.c_void_p,c.c_size_t,c.POINTER(c.c_size_t)]
k.QueryFullProcessImageNameW.argtypes=[w.HANDLE,w.DWORD,w.LPWSTR,c.POINTER(w.DWORD)]
k.CloseHandle.argtypes=[w.HANDLE]
p.EnumProcessModules.argtypes=[w.HANDLE,c.POINTER(c.c_void_p),w.DWORD,c.POINTER(w.DWORD)]
pid=int(sys.argv[1]);h=k.OpenProcess(0x410,False,pid);assert h
try:
 path=c.create_unicode_buffer(32768);length=w.DWORD(len(path));assert k.QueryFullProcessImageNameW(h,0,path,c.byref(length))
 assert Path(path.value).resolve()==(ROOT.parent/'Bin64/Game.exe').resolve()
 assert hashlib.sha256(Path(path.value).read_bytes()).hexdigest()=='72f4898ee04d2e8a6d94ff6d45cdc183dfa655eae40c31ddc67dcc2099d9c00d'
 base=c.c_void_p();need=w.DWORD();assert p.EnumProcessModules(h,c.byref(base),8,c.byref(need))
 def read(at,size):
  assert 0x10000<=at<0x7fffffffffff and size<=128
  data=c.create_string_buffer(size);actual=c.c_size_t();assert k.ReadProcessMemory(h,at,data,size,c.byref(actual)) and actual.value==size
  return data.raw
 def q(at):return struct.unpack('<Q',read(at,8))[0]
 def i(at):return struct.unpack('<i',read(at,4))[0]
 def nil(at):return read(at+25,1)!=b'\0'
 if '--lua-owner' in sys.argv:
  obj=q(base.value+0x1056970);owner=q(obj+16);native=q(owner)
  print(json.dumps({'object':hex(obj),'owner':hex(owner),'native':hex(native),'object_tag':i(obj+24),'native_words':{hex(x):hex(q(native+x)) for x in (0,8,16,24,32,40)}}));sys.exit(0)
 manager=q(base.value+0x105d568);a,s,t=[i(manager+x) for x in (0x60,0x64,0x68)]
 begin,end=q(manager+8),q(manager+16);assert 0<=a<(end-begin)//96<=128
 area=begin+a*96;count=i(area+0x58);assert 0<=s<count<=1024
 head=q(area+0x50);node=q(head)
 for _ in range(s):
  right=q(node+16)
  if not nil(right):
   node=right
   for _ in range(1024):
    left=q(node)
    if nil(left):break
    node=left
   else:raise ValueError('invalid tree')
  else:
   parent=q(node+8)
   for _ in range(1024):
    if nil(parent) or node!=q(parent+16):break
    node=parent;parent=q(parent+8)
   else:raise ValueError('invalid tree')
   node=parent
  assert node!=head
 entry=node+32
 print(json.dumps({'pid':pid,'area_index':a,'server_index':s,'selected_type':t,'catalog_fields':{hex(x):i(entry+x) for x in (0x30,0x34,0x38,0x3c)}}))
finally:k.CloseHandle(h)
