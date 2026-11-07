"""Export every original 天龙助手 script as readable Lua, one file each, under 原脚本源码/.

- 原脚本源码/Script64/<分组>/<名称>.lua: the 318 Lua 5.4 chunks embedded in dfz64.dll
  (artifacts/reference-tlzz/bytecode/<token>.luac), decompiled with unluac 2025-12-23
  (.tools/unluac/unluac.jar, Java). Layout follows the chunks' own source names
  (@..\\tlzs\\Script64\\<分组>\\<名称>.lua).
- 原脚本源码/script/<分组>/<名称>.lua: the 36 plain-source scripts shipped beside the program
  (数据, 自定义), copied unchanged apart from encoding.
All text is converted from GBK to UTF-8.

unluac fails on one function, CDG:checkMP in daguai. The rest of daguai is decompiled with that
function replaced by an empty stub, then the hand translation in
original-fixups/daguai.checkMP.lua is spliced in; the fuzz harness beside it must agree with the
original bytecode or the export stops. Output is reference only: shipped tasks keep running the
original bytecode.
"""
from pathlib import Path
import importlib.util, json, re, shutil, struct, subprocess, sys

ROOT = Path(__file__).resolve().parents[1]
BYTECODE = ROOT / 'artifacts/reference-tlzz/bytecode'
OUT = ROOT / '原脚本源码'
JAR = ROOT / '.tools/unluac/unluac.jar'
LUA = ROOT / '.tools/build/environment-smoke/lua.exe'
TEMP = ROOT / '.tools/temp/decompile'
FIXUPS = Path(__file__).resolve().parent / 'original-fixups'
CHECKMP_INDEX = 29  # daguai child proto, source lines 839-941

spec = importlib.util.spec_from_file_location('undump', Path(__file__).resolve().parent / 'inspect-lua54-chunks.py')
undump = importlib.util.module_from_spec(spec)
spec.loader.exec_module(undump)


def unluac(path):
    """Decompiled text (GBK strings decoded, LF line endings), or None when unluac fails."""
    r = subprocess.run(['java', '-jar', str(JAR), '--rawstring', str(path)], capture_output=True)
    if r.returncode != 0 or not r.stdout.strip():
        return None
    return r.stdout.decode('gb18030', 'replace').replace('\r\n', '\n')


def size(n):
    out = [n & 127]
    n >>= 7
    while n:
        out.append(n & 127)
        n >>= 7
    out.reverse()
    out[-1] |= 128
    return bytes(out)


