"""Static PE RIP-relative references to selected, observed Lua registration names."""
from pathlib import Path
import json
import re
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
login = '--login' in sys.argv
mount = '--mount' in sys.argv
team = '--team' in sys.argv
OUT = ROOT/'artifacts'/('emei-2026-10-29/native' if team else 'sanhuan-2026-10-28/mount' if mount else 'login-research' if login else 'adapter-research')
OUT.mkdir(parents=True,exist_ok=True)
data = (ROOT.parent/'Bin64'/'Game.exe').read_bytes()
pe = struct.unpack_from('<I',data,0x3c)[0]
optional = pe+24
base = struct.unpack_from('<Q',data,optional+24)[0]
section_table = optional+struct.unpack_from('<H',data,pe+20)[0]
sections = []
for i in range(struct.unpack_from('<H',data,pe+6)[0]):
    at = section_table+i*40
    vs,rva,size,raw = struct.unpack_from('<IIII',data,at+8)
    sections.append(dict(name=data[at:at+8].rstrip(b'\0').decode(),rva=rva,size=size,raw=raw,virtual=vs))

def rva_of(at):
    for s in sections:
        if s['raw']<=at<s['raw']+s['size']:
            return s['rva']+at-s['raw']

anchors=[]
for name in (['GetTeamMemInfoExByIndex','GetTeamMemberObjIDNamePortInfo','GetTeamMemSandBoxHPInfo','GetTeamMemGUIDByUIIndex','IsTeamMemberInScene'] if team else ['GetBuffNumber','GetBuffToolTipsByIndex','DispelBuffByIndex','GetMountID'] if mount else ['GetServerAreaName','GetAreaLoginServerInfo','SelectLoginServer'] if login else ['GetMyPos','GetCurrentSceneName','AutoRunToTargetEx','AutoRunToTarget','GetSceneID']):
    needle=name.encode()+b'\0'
    for m in re.finditer(re.escape(needle),data):
        if m.start() and data[m.start()-1] != 0:
            continue
        anchors.append(dict(name=name,offset=m.start(),rva=rva_of(m.start()),references=[],pointer_references=[]))
targets={a['rva']:a for a in anchors}
for s in sections:
    if s['name'] != '.text':
        continue
    for at in range(s['raw'],s['raw']+s['size']-7):
        if data[at] not in (0x48,0x4c) or data[at+1] != 0x8d or data[at+2]&0xc7 != 5:
            continue
        current=rva_of(at)
        target=current+7+struct.unpack_from('<i',data,at+3)[0]
        if target in targets:
            targets[target]['references'].append(dict(file_offset=at,rva=current))
for a in anchors:
    for m in re.finditer(re.escape(struct.pack('<Q',base+a['rva'])),data):
        a['pointer_references'].append(dict(file_offset=m.start(),rva=rva_of(m.start()),
                                           surrounding=data[max(0,m.start()-16):m.start()+32].hex()))
objdump=ROOT/'.tools'/'Qt'/'Tools'/'mingw1310_64'/'bin'/'objdump.exe'
parts=[]
for a in anchors:
    for ref in a['references'][:8]:
        start=base+ref['rva']-40
        end=base+ref['rva']+140
        result=subprocess.run([str(objdump),'-d','-M','intel',f'--start-address={start}',
                               f'--stop-address={end}',str(ROOT.parent/'Bin64'/'Game.exe')],
                              capture_output=True,timeout=15,check=True)
        parts.append(f"\n### {a['name']} string_rva={a['rva']:#x} reference_rva={ref['rva']:#x}\n"+
                     result.stdout.decode(errors='replace'))
(OUT/'native-xrefs.json').write_text(json.dumps(dict(base=hex(base),anchors=anchors),indent=2),encoding='utf-8')
(OUT/'native-xrefs.txt').write_text(''.join(parts),encoding='utf-8')
print(json.dumps(dict(base=hex(base),anchors=anchors),indent=2))
