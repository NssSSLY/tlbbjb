"""Bounded static Lua 5.4 undump/disassembly. Does not load or execute the supplied DLL/chunks."""
from pathlib import Path
import hashlib, json, re, struct
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'满天星/天龙助手/dfz64.dll'
OUT=ROOT/'artifacts/reference-tlzz/bytecode'
OPS='MOVE LOADI LOADF LOADK LOADKX LOADFALSE LFALSESKIP LOADTRUE LOADNIL GETUPVAL SETUPVAL GETTABUP GETTABLE GETI GETFIELD SETTABUP SETTABLE SETI SETFIELD NEWTABLE SELF ADDI ADDK SUBK MULK MODK POWK DIVK IDIVK BANDK BORK BXORK SHRI SHLI ADD SUB MUL MOD POW DIV IDIV BAND BOR BXOR SHL SHR MMBIN MMBINI MMBINK UNM BNOT NOT LEN CONCAT CLOSE TBC JMP EQ LT LE EQK EQI LTI LEI GTI GEI TEST TESTSET CALL TAILCALL RETURN RETURN0 RETURN1 FORLOOP FORPREP TFORPREP TFORCALL TFORLOOP SETLIST CLOSURE VARARG VARARGPREP EXTRAARG'.split()

class Chunk:
    def __init__(self,data,start):self.data=data;self.at=start;self.start=start;self.total=0;self.functions=0
    def take(self,n):
        assert 0<=n<=8*1024*1024 and self.at+n<=len(self.data) and self.at+n-self.start<=16*1024*1024
        value=self.data[self.at:self.at+n];self.at+=n;return value
    def byte(self):return self.take(1)[0]
    def size(self,limit=1000000):
        n=0
        for _ in range(9):
            b=self.byte();n=(n<<7)|(b&127)
            if b&128:
                assert n<=limit
                return n
        raise ValueError('Integer overflow')
    def string(self):
        n=self.size()
        if n==0:return None
        raw=self.take(n-1)
        # These compiled Script64 sources use GBK; some two-character GBK strings
        # are coincidentally valid UTF-8 and must not be guessed as Greek text.
        for enc in ('gb18030','utf-8'):
            try:return raw.decode(enc)
            except UnicodeError:pass
        return 'hex:'+raw.hex()
    def proto(self,parent=None,depth=0):
        assert depth<=32
        self.functions+=1;assert self.functions<=10000
        p={'source':self.string() or parent,'line':self.size(),'last_line':self.size(),
           'params':self.byte(),'vararg':self.byte(),'stack':self.byte()}
        n=self.size(250000);self.total+=n;assert self.total<=2000000
        p['code']=list(struct.unpack('<'+'I'*n,self.take(4*n)))
        p['constants']=[]
        for _ in range(self.size(100000)):
            kind=self.byte()
            if kind==0:v=None
            elif kind in (1,17):v=kind==17
            # lobject.h: LUA_VNUMINT=3; LUA_VNUMFLT=19 (Lua 5.4).
            elif kind in (3,19):v=struct.unpack('<q' if kind==3 else '<d',self.take(8))[0]
            elif kind in (4,20):v=self.string()
            else:raise ValueError('Unknown constant')
            p['constants'].append(v)
        p['upvalues']=[list(self.take(3)) for _ in range(self.size(255))]
        p['children']=[self.proto(p['source'],depth+1) for _ in range(self.size(10000))]
        self.take(self.size(250000))
        for _ in range(self.size(250000)):self.size();self.size()
        p['locals']=[{'name':self.string(),'start':self.size(),'end':self.size()} for _ in range(self.size(100000))]
        p['upvalue_names']=[self.string() for _ in range(self.size(255))]
        return p
    def parse(self):
        assert self.take(12)==b'\x1bLua\x54\x00\x19\x93\r\n\x1a\n'
        assert self.take(3)==bytes([4,8,8])
        assert struct.unpack('<q',self.take(8))[0]==0x5678
        assert struct.unpack('<d',self.take(8))[0]==370.5
        upvalues=self.byte();p=self.proto();assert upvalues==len(p['upvalues'])
        return p

def listing(p,lines,depth=0):
    indent='  '*depth
    lines.append(f"{indent}FUNCTION {p['source']} lines {p['line']}..{p['last_line']} params={p['params']} stack={p['stack']}")
    for i,v in enumerate(p['constants']):lines.append(f'{indent}K{i}: '+json.dumps(v,ensure_ascii=False))
    for pc,w in enumerate(p['code']):
        op=w&127;assert op<len(OPS)
        a=(w>>7)&255;k=(w>>15)&1;b=(w>>16)&255;c=(w>>24)&255;bx=(w>>15)&0x1ffff
        lines.append(f'{indent}{pc+1:05d} {OPS[op]:12} A={a} B={b} C={c} k={k} Bx={bx} sBx={bx-65535}')
    for child in p['children']:listing(child,lines,depth+1)

def all_constants(p):
    yield from p['constants']
    for c in p['children']:yield from all_constants(c)

def main():
    OUT.mkdir(parents=True,exist_ok=True);data=SOURCE.read_bytes();reports=[];failed=[]
    for match in re.finditer(re.escape(b'\x1bLua\x54\x00'),data):
        at=match.start();c=Chunk(data,at)
        try:
            proto=c.parse();lines=[];listing(proto,lines)
            token=f'{at:08x}';(OUT/(token+'.listing.txt')).write_text('\n'.join(lines)+'\n',encoding='utf-8')
            # JSON is static syntax/constant data, never a runtime module.
            (OUT/(token+'.json')).write_text(json.dumps(proto,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
            raw=data[at:c.at];(OUT/(token+'.luac')).write_bytes(raw)
            constants=list(all_constants(proto))
            reports.append({'offset':at,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),
                'source':proto['source'],'functions':c.functions,'instructions':c.total,
                'string_constant_count':sum(isinstance(v,str) for v in constants),'listing':token+'.listing.txt'})
        except (AssertionError,ValueError,IndexError,struct.error) as e:
            failed.append({'offset':at,'reason':type(e).__name__})
    result={'source_sha256':hashlib.sha256(data).hexdigest(),'lua54_headers':len(reports)+len(failed),
        'parsed_count':len(reports),'failed':failed,'chunks':reports,'executed':False,'decompiled_source_recovered':False}
    (OUT/'index.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'parsed_count':len(reports),'failed':failed,'source_names':[e['source'] for e in reports]},ensure_ascii=False))
if __name__=='__main__':main()
