"""Validate the built app using owned UI fixtures, without staging or packaging."""
from pathlib import Path
import json,os,shutil,subprocess,uuid
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/universal-runtime-0.15.0/native-ui'
OUT.mkdir(parents=True,exist_ok=True)
fixture=OUT/'binding-fixtures';(fixture/'Bin64').mkdir(parents=True,exist_ok=True)
owned=ROOT/'.tools/build/client-0.15.0/TLBBFixture.exe'
for name in ['Bin64/Game.exe','Launch.exe','Launch.bin']:shutil.copy2(owned,fixture/name)
(fixture/'.owned-binding-fixture').write_text('TLBBClient-owned-window-fixture',encoding='ascii')
env=os.environ.copy();env['TEMP']=env['TMP']=str(ROOT/'.tools/temp')
env['PATH']=str(ROOT/'.tools/Qt/6.8.3/mingw_64/bin')+os.pathsep+str(ROOT/'.tools/Qt/Tools/mingw1310_64/bin')+os.pathsep+env.get('PATH','')
runtime=OUT/'owned-compact-runtime';runtime.mkdir(exist_ok=True)
for name in ['TLBB.exe','TLBBEngine.dll','TLBBData.rcc','TLBBFixture.exe']:shutil.copy2(ROOT/'.tools/build/client-0.15.0'/name,runtime/name)
exe=runtime/'TLBB.exe'
env['QT_PLUGIN_PATH']=str(ROOT/'.tools/Qt/6.8.3/mingw_64/plugins')
env['QT_QPA_PLATFORM_PLUGIN_PATH']=str(ROOT/'.tools/Qt/6.8.3/mingw_64/plugins/platforms')
assert not (runtime/'scripts').exists() and not (runtime/'tasks').exists()
assets_file=OUT/'resource-index.json'
subprocess.run([str(exe),'--assets-report',str(assets_file)],env=env,capture_output=True,timeout=15,check=True,creationflags=subprocess.CREATE_NO_WINDOW)
assets=json.loads(assets_file.read_text(encoding='utf-8'));assert assets['mounted'] and not assets['compressed'] and not assets['overrides']
# A loose override changes one script without rebuilding the exe or duplicating the full tree.
import hashlib
relative='scripts/builtin/utility/wait_until.lua'
override=runtime/'overrides'/relative;override.parent.mkdir(parents=True,exist_ok=True)
override.write_bytes((ROOT/'scripts/utility/wait_until.lua').read_bytes()+b'\n-- owned override verification\n')
subprocess.run([str(exe),'--assets-report',str(OUT/'override-index.json')],env=env,capture_output=True,timeout=15,check=True,creationflags=subprocess.CREATE_NO_WINDOW)
overridden=json.loads((OUT/'override-index.json').read_text(encoding='utf-8'))
assert overridden['overrides']==[{'path':relative,'sha256':hashlib.sha256(override.read_bytes()).hexdigest()}]
# Remove only our exact override fixture; no user profile or game file is touched.
assert override.resolve().is_relative_to(runtime.resolve());override.unlink()
# Corrupted bundles fail closed before starting the GUI.
invalid=OUT/'owned-invalid-runtime';invalid.mkdir(exist_ok=True)
shutil.copy2(exe,invalid/'TLBB.exe');(invalid/'TLBBData.rcc').write_bytes(b'owned invalid resource fixture')
rejected=subprocess.run([str(invalid/'TLBB.exe'),'--assets-report',str(OUT/'invalid-index.json')],env=env,capture_output=True,timeout=15,creationflags=subprocess.CREATE_NO_WINDOW)
assert rejected.returncode==2 and not (OUT/'invalid-index.json').exists()
args=[str(exe),'--ui-self-test','--fixture-root',str(fixture),'--game-root',str(fixture),
    '--data-root',str(OUT/('owned-data-'+uuid.uuid4().hex[:12])),'--report',str(OUT/'verification.json')]
with (OUT/'stderr.log').open('wb') as error:
    result=subprocess.run(args,env=env,stdout=subprocess.DEVNULL,stderr=error,timeout=55,creationflags=subprocess.CREATE_NO_WINDOW)
assert result.returncode==0,f'Owned UI fixture exited {result.returncode}'
report=json.loads((OUT/'verification.json').read_text(encoding='utf-8-sig'))
assert report['passed'] and report['remaining_sessions']==0
print(json.dumps({'status':'pass','native_ui_checks':len(report['checks']),
    'native_hotkeys_verified_on_owned_fixtures':report['native_hotkey_input_verified_on_owned_fixtures'],
    'bundled_resources':len(assets['files']),'runtime_loose_script_files':0,'resource_override_verified':True,'corrupt_resource_rejected':True,
    'real_game_tested':False,'installer_generated':False,'zip_generated':False,'report':str(OUT/'verification.json')},ensure_ascii=False))
