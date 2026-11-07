"""Inspect and transcode trusted Lua 5.4 rules without executing the vendor DLL.

Only string encodings/lengths change. Instructions, constants' numeric bytes,
upvalue layouts and control flow are retained and checked after transcoding.
"""
from pathlib import Path
import hashlib,importlib.util,json,struct,argparse

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('undump',ROOT/'tools/inspect-lua54-chunks.py')
undump=importlib.util.module_from_spec(spec);spec.loader.exec_module(undump)
OUT=ROOT/'artifacts/original-combat-0.12.0'

def sha(data):return hashlib.sha256(data).hexdigest()
def size(n):
    parts=[n&127];n>>=7
    while n:parts.append(n&127);n>>=7
    parts.reverse();parts[-1]|=128;return bytes(parts)

class Recorded(undump.Chunk):
    def __init__(self,data):super().__init__(data,0);self.strings=[];self.spans={}
    def string(self):
        start=self.at;n=self.size()
        if not n:return None
        raw=self.take(n-1);text=raw.decode('gb18030');self.strings.append((start,self.at,text))
        return text
    def proto(self,parent=None,depth=0):
        start=self.at;p=super().proto(parent,depth);self.spans[id(p)]=(start,self.at);return p
    def transcode(self,p):
        start,end=self.spans[id(p)];result=self.data[start:end]
        for a,b,text in reversed(self.strings):
            if start<=a<b<=end:
                encoded=text.encode('utf-8');result=result[:a-start]+size(len(encoded)+1)+encoded+result[b-start:]
        return self.data[:31]+bytes([len(p['upvalues'])])+result

def digest_shape(p):
    # Strings deliberately differ in encoding only. The decoded text is the same.
    return {'code':p['code'],'constants':p['constants'],'params':p['params'],'vararg':p['vararg'],
        'stack':p['stack'],'upvalues':p['upvalues'],'children':[digest_shape(c) for c in p['children']]}

class Utf8(undump.Chunk):
    def string(self):
        n=self.size();return None if not n else self.take(n-1).decode('utf-8')

def load(token):
    data=(ROOT/f'artifacts/reference-tlzz/bytecode/{token}.luac').read_bytes()
    reader=Recorded(data);p=reader.parse();assert reader.at==len(data);return reader,p

def bindings(p):
    regs={};result={};K=p['constants']
    for w in p['code']:
        op=undump.OPS[w&127];a=(w>>7)&255;b=(w>>16)&255;c=(w>>24)&255;k=(w>>15)&1;bx=(w>>15)&0x1ffff
        if op=='CLOSURE':regs[a]=('fn',bx)
        elif op=='MOVE':regs[a]=regs.get(b)
        elif op=='GETTABUP':regs[a]=('global',K[c])
        elif op=='SETTABUP':
            v=regs.get(c) if not k else None
            if v and v[0]=='fn':result[K[b]]=p['children'][v[1]]
        elif op=='SETFIELD':
            v=regs.get(c) if not k else None;table=regs.get(a)
            if v and v[0]=='fn':result[(table[1]+'.' if table and table[0]=='global' else '')+str(K[b])]=p['children'][v[1]]
        elif op not in ('RETURN','RETURN0','RETURN1','SETLIST','EXTRAARG','VARARGPREP'):regs.pop(a,None)
    return result

def quote(text):return json.dumps(text,ensure_ascii=False)
def binary_literal(data):
    return '\n..'.join('"'+''.join(f'\\x{v:02x}' for v in data[i:i+80])+'"' for i in range(0,len(data),80))

def check_transcode(reader,p,data):
    other=Utf8(data,0);converted=other.parse();assert other.at==len(data)
    # A child selected as a new chunk can have no encoded source name; its code
    # and all non-string constants remain identical regardless of debug names.
    assert digest_shape(p)==digest_shape(converted)
    words=[w for fn in walk(p) for w in fn['code']]
    return {'original_instruction_sha256':sha(struct.pack('<'+'I'*len(words),*words)),
        'utf8_chunk_sha256':sha(data),'instruction_count':sum(len(x['code']) for x in walk(p)),
        'numeric_and_control_flow_unchanged':True}

def walk(p):
    yield p
    for c in p['children']:yield from walk(c)

