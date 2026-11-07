"""Collect a verified release and hash manifest; ZIP requires --include-zip."""

from pathlib import Path

import hashlib

import json

import re

import zipfile
import argparse

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument("--include-zip",action="store_true",help="Explicitly also generate a portable ZIP")
args=parser.parse_args()



ROOT = Path(__file__).resolve().parents[1]

STAGE = ROOT / "dist/TLBBClient-0.15.0"

OUTPUT = ROOT / "dist/packages"

OUTPUT.mkdir(parents=True, exist_ok=True)



def sha(file):

    return hashlib.file_digest(file.open("rb"), "sha256").hexdigest()



def included(file):

    rel = file.relative_to(STAGE).as_posix()

    return rel.startswith("data/docs/") or not any(rel == p or rel.startswith(p + "/") for p in ["data", "scripts/user"])



for relative in ["TLBB.exe", "TLBBEngine.dll", "TLBBRuntime.dll", "scripts/builtin/legacy/manifest.json", "scripts/tasks/catalog.json"]:

    assert (STAGE / relative).is_file(), relative



release = json.loads((ROOT/'artifacts/release-verification-0.15.0.json').read_text(encoding='utf-8'))
assets=release['resources']
assert assets['loose_scripts'] and not assets['mounted']
asset_index={a['path']:a for a in assets['files']}
for name,a in asset_index.items():
    source=ROOT/'scripts'/name[16:] if name.startswith('scripts/builtin/') else ROOT/'design/task-catalog.json'
    assert source.is_file() and sha(source)==a['sha256'],f'Resource differs from verified source: {name}'
def asset_file(name):
    assert name in asset_index,name
    return ROOT/'scripts'/name[16:] if name.startswith('scripts/builtin/') else ROOT/'design/task-catalog.json'

# Carry the exact license shipped by the Lua source distribution.

readme = (ROOT / ".tools/src/lua-5.4.9/doc/readme.html").read_text(encoding="utf-8")

license_text = re.search(r"<BLOCKQUOTE[^>]*>\s*(Copyright.*?)</BLOCKQUOTE>", readme, re.S | re.I).group(1)

import html

license_text = html.unescape(re.sub(r"<[^>]+>", "", license_text)).strip()

(STAGE / "data/docs").mkdir(parents=True, exist_ok=True)
(STAGE / "data/docs/LICENSE-LUA.txt").write_text(license_text + "\n", encoding="utf-8")

qt_license = ROOT / "packaging/LICENSE-LGPL-3.0.txt"

assert qt_license.is_file(), "Qt LGPL license must be present"

(STAGE / "data/docs" / qt_license.name).write_bytes(qt_license.read_bytes())

metadata = {

    "schema": 1, "version": "0.15.0", "product": "TLBBClient",

    "capabilities": {"home_binding": True, "launcher_binding": True, "single_game_panels": True,

                     "automatic_authentication": True, "automatic_authentication_live_verified": False,

                     "role_selection_name_reader": True, "verified_role_nickname_reader": False,

                     "strict_utf8_role_names": True, "utility_wait_task": True,

                     "legacy_lua_runtime": True, "daily_sign_integrated": True, "daily_sign_live_verified": False,

                     "resident_lua54": True, "direct_game_lua": True, "per_game_operation_ipc": False, "combined_engine_dll": True, "risk_switches_cover_raw_lua": False, "reference_compat_api": True, "fixed_game_snippets": True, "reference_tasks_live_verified": False,

                     "cross_scene_pathfinding": True, "cross_scene_pathfinding_live_verified": False,

                     "npc_dialog_options": True, "bank_transfer": True, "temporary_bag_transfer": True,

                     "instance_sweep": True, "shop_profit_withdraw": True, "gem_compose": True, "item_destroy": False,

                     "planting": False, "multi_open_limit_bypass": False,

                     "reference_route_configuration": True, "reference_route_execution": False,

                     "sequential_and_scheduled_flow": True, "single_executor_per_game": True,

                     "combat": True, "combat_live_verified": False, "zhenlong_dungeon": True, "zhenlong_dungeon_live_verified": False, "trading": False},

    "scripts": [], "files": []

}

release = json.loads((ROOT / 'artifacts/release-verification-0.15.0.json').read_text(encoding='utf-8'))
assert release['status']=='pass' and release['sha256']==sha(STAGE/'TLBB.exe') and release['engine_sha256']==sha(STAGE/'TLBBEngine.dll')
import subprocess
pe = subprocess.run([str(ROOT/'.tools/Qt/Tools/mingw1310_64/bin/objdump.exe'),'-p',str(STAGE/'TLBBEngine.dll')],capture_output=True,text=True,check=True).stdout
imports = re.findall(r'DLL Name: (\S+)',pe)
assert imports and set(x.lower() for x in imports)<= {'kernel32.dll','msvcrt.dll','user32.dll'}, imports
metadata['resident_engine']={'dll':'TLBBEngine.dll','imports':imports,'version':'2','lua_runtime':'5.4.9','game_lua_runtime':'LuaPlus 5.0',
    'control_poll_ms':500,'scheduler_ms':20,'per_action_ipc':False,'script_heap_limit_bytes':16*1024*1024,'game_lua_heap_limited_by_script_heap':False,
    'trusted_direct_lua':True,'risk_switches_cover_raw_lua':False,'live_tested':False,'script_gc_finalizers_supported':False}

