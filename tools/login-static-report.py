from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]/'artifacts/login-research'
text=(root/'cegui-abi.txt').read_text(encoding='utf-8')
for key in ['isWindowPresent@','getWindow@WindowManager','??0WindowEventArgs@CEGUI@@QEAA@PEAV','getText@Window']:
 for part in text.split('### '):
  if part.startswith(key):
   lines=[l for l in part.splitlines() if l.strip()]
   print('\n'.join(lines[:33]))
for file in ['Interface-block-5813.txt','Interface-block-6810.txt']:
 text=(root/file).read_text(encoding='utf-8')
 print('\n',file)
 for m in re.finditer(r'<Window\b([^>]+)>(.*?)(?=<Window|</Window>)',text,re.S):
  attrs,body=m.groups()
  name=re.search(r'Name="([^"]+)',attrs)
  events=re.findall(r'<Event\s+Name="([^\"]+)"\s+Function="([^"]+)"',body)
  if name and events and (file.endswith('5813.txt') or any(x in name[1] for x in ['Area','area','Accept','Search','OK'])):print(name[1],events)
