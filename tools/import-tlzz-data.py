"""Convert audited public coordinate tables/presets to inert UTF-8 reference data."""
from pathlib import Path
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
SOURCE=ROOT/'满天星/天龙助手'
audit=json.loads((ROOT/'artifacts/reference-tlzz/analysis.json').read_text(encoding='utf-8'))
inventory={e['path']:e for e in audit['inventory']}
routes=[]
for pattern in ('data/坐标/*.txt','data/模版/*.json'):
    for file in sorted(SOURCE.glob(pattern)):
        relative=file.relative_to(SOURCE).as_posix();raw=file.read_bytes()
        digest=hashlib.sha256(raw).hexdigest();assert digest==inventory[relative]['sha256']
        for encoding in ('utf-8-sig','gb18030'):
            try:text=raw.decode(encoding);break
            except UnicodeError:pass
        else:raise ValueError(relative)
        points=[];extra={}
        if file.suffix=='.txt':
            hint=re.sub(r'^\d+(?:-\d+)?级','',file.stem)
            for number,line in enumerate(text.splitlines(),1):
                if not line.strip():continue
                m=re.fullmatch(r'\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*',line);assert m,relative
                points.append({'x':float(m[1]),'y':float(m[2]),'source_line':number})
        else:
            p=json.loads(text);assert set(p)<=set(['sceneName','sceneID','x','y','r'])
            hint=p['sceneName'];assert isinstance(hint,str) and hint
            assert isinstance(p['sceneID'],int) and 0<=p['sceneID']<=1000000
            points=[{'x':p['x'],'y':p['y'],'source_line':1}]
            extra={'scene_id_hint':p['sceneID'],'radius_hint':p['r']}
        assert 1<=len(points)<=2048
        for p in points:assert all(isinstance(p[k],(int,float)) and not isinstance(p[k],bool) and 0<=p[k]<=10000 for k in ['x','y'])
        routes.append({'id':'tlzz-'+hashlib.sha256(relative.encode()).hexdigest()[:16],
            'name':file.stem,'map':None,'map_hint':hint,'purpose':'unclassified',
            'verified':False,'runtime_enabled':False,'source':{'pack':'tlzz','path':relative,'sha256':digest,'encoding':encoding},
            'points':points,**extra})
assert len(routes)==72
result={'schema':1,'id':'tlzz-reference-routes','runtime_enabled':False,'routes':routes}
out=ROOT/'scripts/data/tlzz_reference_routes.json';out.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
assert out.stat().st_size<=512*1024
report={'route_count':len(routes),'point_count':sum(len(e['points']) for e in routes),'source_unchanged':True,'runtime_enabled':False,'dataset_sha256':hashlib.sha256(out.read_bytes()).hexdigest()}
(ROOT/'artifacts/reference-tlzz/imported-data.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
