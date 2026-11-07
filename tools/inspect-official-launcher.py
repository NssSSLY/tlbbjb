"""Extract only public launcher skin metadata from its PE ZIP resource. No UI/process actions."""
from pathlib import Path
import hashlib,io,json,struct,zipfile,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
file=ROOT.parent/'Launch.exe';data=file.read_bytes()
pe=struct.unpack_from('<I',data,0x3c)[0];optional=pe+24
directory=optional+(112 if struct.unpack_from('<H',data,optional)[0]==0x20b else 96)
sections=[]
for i in range(struct.unpack_from('<H',data,pe+6)[0]):
    at=optional+struct.unpack_from('<H',data,pe+20)[0]+i*40
    _,rva,size,raw=struct.unpack_from('<IIII',data,at+8);sections.append((rva,size,raw))
def offset(rva):
    for va,size,raw in sections:
        if va<=rva<va+size:return raw+rva-va
    raise ValueError('Unmapped resource')
base=offset(struct.unpack_from('<I',data,directory+16)[0]);resources=[]
def walk(relative,path):
    at=base+relative;named,ids=struct.unpack_from('<HH',data,at+12)
    for i in range(named+ids):
        name,target=struct.unpack_from('<II',data,at+16+8*i)
        if name&0x80000000:
            ptr=base+(name&0x7fffffff);length=struct.unpack_from('<H',data,ptr)[0];name=data[ptr+2:ptr+2+length*2].decode('utf-16-le')
        if target&0x80000000:walk(target&0x7fffffff,path+[name])
        else:
            rva,size,_,_=struct.unpack_from('<IIII',data,base+target)
            if path[0]=='ZIP':resources.append(data[offset(rva):offset(rva)+size])
walk(0,[])
assert len(resources)==1
def text(raw):
    for encoding in ('utf-8-sig','gb18030'):
        try:return raw.decode(encoding)
        except UnicodeError:pass
    raise ValueError('Unknown XML encoding')
result={'sha256':hashlib.sha256(data).hexdigest(),'skins':[]}
with zipfile.ZipFile(io.BytesIO(resources[0])) as archive:
    assert len(archive.infolist())<2000
    names={}
    for info in archive.infolist():
        name=info.filename
        if not info.flag_bits&0x800:
            try:name=name.encode('cp437').decode('gb18030')
            except UnicodeError:pass
        names[name]=info.filename
    def size(name):
        raw=archive.read(names[name]);assert raw.startswith(b'\x89PNG')
        return list(struct.unpack('>II',raw[16:24]))
    for name in ('main.xml','staticmain.xml','wegamemain.xml'):
        root=ET.fromstring(text(archive.read(names[name])))
        start=next(e for e in root if e.get('key')=='start')
        image=start.get('normal');candidates=[n for n in names if n==image or n==image+'000.png']
        result['skins'].append({'file':name,'background':root.get('bkg'),'background_size':size(root.get('bkg')),
                                'start_attributes':start.attrib,'start_image_candidates':candidates,
                                'start_image_size':size(candidates[0]) if candidates else None})
out=ROOT/'artifacts/launcher-research';out.mkdir(parents=True,exist_ok=True)
(out/'skin-profile.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,ensure_ascii=False))
