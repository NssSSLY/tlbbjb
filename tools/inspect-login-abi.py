"""Bounded static export disassembly for the local login adapter. No process access."""
from pathlib import Path
import struct, subprocess, re, sys
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/login-research'
obj=ROOT/'.tools/Qt/Tools/mingw1310_64/bin/objdump.exe'
dll='LuaPlus.dll' if '--lua' in sys.argv else 'CEGUIBase.dll'
data=(ROOT.parent/'Bin64'/dll).read_bytes()
pe=struct.unpack_from('<I',data,0x3c)[0];opt=pe+24
base=struct.unpack_from('<Q',data,opt+24)[0]
sections=[]
for i in range(struct.unpack_from('<H',data,pe+6)[0]):
 p=opt+struct.unpack_from('<H',data,pe+20)[0]+40*i
 vs,rva,size,raw=struct.unpack_from('<IIII',data,p+8);sections.append((rva,size,raw))
def off(r):
 for va,size,raw in sections:
  if va<=r<va+size:return raw+r-va
 raise ValueError(hex(r))
e=off(struct.unpack_from('<I',data,opt+112)[0])
_,_,_,_,_,_,_,count,funcs,names,ords=struct.unpack_from('<IIHHIIIIIII',data,e)
selected=[]
patterns=['isWindowPresent','getWindow@WindowManager','??0String32@CEGUI@@QEAA@PEBD@','??1String32','getSingletonPtr@WindowManager','onClicked@PushButton','getText@Window','isVisible@Window','executeScript','getScriptModule','??0WindowEventArgs','setText@Window']
if '--lua' in sys.argv:patterns=['CreateThread@LuaState','Destroy@LuaState','??0LuaState@LuaPlus@@IEAA@PEAV','??1LuaState@LuaPlus','Ref@LuaState','lua_ref','lua_newthread']
for i in range(count):
 n=off(struct.unpack_from('<I',data,off(names)+i*4)[0]);end=data.index(b'\0',n);name=data[n:end].decode()
 if not any(p in name for p in patterns):continue
 ordinal=struct.unpack_from('<H',data,off(ords)+i*2)[0]
 rva=struct.unpack_from('<I',data,off(funcs)+ordinal*4)[0]
 selected.append((name,rva))
parts=[]
for name,rva in selected:
 result=subprocess.run([str(obj),'-d','-M','intel',f'--start-address={base+rva}',f'--stop-address={base+rva+160}',str(ROOT.parent/'Bin64'/dll)],capture_output=True,check=True)
 parts.append(f'### {name} {rva:#x}\n'+result.stdout.decode(errors='replace'))
(OUT/('lua-abi.txt' if '--lua' in sys.argv else 'cegui-abi.txt')).write_text('\n'.join(parts),encoding='utf-8')
print('\n'.join(f'{name} {rva:#x}' for name,rva in selected))