def daguai(raw):
    """Decompile daguai around CDG:checkMP and splice in the verified hand translation."""
    ranges = []

    class Chunk(undump.Chunk):
        def proto(self, parent=None, depth=0):
            start = self.at
            p = super().proto(parent, depth)
            if depth == 1:
                ranges.append((start, self.at))
            return p

    main = Chunk(raw, 0).parse()
    child = main['children'][CHECKMP_INDEX]
    start, end = ranges[CHECKMP_INDEX]
    assert (child['line'], child['last_line']) == (839, 941), 'daguai layout changed'
    TEMP.mkdir(parents=True, exist_ok=True)
    original = TEMP / 'daguai.checkMP.luac'
    original.write_bytes(raw[:31] + bytes([len(child['upvalues'])]) + raw[start:end])
    fuzz = subprocess.run([str(LUA), str(FIXUPS / 'daguai.checkMP.fuzz.lua'), str(original), str(FIXUPS / 'daguai.checkMP.lua')], capture_output=True)
    if fuzz.returncode != 0:
        raise SystemExit('daguai CDG:checkMP hand translation disagrees with the original bytecode:\n' + fuzz.stdout.decode('utf-8', 'replace'))
    stub = (size(0) + size(child['line']) + size(child['last_line']) + bytes([child['params'], child['vararg'], child['stack']])
            + size(1) + struct.pack('<I', undump.OPS.index('RETURN0')) + size(0)
            + size(len(child['upvalues'])) + b''.join(bytes(u) for u in child['upvalues'])
            + size(0) + size(0) + size(0) + size(0) + size(0))
    stubbed = TEMP / 'daguai.stub.luac'
    stubbed.write_bytes(raw[:start] + stub + raw[end:])
    text = unluac(stubbed)
    pattern = re.compile(r'^function CDG\.checkMP\([^)]*\)\n(?:  .*\n)*?end\n', re.M)
    assert len(pattern.findall(text)) == 1, 'checkMP stub not found'
    hand = (FIXUPS / 'daguai.checkMP.lua').read_text(encoding='utf-8')
    return pattern.sub(lambda _: hand, text)


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    library = json.loads((ROOT / 'scripts/original-library/index.json').read_text(encoding='utf-8'))
    if OUT.exists():
        shutil.rmtree(OUT)
    count = 0
    for m in library['modules']:
        path = BYTECODE / f"{m['token']}.luac"
        raw = path.read_bytes()
        source = undump.Chunk(raw, 0).parse()["source"]
        parts = source.lstrip('@').split('\\')
        target = OUT.joinpath(*parts[parts.index('Script64'):])
        if m['name'] == 'daguai':
            text = daguai(raw)
            note = '；函数 CDG:checkMP 由原字节码手工还原并经对拍核对'
        else:
            out = unluac(path)
            if out is None:
                raise SystemExit(f"unluac failed: {m['group']}/{m['name']}")
            text, note = out, ''
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(f"-- 反编译自 dfz64.dll 内嵌字节码 {m['token']}（unluac 2025-12-23{note}；仅供分析）\n" + text, encoding='utf-8')
        count += 1
    for c in library['custom_sources']:
        source = ROOT / c['source']
        target = OUT / Path(c['source']).relative_to('满天星/天龙助手')
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(source.read_bytes().decode('gb18030'), encoding='utf-8')
        count += 1
    (OUT / 'README.md').write_text(README.format(count=count), encoding='utf-8')
    print('exported', count, 'files to', OUT)


README = """# 天龙助手原脚本源码（反编译导出）

本目录由 `python tools/decompile-original.py` 生成，每次运行会整体重建；需要修改请另存副本。

| 目录 | 内容 |
|---|---|
| `Script64/<分组>/<名称>.lua` | dfz64.dll 内嵌的 318 个 Lua 5.4 字节码模块，经 unluac 2025-12-23 反编译。目录与原程序 `..\\tlzs\\Script64` 一致，保留原局部变量名 |
| `script/数据`、`script/自定义` | 随原程序附带的 36 个明文脚本，内容未改 |

共 {count} 个 Lua 文件，全部由 GBK 转为 UTF-8。

- 每个反编译文件第一行注明对应的字节码编号，原字节码在 `artifacts/reference-tlzz/bytecode/<编号>.luac`。
- `Script64/系统/daguai.lua` 中有一个函数 `CDG:checkMP` unluac 处理不了。该函数已按原字节码手工还原，与原字节码随机对拍 2 万次，返回值和调用序列一致；见 `tools/original-fixups/`。
- 往返核对：用标准 Lua 5.4.9 重新编译后与原字节码（去调试信息）比较。26 个逐字节一致，其余差异不超过 0.6%，属寄存器和跳转排布不同，逻辑相同。
- 以下 11 个反编译文件和 5 个明文脚本使用了中文变量名或函数名，原程序的 Lua 可以运行，标准 Lua 会报语法错：师门任务、新手1-40级、闲常治务、材料点金、点心法、庄园养鱼、属地马贼、坐标摆摊、common_2、fnE2C、graph；script 下的坐标摆摊、[例] 等待到时间、[例] 等待队伍人数、窗口闪烁报警、自动组队(例)。
- 本目录只供阅读，程序不直接读取。程序使用的副本在 `scripts/original-source/`，由 `python tools/import-original-source.py` 从本目录导入：中文键名改为 `["键名"]` 写法，并修正反编译错误，修正后逐函数与原字节码比对一致。对接表见 `docs/ORIGINAL_SOURCE_MAP.md`。
"""


if __name__ == '__main__':
    main()
