"""Collect a small official-site link inventory for UI design; no game access."""
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.parse import urljoin, urlsplit
import concurrent.futures
import datetime as dt
import hashlib
import json
import re
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
from bs4 import BeautifulSoup
OUT=ROOT/'design/research'
OUT.mkdir(parents=True,exist_ok=True)
urls=[
 'https://tl.changyou.com/data/index.shtml',
 'https://tl.changyou.com/xtl/announce/general/20261023/186264.shtml',
 'https://tl.changyou.com/download/index.shtml',
 'https://tl.changyou.com/data/bbs/fbsdgz.shtml',
 'https://tl.changyou.com/data/mission/jbsh.shtml',
 'https://tl.changyou.com/data/info/xhrw3.shtml',
 'https://tl.changyou.com/xtl/announce/general/20260529/184050.shtml',
]
pattern=re.compile('副本|师门|漕运|采矿|钓鱼|种植|贼兵|马贼|藏宝|寻宝|昆仑|寒山|问道|少室|四绝|缥缈|燕子|棋局|门派|扫荡|登录|寻影|九黎|百花|闲常|清剿')
def inspect(url):
 try:
  with urlopen(Request(url,headers={'User-Agent':'Mozilla/5.0'}),timeout=18) as response:
   data=response.read(2*1024*1024)
  hint=re.search(rb'charset\s*=\s*["\']?([\w-]+)',data[:4096],re.I)
  encoding=hint.group(1).decode() if hint else 'utf-8'
  if encoding.lower() in {'gb2312','gbk'}:encoding='gb18030'
  soup=BeautifulSoup(data.decode(encoding,errors='replace'),'html.parser')
  title=soup.title.get_text(' ',strip=True) if soup.title else ''
  links=[]
  for a in soup.select('a[href]'):
   text=a.get_text(' ',strip=True)
   target=urljoin(url,a.get('href',''))
   if pattern.search(text) and urlsplit(target).hostname in {'tl.changyou.com','www.tl.changyou.com','event.changyou.com'}:
    item=dict(title=text,url=target)
    if item not in links:links.append(item)
  return dict(url=url,title=title,encoding=encoding,sha256=hashlib.sha256(data).hexdigest(),
              bytes_read=len(data),links=links,status='ok')
 except Exception as exc:
  return dict(url=url,status='unavailable',error=str(exc))
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
 pages=list(pool.map(inspect,urls))
report=dict(captured_at=dt.datetime.now(dt.timezone(dt.timedelta(hours=8))).isoformat(),
 scope='Official links and metadata only. Old reference pages do not establish live server eligibility.',pages=pages)
(OUT/'official-link-inventory.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
for p in pages:
 print(p['status'],p['url'],'links',len(p.get('links',[])),flush=True)
 if p.get('links'):
  for link in p['links'][:35]: print(json.dumps(link,ensure_ascii=False),flush=True)
