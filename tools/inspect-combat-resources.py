"""Read-only primary-source combat API evidence; no game process access."""
from pathlib import Path
import hashlib, json, re, struct, subprocess
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/combat-research'; OUT.mkdir(parents=True,exist_ok=True)
file=ROOT.parent/'Data/Interface.axp'
matches=[]
terms=re.compile(r'Target:|Player:.*(?:Skill|Target)|GetTargetInfo|GetHPPercent|SelectTargetOfTarget|GetBattleSkillData|SelectAsTargetByObjID|EnumAction\([^\n]*["\'](?:skill|auto)|AutoFight|AutoAttack|AutoBattle|StopAction')
with file.open('rb') as f:
    values=struct.unpack('<10I',f.read(40)); f.seek(values[4]); index=f.read(values[5]*12)
    for block,(at,size,flags) in enumerate(struct.iter_unpack('<3I',index)):
        if not flags&0x80000000 or not 0<size<2*1024*1024: continue
        f.seek(at); data=f.read(size)
        if not re.search(rb'Target:|Player:|GetTargetInfo|GetHPPercent|SelectTargetOfTarget|GetBattleSkillData|SelectAsTargetByObjID|AutoFight|AutoAttack|AutoBattle|StopAction|EnumAction',data):continue
        try: text=data.decode('utf-8-sig')
        except UnicodeDecodeError:text=data.decode('gb18030',errors='replace')
        lines=text.splitlines(); hits=[i for i,line in enumerate(lines) if terms.search(line)]
        if not hits:continue
        (OUT/f'interface-{block}.txt').write_text(text,encoding='utf-8')
        matches.append(dict(block=block,sha256=hashlib.sha256(data).hexdigest(),hits=[dict(line=i+1,text=lines[i].strip()) for i in hits]))
(OUT/'ui-matches.json').write_text(json.dumps(matches,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(dict(files=len(matches),hits=sum(len(m['hits']) for m in matches),report=str(OUT/'ui-matches.json')),ensure_ascii=False))
