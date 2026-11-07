"""Read static game UI resources only; never open Accounts, user profiles or processes."""
from pathlib import Path
import hashlib
import json
import re
import struct

ROOT=Path(__file__).resolve().parents[1]
GAME=ROOT.parent
OUT=ROOT/'artifacts/login-research'
OUT.mkdir(parents=True,exist_ok=True)
results=[]
for archive in ['Interface.axp','Config.axp']:
    file=GAME/'Data'/archive
    found=[];total=0
    before=file.stat()
    with file.open('rb') as f:
        header=f.read(40);values=struct.unpack('<10I',header)
        assert values[0]==0x4b505841 and values[5]<100000
        offset,count=values[4:6]
        f.seek(offset);index=f.read(count*12)
        for block,(at,size,flags) in enumerate(struct.iter_unpack('<3I',index)):
            if not flags&0x80000000 or not 0<size<2*1024*1024:continue
            assert at>=40 and at+size<=before.st_size
            f.seek(at);prefix=f.read(min(size,512))
            if not (prefix.startswith((b'--',b'<?xml',b'function ',b'local ',b'\xef\xbb\xbf')) or b'function ' in prefix):continue
            if total+size>192*1024*1024:break
            f.seek(at);data=f.read(size);total+=size
            try:text=data.decode('utf-8-sig')
            except UnicodeDecodeError:text=data.decode('gb18030',errors='replace')
            functions=re.findall(r'^\s*function\s+([\w.:]+)',text,re.M)
            relevant=[x for x in functions if re.search(r'(?i)(^Login|GameLogin|LogOn|SelectServer|ServerSelect|^ServerList|CharSelect|SelectChar|LoginQueue|LoginAccount|AccountLogin|SceneLogin|CreateChar)',x)]
            xml_login=text.startswith('<?xml') and bool(re.search(r'Name="(?:Login|GameLogin|LogOn|Select|ServerList|Char|Role)',text))
            if not relevant and not xml_login:continue
            name=f'{archive[:-4]}-block-{block}.txt'
            (OUT/name).write_text(text,encoding='utf-8')
            found.append({'block':block,'file':name,'bytes':size,'sha256':hashlib.sha256(data).hexdigest(),'functions':relevant[:40]})
    assert file.stat().st_mtime_ns==before.st_mtime_ns
    results.append({'archive':archive,'read_bytes':total,'matches':found})
strings={}
for rel in ['Bin64/Game.exe','Launch.exe']:
    data=(GAME/rel).read_bytes();values=[]
    for m in re.finditer(rb'[\x20-\x7e]{5,160}',data):
        s=m.group().decode('ascii')
        if re.search(r'(?i)(Login|Passport|Account|Password|ServerList|SelectServer|EnterWorld|SelectChar|ChooseChar)',s):
            values.append(s)
    strings[rel]=values[:500]
(OUT/'static-login.json').write_text(json.dumps({'archives':results,'binary_strings':strings},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'archives':[{'archive':a['archive'],'matches':[{'block':m['block'],'functions':m['functions'][:6]} for m in a['matches']]} for a in results],'binary_string_counts':{k:len(v) for k,v in strings.items()}},ensure_ascii=False))