def audit():
    index=json.loads((ROOT/'artifacts/reference-tlzz/bytecode/index.json').read_text(encoding='utf-8'))
    tasks=[]
    for entry in index['chunks']:
        if '\\副本\\' not in entry['source']:continue
        token=Path(entry['listing']).stem.replace('.listing','');reader,p=load(token)
        listings=OUT/'listings';listings.mkdir(parents=True,exist_ok=True);lines=[];undump.listing(p,lines)
        (listings/entry['listing']).write_text('\n'.join(lines)+'\n',encoding='utf-8')
        config=[];strings=set()
        for fn in walk(p):
            K=fn['constants'];regs={}
            for pc,w in enumerate(fn['code']):
                op=undump.OPS[w&127];a=(w>>7)&255;b=(w>>16)&255;c=(w>>24)&255;k=(w>>15)&1;bx=(w>>15)&0x1ffff
                if op=='GETTABUP':regs[a]=('global',K[c])
                elif op=='LOADK':regs[a]=('literal',K[bx])
                elif op=='MOVE':regs[a]=regs.get(b)
                elif op=='CALL':
                    target=regs.get(a)
                    if target and target[0]=='global' and target[1] in ('GetConfigBool','GetConfigText','GetConfigNumber','ReadConfigBool','ReadConfigText','ReadConfigNumber'):
                        args=[regs.get(a+i) for i in range(1,b)]
                        if len(args)>=2 and all(x and x[0]=='literal' for x in args[:2]):
                            config.append({'reader':target[1],'section':args[0][1],'key':args[1][1],'line_range':[fn['line'],fn['last_line']],'pc':pc+1})
                    regs.clear()
                elif op not in ('SETFIELD','SETTABUP','EXTRAARG','SETLIST'):regs.pop(a,None)
            strings.update(v for v in K if isinstance(v,str))
        tasks.append({'name':Path(entry['source'].replace('\\','/')).stem,'source':entry['source'],'sha256':entry['sha256'],
            'listing':entry['listing'],'configs':config,'global_names':sorted({fn['constants'][(w>>24)&255] for fn in walk(p) for w in fn['code'] if undump.OPS[w&127]=='GETTABUP'}),
            'runtime_enabled':entry['listing']=='002b8890.listing.txt'})
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'dungeon-config-inventory.json').write_text(json.dumps({'schema':1,'tasks':tasks,'count':len(tasks),'executed':False,'constant_tags_corrected':True},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    return tasks

def generate():
    tasks=audit();directory=ROOT/'scripts/legacy/original';directory.mkdir(parents=True,exist_ok=True)
    reader,p=load('002b8890');data=reader.transcode(p);proof=check_transcode(reader,p,data)
    wrapper='-- 原【副本】刷棋.lua 的 Lua 5.4 指令；仅字符串从 GBK 转 UTF-8。不要手改字节串。\n'
    wrapper+='if TaskConfig.rule_source=="兼容重建" then RunZhenlongDungeon();return end\n'
    wrapper+='LoadScript("original_combat")\nBeginOriginalDungeon("qiju",61)\n'
    wrapper+='local original=assert(load('+binary_literal(data)+',"@original/刷棋.lua","b",_G))\noriginal()\nEndOriginalDungeon("qiju",61)\n'
    path=directory/'qiju.lua';path.write_text(wrapper,encoding='utf-8')
    proof.update({'source':p['source'],'original_chunk_sha256':sha(reader.data),'wrapper_sha256':sha(path.read_bytes()),'entry':str(path.relative_to(ROOT)),
        'mode':'original_bytecode_string_transcode','rules_rewritten':False,'game_executed':False,
        'scene_id':61,'minimum_team_count':3,'scene_upvalue_binding':{'instack':1,'register':3},'team_upvalue_binding':{'instack':1,'register':1}})
    (OUT/'qiju-provenance.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (directory/'qiju.provenance.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    # Reuse the original collection/filter functions rather than guessing their
    # positional arguments. Native EnumEnvObj is supplied by our adapter.
    reader,root=load('004ab809');functions=bindings(root);lines=['-- 原 common/common_2.lua 对象筛选函数；只转换字符串编码。']
    selected=['ObjFilterByStr','ObjFilterByInt','ObjFilterByClass','ObjSort','Enum2XByName','Enum2XByClass']
    helper_proofs=[]
    groups=[(reader,functions,selected)]
    common,root=load('0049c027');groups.append((common,bindings(root),['BubbleSort','BubbleByDst','BubbleByHP','FindTableValue','DeleteTableFieldValue','HandleText_AddFuHao']))
    team,root=load('0055b610');groups.append((team,bindings(root),['Team.IsCountReady']))
    for reader,functions,names in groups:
        for name in names:
            fn=functions[name];assert fn['upvalue_names'] in (['_ENV'],[]),(name,fn['upvalue_names'])
            data=reader.transcode(fn);entry=check_transcode(reader,fn,data);entry.update(name=name,source_chunk_sha256=sha(reader.data));helper_proofs.append(entry)
            target='_G['+quote(name)+']' if '.' not in name else name
            lines.append(target+'=assert(load('+binary_literal(data)+','+quote('@original/'+name)+',"b",_G))')
    (ROOT/'scripts/legacy/modules/original_filters.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    # The early partial filter export is regenerable output, never a hand-edited rule.
    partial=directory/'object_filters.lua'
    if partial.exists():
        assert partial.resolve().is_relative_to(directory.resolve());partial.unlink()
    (OUT/'filter-provenance.json').write_text(json.dumps({'source_chunks':sorted({p['source_chunk_sha256'] for p in helper_proofs}),'functions':helper_proofs},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'dungeons_audited':len(tasks),'qiju':proof,'original_filter_functions':selected},ensure_ascii=False))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--generate',action='store_true');args=parser.parse_args()
    if args.generate:generate()
    else:print(json.dumps({'audited':len(audit())},ensure_ascii=False))