live = json.loads((ROOT / 'artifacts/login-live-test/verified-0.5.2.json').read_text(encoding='utf-8'))

assert live['status'] == 'pass' and live['credential_submission_count'] == 1

assert live['verified_world_samples'] >= 2 and live['learned_role_count'] > 0

assert sha(ROOT / 'include/game_lua_login.hpp') == live['game_lua_login_source_sha256']

metadata['login_verification'] = {'date': live['date'], 'tested_version': live['tested_version'],

    'current_version_full_chain_live_tested': False, 'bridge_updated_for_utf8_role_names': True,

    'credential_submission_count': 1, 'verified_world_samples': live['verified_world_samples']}

role_report=ROOT/'artifacts/role-encoding-0.14.0/verification.json'

metadata['login_verification']['current_role_query_live_tested']=False

if role_report.exists():

    role=json.loads(role_report.read_text(encoding='utf-8'))

    if role.get('status')=='pass' and role.get('login_bridge_sha256')==sha(STAGE/'TLBBEngine.dll'):

        metadata['capabilities']['verified_role_nickname_reader']=True

        metadata['login_verification']['current_role_query_live_tested']=True

reference_routes = json.loads(asset_file('scripts/builtin/data/reference_routes.json').read_text(encoding='utf-8'))

assert reference_routes['runtime_enabled'] is False

metadata['reference_routes'] = {'route_count': len(reference_routes['routes']),

                               'point_count': sum(len(r['points']) for r in reference_routes['routes']),

                               'runtime_enabled': False}

tlzz=json.loads(asset_file('scripts/builtin/data/tlzz_reference_routes.json').read_text(encoding='utf-8'))

assert tlzz['runtime_enabled'] is False

metadata['assistant_reference_routes']={'route_count':len(tlzz['routes']),

    'point_count':sum(len(r['points']) for r in tlzz['routes']),'runtime_enabled':False}

legacy=json.loads(asset_file('scripts/builtin/legacy/manifest.json').read_text(encoding='utf-8'))

metadata['legacy_tasks']=legacy['tasks']

original_index=json.loads(asset_file('scripts/builtin/original-library/index.json').read_text(encoding='utf-8'))
original_modules={m['token']:m for m in original_index['modules']}
# Original tasks run from the decompiled source (tools/import-original-source.py checks each file
# against the original bytecode function by function); verify every shipped file against its index.
source_index=json.loads(asset_file('scripts/builtin/original-source/index.json').read_text(encoding='utf-8'))
def verify_source(token):
    entry=source_index['modules'][token]
    data=asset_file('scripts/builtin/original-source/'+entry['path']).read_bytes()
    assert hashlib.sha256(data).hexdigest()==entry['sha256'] and len(data)==entry['bytes']

