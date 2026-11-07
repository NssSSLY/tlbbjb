"""Build the user-requested feature roadmap from supplied Lua, without executing it.

Use --write to update the catalog and stage only the eleven explicit priority chunks.
Other source modules remain references until their adapters and completion contracts exist.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/feature-plan-2026-10-26'
spec=importlib.util.spec_from_file_location('original_rules',ROOT/'tools/original-lua-rules.py')
rules=importlib.util.module_from_spec(spec);spec.loader.exec_module(rules)

# Names are the human request; tokens resolve exact supplied artifacts, never fuzzy matches.
# P0 names are the user's eleven explicitly repeated priority items.
REQUESTS=[
 ('bandits','马贼','挂机','P1',['003837b4','0036e251','00378b88'],'combat,navigation,loot'),
 ('songliao','宋辽','活动','P1',['003771af'],'player_objects,pvp,team'),
 ('pvp','团战','活动','P1',['00368d15'],'player_objects,pvp,team'),
 ('heal_support','加血机','工具','P1',['0037bcdc'],'player_objects,team_heal,team'),
 ('roadbook','路书挖宝','日常','P1',['00292f75','0029bb09','0029f73e','002a33bc'],'combat,navigation,quest_state,loot'),
 ('new_treasure_map','寻宝图挖宝','日常','P1',['002981ea'],'navigation,quest_state,loot'),
 ('dig_map','藏宝图挖宝','日常','P1',['0038f06e'],'combat,navigation,quest_state,loot'),
 ('mainline','主线任务','日常','P1',['0023d14c','0024e474'],'combat,navigation,quest_state,quest_submit'),
 ('novice_1_40','新手 1–40','日常','P1',['0026bf4a'],'combat,navigation,quest_state,quest_submit'),
 ('shimen','师门任务','日常','P0',['0025fb7b'],'combat,navigation,quest_state,quest_submit'),
 ('qianbai','千百渡他','副本','P0-D',['00445897','00445fe7','00446737'],'combat,team,dungeon_stages,dungeon_result'),
 ('chuge','楚歌难渡','副本','P0-D',['00446ef5','004486c3','00449e91'],'combat,team,dungeon_stages,dungeon_result'),
 ('yuhua','虞花苦渡','副本','P0-D',['0044b65f','0044d295','0044eec5'],'combat,team,dungeon_stages,dungeon_result'),
 ('wujian','渡别乌江','副本','P0-D',['00453a9f','00454fcd','00456501'],'combat,team,dungeon_stages,dungeon_result'),
 ('xiaoaci','暗袭萧阿刺','副本','P0-D',['0045934a','0045a610','0045b8d6'],'combat,team,dungeon_stages,dungeon_result'),
 ('xiakexing','侠客行','副本','P0-D',['0043595d'],'combat,team,dungeon_stages,dungeon_result'),
 ('chuhan','楚汉之战','副本','P0-D',['00444592'],'combat,team,dungeon_stages,dungeon_result'),
 ('nixi','逆袭','副本','P0-D',['0042de32'],'combat,team,dungeon_stages,dungeon_result'),
 ('shengjing','盛景繁绘','活动','P1',['0043776f'],'quest_state,quest_submit'),
 ('jinwen','使用金纹铜钱','活动','P1',['0043a061'],'quest_state,inventory_result'),
 ('qingji','情寄虞兮','活动','P1',['00450a02'],'quest_state,navigation,quest_submit'),
 ('xiagu','侠骨丹心','活动','P1',['00457c3f'],'combat,quest_state,quest_submit'),
 ('death_stats','死亡统计','工具','P1',['00382f48'],'death_events'),
 ('tanyinyuan','叹姻缘','活动','P1',['00451266'],'quest_state,quest_submit'),
 ('gather_script','采集脚本','生活','P1',['0035f720'],'resource_objects,gathering,inventory_result'),
 ('plant_script','种地脚本','生活','P1',['003607d9'],'planting,inventory_result'),
 ('gather_tianmai','采集天脉玄晶','生活','P1',['003921c4'],'resource_objects,gathering,inventory_result'),
 ('xingluo','星落九野','活动','P1',['003824d1'],'combat,quest_state,dungeon_result'),
 ('guild_guard','戍卫帮会','活动','P1',['0035a761'],'combat,team,quest_state'),
 ('couple','伉俪情深','日常','P1',['00252a6a'],'combat,navigation,quest_state,quest_submit'),
 ('child_adopt','子女领养','日常','P1',['0025bf77'],'child_identity,quest_state,quest_submit'),
 ('yuandan','元丹坊','生活','P1',['0047029f'],'shop_purchase,inventory_result'),
 ('tianhuang','天荒商行','生活','P1',['00471348'],'shop_purchase,inventory_result'),
 ('zhenyuan','真元凝元','生活','P1',['0034e5e3'],'inventory_result,quest_state'),
 ('mingshi_exchange','名士斋礼物兑换','生活','P1',['003461b4'],'inventory_result,quest_state'),
 ('child_parents','子女天下父母心','日常','P0',['002585c4'],'combat,child_identity,quest_state,quest_submit'),
 ('pet_sell_npc','抓珍兽卖NPC','生活','P0',['002ac448'],'pet_objects,pet_capture,pet_sell_npc,pet_identity'),
 ('pet_shop','抓珍兽上架商会','生活','P0',['002ac35d'],'pet_objects,pet_capture,pet_listing,pet_identity'),
 ('pet_comprehension','抓成年提悟','生活','P0',['002aa437'],'pet_objects,pet_capture,pet_comprehension,pet_identity'),
 ('fish_process','钓鱼加工','生活','P0',['00367515'],'resource_objects,fishing_process,inventory_result'),
 ('dali_flower','大理种花','生活','P0',['0036c43f'],'planting,quest_state,inventory_result'),
 ('tea_biluo','清泉茗茶·碧螺春','活动','P1',['0043c03c'],'gathering,quest_state,quest_submit'),
 ('tea_longjing','清泉茗茶·龙井','活动','P1',['0043e0aa'],'gathering,quest_state,quest_submit'),
 ('tea_puer','清泉茗茶·普洱','活动','P1',['00440116'],'gathering,quest_state,quest_submit'),
 ('tea_zhuye','清泉茗茶·竹叶青','活动','P1',['00442184'],'gathering,quest_state,quest_submit'),
 ('beijiu','杯酒尽江湖','日常','P1',['0042af8e'],'quest_state,quest_submit'),
 ('guild_box','帮会福利宝箱','活动','P1',['003521ee'],'loot,quest_state,inventory_result'),
 ('manor_encounter','庄园奇遇','生活','P1',['00353b78'],'combat,quest_state,quest_submit'),
 ('new_grind','新刷怪','挂机','P1',['00381690'],'combat,loot,navigation'),
 ('xunying','寻影九黎','日常','P0',['0025d97e'],'combat,navigation,quest_state,quest_submit'),
 ('routine','闲常治务','日常','P1',['0028b707'],'combat,navigation,quest_state,quest_submit'),
 ('child_quality','子女综合素养','日常','P1',['00259e6e'],'child_identity,quest_state,quest_submit'),
 ('jiuli_clear','清剿九黎余孽','日常','P0',['002842e0'],'combat,navigation,quest_state,dungeon_result'),
 ('fixed_rebels','定点抢反','活动','P0',['002a98ce'],'combat,spawn_detection,team,dungeon_result'),
 ('grab_box','抢箱子','活动','P0',['002b1de4'],'loot,interaction_skill,inventory_result'),
 ('wenhua','问画朔源','活动','P1',['00452b92'],'combat,navigation,quest_state,quest_submit'),
]
CAPABILITIES={
 'combat':('普通敌方目标战斗','partial'), 'navigation':('跨图导航与传送','partial'),
 'loot':('包裹/宝箱识别与拾取','unadapted'), 'player_objects':('玩家对象和关系读取','unadapted'),
 'pvp':('宋辽/团战敌我与目标规则','unadapted'), 'team':('队伍身份/跟随/阶段同步','partial'),
 'quest_state':('任务状态、次数及已完成读取','partial'), 'quest_submit':('任务接受/提交与回执','partial'),
 'dungeon_stages':('副本阶段和首领机制','per_task_required'), 'dungeon_result':('通关/离场/次数回执','per_task_required'),
 'inventory_result':('库存变化及物品结果确认','partial'), 'team_heal':('队友生命和治疗选中','unadapted'),
 'death_events':('死亡事件去重与统计','unadapted'), 'resource_objects':('资源点/采集对象枚举','unadapted'),
 'gathering':('采集状态和完成回执','unadapted'), 'planting':('地块/播种/生长/收获状态','unadapted'),
 'child_identity':('子女身份/成长任务状态','unadapted'), 'shop_purchase':('对应商店购买和限额','per_task_required'),
 'pet_objects':('野外珍兽枚举','unadapted'), 'pet_capture':('捕捉资格/提交/新增珍兽确认','unadapted'),
 'pet_sell_npc':('珍兽身份保护和 NPC 出售回执','unadapted'), 'pet_identity':('珍兽 GUID/品质/锁定/保护筛选','partial'),
 'pet_listing':('商会店铺/价格/上架回执','unadapted'), 'pet_comprehension':('成年材料筛选/提悟消耗确认','unadapted'),
 'fishing_process':('钓点/钓鱼动作/加工及产物确认','unadapted'), 'spawn_detection':('定点出现检测/归属/入场状态','unadapted'),
 'interaction_skill':('非敌方宝箱的交互动作','unadapted'),
}
PRIORITY_ORDER=['shimen','child_parents','xunying','jiuli_clear','fixed_rebels','grab_box',
                'pet_sell_npc','pet_shop','pet_comprehension','fish_process','dali_flower']
EXISTING_DUNGEONS={'002b8890':'zhenlong_combat','00313c18':'yanzi','002ef962':'shaoshi',
 '002e1226':'sijue','002fef1e':'piaomiao','002c0fc9':'bingsheng','002fe6b9':'langhuan',
 '002cf5a7':'wangling','002bb430':'sanshen','00302521':'guanshan','002bba5a':'xiaoxiao','002b54ac':'invasion'}
READERS={'ReadConfigBool','GetConfigBool','ReadConfigText','GetConfigText','ReadConfigInt','GetConfigInt','ReadConfigNumber','GetConfigNumber'}

def audit_module(meta,stage):
    token=Path(meta['listing']).stem.replace('.listing','')
    reader,proto=rules.load(token)
    assert rules.sha(reader.data)==meta['sha256']
    configs={};globals_=set();dynamic=0;loads=set()
    for fn in rules.walk(proto):
        regs={};K=fn['constants']
        for pc,w in enumerate(fn['code']):
            op=rules.undump.OPS[w&127];a=(w>>7)&255;b=(w>>16)&255;c=(w>>24)&255;bx=(w>>15)&0x1ffff
            if op=='GETTABUP':
                if b<len(fn['upvalue_names']) and fn['upvalue_names'][b]=='_ENV':
                    regs[a]=('global',K[c]);globals_.add(K[c])
                else: regs.pop(a,None)
            elif op=='LOADK': regs[a]=('literal',K[bx])
            elif op=='MOVE': regs[a]=regs.get(b)
            elif op=='CALL':
                target=regs.get(a)
                if target and target[0]=='global' and target[1] in READERS:
                    args=[regs.get(a+i) for i in (1,2)] if b>=3 else []
                    if len(args)==2 and all(x and x[0]=='literal' and isinstance(x[1],str) for x in args):
                        section,key=args[0][1],args[1][1];identity=(target[1],section,key)
                        item=configs.setdefault(identity,dict(reader=target[1],section=section,key=key,locations=[]))
                        item['locations'].append(dict(lines=[fn['line'],fn['last_line']],pc=pc+1))
                    else: dynamic+=1
                if target==('global','LoadScript'):
                    arg=regs.get(a+1)
                    if b>=2 and arg and arg[0]=='literal' and isinstance(arg[1],str): loads.add(arg[1])
                regs.clear()
            elif op in ('JMP','FORPREP','FORLOOP','TFORPREP','TFORLOOP','EQ','EQK','EQI','LT','LE','TEST','TESTSET','RETURN','RETURN0','RETURN1'): regs.clear()
            elif op not in ('SETFIELD','SETTABUP','EXTRAARG','SETLIST','VARARGPREP'): regs.pop(a,None)
    result=dict(token=token,name=Path(meta['source'].replace('\\','/')).stem,source=meta['source'],
        source_sha256=meta['sha256'],global_dependencies=sorted(globals_),literal_module_loads=sorted(loads),
        direct_config_reads=sorted(configs.values(),key=lambda x:(x['section'],x['key'],x['reader'])),
        dynamic_config_reads=dynamic,config_discovery='direct literal calls in straight-line bytecode only; dynamic and indirect keys remain unknown',
        configuration_coverage='partial',indirect_configuration_keys_unknown=True,
        original_rules_rewritten=False,runtime_enabled=False)
    if stage:
        converted=reader.transcode(proto);proof=rules.check_transcode(reader,proto,converted)
        result.update(resource='original/'+token+'.luac',resource_sha256=rules.sha(converted),
                      resource_bytes=len(converted),bytecode_proof=proof)
        return result,converted
    return result,None

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--write',action='store_true');args=parser.parse_args()
    source=json.loads((ROOT/'artifacts/reference-tlzz/bytecode/index.json').read_text(encoding='utf-8'))
    by_token={Path(m['listing']).stem.replace('.listing',''):m for m in source['chunks']}
    catalog=json.loads((ROOT/'design/task-catalog.json').read_text(encoding='utf-8'));tasks={t['id']:t for t in catalog['tasks']}
    cache={};staged={};features=[]
    def module(token,stage=False):
        if token not in cache:
            cache[token],data=audit_module(by_token[token],stage)
            if data is not None: staged[token]=data
        elif stage and token not in staged:
            cache[token],staged[token]=audit_module(by_token[token],True)
        return cache[token]
    def register(identity,name,category,priority,tokens,deps,kind):
        modules=[module(t,identity in PRIORITY_ORDER) for t in tokens]
        existing=tasks.get(identity)
        integrated=existing and existing.get('adapter_status') in ('integrated_pending_live','verified_luoyang_nearby','adapted')
        feature=dict(id=identity,name=name,category=category,priority=priority,kind=kind,
            status='integrated_pending_live' if integrated else 'planned_pending_adapter',
            runtime_enabled=bool(integrated),source_tokens=tokens,capability_dependencies=deps,
            blocked_by=[CAPABILITIES[d][0] for d in deps] if not integrated else [],
            proposed_parameters=parameters(identity,kind),completion_contract=['check','run','verify','report'],
            task_id=identity)
        features.append(feature)
        if not existing:
            existing=dict(id=identity,name=name,aliases=[],category=category,family='planned',adapter_status='planned_pending_adapter')
            catalog['tasks'].append(existing);tasks[identity]=existing
        if existing['name']!=name and name not in existing.get('aliases',[]):
            existing.setdefault('aliases',[]).append(name)
        existing.update(plan_priority=priority,plan_feature=identity)
        if not integrated:
            existing.update(adapter_status='planned_pending_adapter',planning_only=True,
                source_refs=['tlzz:'+m['source'] for m in modules],source_scope='原规则已定位；等待宿主及完成契约接入',
                planning_blockers=feature['blocked_by'],settings=feature['proposed_parameters'])
    for identity,name,category,priority,tokens,deps in REQUESTS:
        register(identity,name,category,priority,tokens,deps.split(','),'requested')
    dungeons=json.loads((ROOT/'scripts/dungeons/catalog.json').read_text(encoding='utf-8'))['entries']
    for d in dungeons:
        token=d['source_token'];identity=EXISTING_DUNGEONS.get(token,'dungeon_'+token)
        register(identity,d['name'],'副本','P0-D',[token],['combat','team','navigation','dungeon_stages','dungeon_result'],'dungeon')
    plan=dict(schema=1,review_date='2026-10-26',source_dll_sha256=source['source_sha256'],
        priority_policy={'P0':'用户明确点名的十一项优先任务','P0-D':'副本和战斗活动优先线','P1':'其他已纳入需求'},
        priority_task_order=PRIORITY_ORDER,
        capability_contracts={k:dict(name=v[0],state=v[1]) for k,v in CAPABILITIES.items()},
        features=features,modules=sorted(cache.values(),key=lambda x:x['token']),
        requested_group_count=len(REQUESTS),source_dungeon_count=len(dungeons),
        staged_priority_modules=len(staged),new_executable_tasks=0,source_executed=False,
        acceptance=['真实条件前检','动作后状态确认','完成/限额/未知分开','暂停/停止/游戏退出清理','角色配置隔离','实机单轮验收'])
    catalog['review_date']='2026-10-26';catalog['scope']='已接入任务与用户完整接入规划；planning_only 条目禁止执行'
    assert len(tasks)==len(catalog['tasks']) and len(PRIORITY_ORDER)==11
    OUT.mkdir(parents=True,exist_ok=True)
    if args.write:
        directory=ROOT/'scripts/planning';(directory/'original').mkdir(parents=True,exist_ok=True)
        for token,data in staged.items(): (directory/'original'/f'{token}.luac').write_bytes(data)
        (directory/'feature-plan.json').write_text(json.dumps(plan,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        (ROOT/'design/task-catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        write_document(plan)
    summary=dict(features=len(features),requested_groups=len(REQUESTS),dungeon_sources=len(dungeons),
        source_modules=len(cache),priority_tasks=PRIORITY_ORDER,staged_original_modules=len(staged),
        direct_configuration_reads=sum(len(m['direct_config_reads']) for m in cache.values()),
        dynamic_configuration_reads=sum(m['dynamic_config_reads'] for m in cache.values()),
        catalog_tasks=len(catalog['tasks']),new_executable_tasks=0,written=args.write,source_executed=False)
    (OUT/'generation.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(summary,ensure_ascii=False,indent=2))

def parameters(identity,kind):
    def f(key,label,type='text',default='',**extra): return dict(key='plan_'+key,label=label,type=type,default=default,planning_only=True,**extra)
    common=[f('rounds','目标次数 / 轮数','number',1,min=1,max=100),f('budget','支出上限（游戏内货币单位待映射）','number',0,min=0,max=1000000)]
    if identity.startswith('pet_'):
        extra=[f('map','捕捉地图'),f('pet_name','目标珍兽'),f('keep','保留 / 保护名单'),f('limit','单轮处理数量上限','number',1,min=1,max=50)]
        if identity=='pet_shop': extra += [f('shop','商会店铺'),f('price','上架价格','number',0,min=0,max=1000000)]
        if identity=='pet_comprehension': extra += [f('comprehension','目标悟性','number',1,min=1,max=100)]
        return extra+common
    if identity in ('fish_process','dali_flower','plant_script','gather_script','gather_tianmai'):
        return [f('target','鱼种 / 作物 / 资源'),f('map','地图 / 地点'),f('quantity','目标产物数量','number',1,min=1,max=10000)]+common
    if identity in ('child_parents','child_adopt','child_quality'): return [f('child','子女名称'),f('materials','允许材料名单')]+common
    if identity in ('shimen','xunying','jiuli_clear','fixed_rebels','grab_box'):
        return [f('target','目标 / 任务分支'),f('map','地图 / 定位点')]+common
    if kind=='dungeon': return [f('team','队伍 / 角色职责'),f('difficulty','难度 / 路线')]+common
    return common

def write_document(plan):
    lines=['# 用户功能接入总计划（2026-10-26）','',
      '依据用户本轮清单与提供的天龙助手原模块生成。所有功能均纳入；原模块已定位、原 Lua 已入库、宿主已接入和实机通过分别记录。此文件及规划配置不代表任务可执行。',
      '', '## 优先顺序','',
      '两条优先线并行安排依赖：十一项明确点名任务（P0）与普通副本、战斗活动（P0-D）。先补任务状态、战斗/队伍、对象枚举与动作回执，再按依赖闭环逐项开放；不按按钮数量假报进度。',
      '', 'P0 实施顺序：'+ ' → '.join(next(f['name'] for f in plan['features'] if f['id']==i) for i in PRIORITY_ORDER)+'。',
      '', 'P0-D 普通副本先复核燕子坞、四绝庄，再扩少室山、缥缈峰、王陵、福地、三神、兵圣、观山海等；每项分别确认入场、阶段、首领、离场及完成回执。原来源全部 32 份列在下方，不局限棋局。',
      '', '战斗活动包含千百渡他、楚歌难渡、虞花苦渡、渡别乌江、暗袭萧阿刺的各难度，以及侠客行、楚汉之战、逆袭。以用户提供源版本为依据，当前服务器开放期、资格与次数还需核对。',
      '', '## 完整清单','', '|优先级|功能|来源模块|缺失或需复核的能力|', '|---|---|---|---|']
    mods={m['token']:m for m in plan['modules']}
    for f in plan['features']:
        names='、'.join(mods[t]['name'] for t in f['source_tokens'])
        lines.append('|'+ '|'.join([f['priority'],f['name'],names,'；'.join(f['blocked_by']) or '已接入，仍待实机验收'])+'|')
    lines += ['', '## 配置和完成标准','',
      '- 原规则：优先保留原 Lua 的数值、指令、分支与等待；本轮十一份优先模块只转码 GBK 字符串到 UTF-8，未执行、未改主流程。',
      '- 配置：直接配置读取保留 section/key/reader/位置；动态键和公共模块的间接键另记未知。客户端展示的 plan_ 参数只是规划草稿，尚未映射原规则，不会据此执行。',
      '- 抓宠三项分别实现捕捉、宠物身份/锁定/品质筛选、卖 NPC、上架商会、成年提悟的结果确认；出售/消耗必须有明确目标和保护规则。出战宠物生命读取不等于野外抓宠接口已实现。',
      '- 加血机需要队友对象和队友生命/目标读取；现有自身/出战宠物恢复不能冒充团队治疗。宋辽/团战分别核对阵营和玩家目标，不复用怪物敌对判断。',
      '- 抢箱子需要宝箱对象和交互动作，不把普通敌方技能释放当作开箱；采集、钓鱼、种地分别确认资源点、动作状态、库存增量及停止条件。',
      '- 每项 check → run → verify → report；已完成、次数上限、材料不足、未知状态分开。动作返回或 Lua 退出不能替代任务完成。',
      '- 启用前：接口与配置映射、离线异常回归、暂停停止/进程退出、多角色隔离、实机单轮和队列衔接通过。',
      '', '## 程序中的入口','',
      '“所有功能”可搜索全部规划项，并以“优先接入”筛选 P0/P0-D；“信息 → 功能接入规划”查看来源、依赖与状态。规划项可以保存草稿，不开放运行。',
      '', '机器清单：scripts/planning/feature-plan.json；十一份原规则：scripts/planning/original/*.luac。它们属于集中资源，未给运行清单新增可执行适配器。',
      '', '本轮不生成安装器、ZIP 或新发布目录。开发构建沿用 .tools/build/client-0.15.0；用户自行打包使用 tools/build-installer.ps1。', '']
    (ROOT/'docs/FEATURE_IMPLEMENTATION_PLAN_2026-10-26.md').write_text('\n'.join(lines),encoding='utf-8')

if __name__=='__main__': main()
