"""Explicit live acceptance: one Lua movement to the user-requested test location.

Running this file DOES move a currently logged-in game character. No planting.
"""
from pathlib import Path
import argparse
import datetime as dt
import json
import math
import os
import queue
import subprocess
import sys
import threading
import time
import uuid

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/pythonpkgs'))
import psutil
parser=argparse.ArgumentParser()
parser.add_argument('--pid',type=int,required=True)
parser.add_argument('--created',required=True)
parser.add_argument('--x',type=int,default=360)
parser.add_argument('--y',type=int,default=317)
args=parser.parse_args()
exe=ROOT/'dist/TLBBClient/TLBB.exe'
session=str(uuid.uuid4())
env=os.environ.copy()
env['PATH']=os.pathsep.join([str(Path(os.environ['SystemRoot'])/'System32'),os.environ['SystemRoot']])
env.pop('QT_PLUGIN_PATH',None)
env.pop('QT_QPA_PLATFORM_PLUGIN_PATH',None)
worker=subprocess.Popen([str(exe),'--worker','--target-pid',str(args.pid),'--created',args.created,
                         '--session',session,'--game-root',str(ROOT.parent),
                         '--script',str(exe.parent/'scripts/luoyang_plant.lua')],
                        env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,
                        creationflags=subprocess.CREATE_NO_WINDOW)
messages=queue.Queue(maxsize=128)
def collect():
    for line in worker.stdout:
        if len(line)>32768:
            break
        try: messages.put(json.loads(line),timeout=1)
        except (ValueError,queue.Full):break
threading.Thread(target=collect,daemon=True).start()
events=[]
peak_private=peak_working=0
def wait(kind,timeout=15):
    global peak_private,peak_working
    end=time.monotonic()+timeout
    while time.monotonic()<end:
        try:
            memory=psutil.Process(worker.pid).memory_info()
            peak_private=max(peak_private,memory.private)
            peak_working=max(peak_working,memory.rss)
        except psutil.Error:pass
        try: event=messages.get(timeout=0.1)
        except queue.Empty:continue
        events.append(event)
        if event.get('event') in {'error','stopped','target_exited'}:
            raise AssertionError(event)
        if event.get('event')==kind:return event
    raise TimeoutError(kind)
def send(command):
    command['session']=session
    worker.stdin.write((json.dumps(command,ensure_ascii=False)+'\n').encode('utf-8'))
    worker.stdin.flush()
try:
    ready=wait('ready')
    assert ready['live_position_available'],ready
    beat=wait('heartbeat')
    before=beat['live_state']
    assert before['map']=='洛阳',before
    distance=math.hypot(before['x']-args.x,before['y']-args.y)
    assert 1<distance<=32,('Choose a different target inside 32 units',before)
    config=dict(x=args.x,y=args.y,crop='小麦',rounds=1,tolerance=0.3,timeout_seconds=15)
    send(dict(op='start',mode='live',config=config))
    refused=wait('blocked')
    assert len(refused['missing'])==2,refused
    config['crop']=''
    send(dict(op='start',mode='live_move',config=config))
    started=wait('started')
    assert started['mode']=='live_move',started
    completed=wait('completed')
    assert completed['preview'] is False and completed['actions']==1,completed
    after=completed['state']
    assert after['map']=='洛阳' and math.hypot(after['x']-args.x,after['y']-args.y)<=0.3,after
    send(dict(op='quit'))
    worker.wait(timeout=5)
    assert worker.returncode==0,worker.returncode
    assert psutil.Process(args.pid).is_running()
    report=dict(status='pass',captured_at=dt.datetime.now(dt.timezone(dt.timedelta(hours=8))).isoformat(),
                pid=args.pid,created=args.created,before=before,after=after,events=events,
                lua_version=started['version'],movement_actions=completed['actions'],
                actual_planting_tested=False,worker_exited=True,game_alive=True,
                sample_peak_private_bytes=peak_private,sample_peak_working_bytes=peak_working,
                scope='One packaged Worker + Lua + native movement; short test, no long-run or multi-game claim')
    output=ROOT/'artifacts/adapter-research/lua-real-movement.json'
    output.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(report,ensure_ascii=False,indent=2))
finally:
    if worker.poll() is None:
        try:send(dict(op='quit'));worker.wait(timeout=4)
        except (OSError,subprocess.TimeoutExpired):worker.kill();worker.wait(timeout=3)