for task in metadata['legacy_tasks']:

    task['packaged_sha256']=asset_index['scripts/builtin/legacy/'+task['entry']]['sha256']
    if 'original_alternative' in task:
        # Optional "run the original script" mode of a rewritten task: same checks as generic tasks.
        alternative=task['original_alternative']
        assert task['adapter']=='tlzz_compat_v1' and not alternative['combat']
        assert original_modules.get(alternative['original_token'],{}).get('original_sha256',alternative['module_sha256'])==alternative['module_sha256']
        for token in [alternative['original_token']]+[{m['name']:m for m in original_index['modules']}[n]['token'] for n in alternative['framework']]:
            verify_source(token)

    if 'original_sha256' in task:task['rules_modified']=task['packaged_sha256']!=task['original_sha256']

    elif task.get('adapter')=='original_archive_v1':
        # Archive entries use an indexed bytecode shard instead of a generated
        # per-wrapper provenance file. Verify the indexed slice and source hashes.
        module=original_modules[task['original_token']]
        assert module['original_sha256']==task['original_chunk_sha256']
        assert module['sha256']==task['utf8_chunk_sha256']
        assert module['numeric_and_control_flow_unchanged'] and not module['rules_rewritten']
        assert module['runtime_contract']==task['validation_contract']
        verify_source(task['original_token'])
        assert not task['rules_modified'] and not task['live_verified']
    elif task.get('adapter')=='original_generic_v1':
        # Generic original tasks: the task script and every framework module it lists run from
        # the verified original source; check each file and its provenance flags.
        by_name={m['name']:m for m in original_index['modules']}
        assert original_modules[task['original_token']]['original_sha256']==task['module_sha256']
        for module in [original_modules[task['original_token']]]+[by_name[n] for n in task.get('framework',[])]:
            assert module['numeric_and_control_flow_unchanged'] and not module['rules_rewritten'] and not module.get('known_empty_stub')
            verify_source(module['token'])
        assert task['entry']=='original/generic_task.lua' and task['requires_resident']
        assert not task['rules_modified'] and not task['live_verified']
    elif task.get('original_bytecode'):
        if not task.get('provenance'):
            raise RuntimeError('原 Lua 任务缺少打包来源验证：'+task['id'])
        proof=json.loads(asset_file('scripts/builtin/legacy/'+task['provenance']).read_text(encoding='utf-8'))
        assert proof['wrapper_sha256']==task['packaged_sha256'] and proof['numeric_and_control_flow_unchanged']
        assert proof['original_chunk_sha256']==task['original_chunk_sha256']==task['module_sha256']
        assert proof['original_instruction_sha256']==task['original_instruction_sha256']
        if 'scene_id' in proof:assert proof['scene_id']==61
        assert not task['rules_modified'] and task['host_api_adapted'] and not task['live_verified']
    elif task.get('adapted'):assert task['combat'] and task['rules_modified'] and not task['live_verified']
    elif task.get('adapter')=='battle_support_v1':assert not task['combat'] and not task['live_verified']
    elif task.get('adapter')=='xiaomi_text_v1':
        # Imported 小蜜文本 scripts (tools/import-xiaomi-scripts.py): they run on modules/xiaomi_api.lua and never count as verified.
        assert task['entry'].startswith('xiaomi/') and task['requires_resident'] and task['module_sha256'] and not task['live_verified']
    elif task.get('rules_modified') and task['entry'].startswith('dungeons/'):
        # Explicitly written dungeon flows: no original chunk to hash; they must carry a completion contract.
        assert task['reconstructed'] and task.get('validation_contract') and task['requires_resident'] and not task['live_verified']
    else:assert task['reconstructed'] and task['module_sha256'] and not task['rules_modified']

assert asset_index['scripts/builtin/legacy/compat.lua']['sha256']==sha(ROOT/'scripts/legacy/compat.lua')

for file in sorted(STAGE.rglob("*")):

    if not file.is_file() or not included(file):

        continue

    assert not file.is_symlink()

    relative = file.relative_to(STAGE).as_posix()

    entry = {"path": relative, "bytes": file.stat().st_size, "sha256": sha(file)}

    metadata["files"].append(entry)

    if relative.startswith("scripts/builtin/") and file.suffix.lower() == ".lua":

        metadata["scripts"].append(entry)

metadata["scripts"]=[a for a in assets["files"] if a["path"].endswith(".lua")]
metadata["resources"]={"directory":"scripts","entries":len(assets["files"])}
dungeon_catalog=json.loads(asset_file('scripts/builtin/dungeons/catalog.json').read_text(encoding='utf-8'))
assert len(dungeon_catalog['entries'])==32
for d in dungeon_catalog['entries']:
    assert asset_index['scripts/builtin/dungeons/'+d['resource']]['sha256']==d['resource_sha256']
    assert d['bytecode_proof']['numeric_and_control_flow_unchanged'] and not d['rules_rewritten']
metadata['original_dungeon_rules']=dungeon_catalog['entries']
metadata['capabilities']['builtin_resource_bundle']=True
metadata['capabilities']['original_dungeon_resources']=32
metadata['capabilities']['original_dungeon_adapters_integrated']=sum(d['runtime_enabled'] for d in dungeon_catalog['entries'])
assert metadata["scripts"]

(STAGE / "data/package-manifest.json").write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

archive = OUTPUT / "TLBBClient-0.15.0-full.zip"

if args.include_zip:
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:

        for file in sorted(STAGE.rglob("*")):

            if file.is_file() and (included(file) or file.as_posix().endswith("data/package-manifest.json")):

                z.write(file, "TLBBClient/" + file.relative_to(STAGE).as_posix())

        for directory in ["data/profiles/", "data/logs/", "data/cache/", "scripts/user/"]:

            z.writestr("TLBBClient/" + directory, b"")

    with zipfile.ZipFile(archive) as z:

        for entry in metadata["files"]:

            assert hashlib.sha256(z.read("TLBBClient/" + entry["path"])).hexdigest() == entry["sha256"]

report = {"version": "0.15.0", "stage": str(STAGE), "zip": str(archive) if args.include_zip else None, "zip_generated":args.include_zip, "zip_bytes": archive.stat().st_size if args.include_zip else 0,

          "zip_sha256": sha(archive) if args.include_zip else None, "file_count": len(metadata["files"]) + 1, "lua_count": len(metadata["scripts"]),

          "private_data_excluded": True, "runtime_bytes": sum(e["bytes"] for e in metadata["files"])}

(ROOT / "artifacts/package-0.15.0.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

print(json.dumps(report, ensure_ascii=False))

