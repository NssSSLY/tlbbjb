#pragma once
#include <cstdint>
#include <cstring>
#include <cwchar>
namespace tlbb::gameplay {
// Fixed Lua 5.0 snippets executed by TLBBGameplayBridge.dll in the game's LuaPlus state.
// IPC carries only a snippet id and typed arguments; no script text or function name crosses it.
// Every game call below is evidenced by Game.exe exports/static disassembly, the game's own
// interface scripts or strings in the reference program built for this client version.
enum Snippet:uint32_t {
    RunTo=1,          // AutoRunToTargetEx(x, y, scene)
    TalkNpc=2,        // AutoRunToTargetEx + SetAutoRunTargetNPCName, as the game's UI does
    NpcTarget=3,      // SetAutoRunTargetNPCName(name)
    QuestOptions=4,   // DataPool:GetNPCEventList_* (read)
    QuestOption=5,    // QuestFrameOptionClicked(index, scriptId, extra) for the matched option
    QuestButton=6,    // Accept / Continue / Complete of the NPC dialog
    BagCount=7,       // PlayerPackage:EnumItem("base", i) (read)
    PlayerData=8,     // Player:GetData(key) for fixed keys (read)
    TeamCount=9,      // DataPool:GetTeamMemberCount() (read)
    XScript=10,       // fixed server script requests
    UiCall=11,        // fixed <Window>_Env functions
    WindowVisible=12, // <Window>_Env.this:IsVisible() (read)
    CloseAll=13,      // CloseAllWindow()
    UiEvent=14,       // PushEvent(fixed event)
    // Bank and temporary bag (BigBank / Packet_Temporary interface scripts, Bank:* methods).
    BankState=15,     // Bank/BigBank visible, bank money, carried money (read)
    BankBig=16,       // switch the small bank window to BigBank, as Bank_Env does
    BankMoney=17,     // Bank:GetMoneyFromBank / Bank:SaveMoneyToBank
    BankItem=18,      // count a named bank item; optionally take one stack via BigBank_Item*:DoAction
    BagStore=19,      // store one named bag stack while the bank is open
    TempBag=20,       // move named or all temporary-bag items to the bag
    // Instance sweep (SweepAll / SweepPage).
    SweepCount=21,    // GetSecKillFuBenCount() (read)
    SweepEnum=22,     // EnumSecKillTable + campaign counts (read)
    SweepData=23,     // GetSecKillData() (read)
    SweepOpenPage=24, // OpenSecKillPage(fubenId, 0)
    SweepBoss=25,     // select the next unfinished boss on SweepPage
    CloseNamed=26,    // CloseWindow(fixed window, true)
    // Shop profit and gem compose (PlayerShop:*, LifeAbility:Do_Combine, GetItemBindStatus).
    ShopMoney=27,     // PlayerShop:ApplyMoney("draw_ok", n) while PS_ShopMag is open
    GemList=28,       // gems in bag / bank / temporary bag with bind state and level (read)
    GemCombine=29,    // LifeAbility:Do_Combine(gem, talisman, mode, odds) on Gemcompose
    CombatScan=30,    // bounded native monster snapshot; no selection or actions
    CombatCast=31,    // revalidate a hostile NPC, then fixed skill action
    CombatSkill=32,   // find a learned skill action by exact name (read)
    CombatName=33,    // Target:GetNpcName(client id) (read)
    // System prompts (on-screen DebugListBox, a CEGUI Listbox) and dictionary text, both read-only.
    DebugMessages=34, // native: texts currently shown in DebugListBox_ListBox
    DictText=35,      // GetDictionaryString(key)
    // NPC dialog list, guild city and activity boxes (common.lua / common_2.lua helpers), read-only.
    NpcEventItem=36,  // DataPool:GetNPCEventList_Item(idx) text while Quest is visible
    NpcEventAll=37,   // all NPC event texts joined with spaces, and their count
    GuildInfo=38,     // Guild:GetMyGuildDetailInfo('ID'/'CityName'); asks for details when unknown
    ActiveBox=39,     // first unclaimed daily activity box from mission 579's round bits
    // Remaining 天龙助手 batch-1 helpers (bag.lua / common_2.lua / functions.lua / player.lua).
    UseBagItem=40,    // PlayerPackage:UseItem on a whitelisted item name, optional bind filter
    MissionFind=41,   // mission slot, mission id and display field 7 (read)
    MissionVar=42,    // DataPool:GetPlayerMission_Variable(slot, n) when in use (read)
    PlayerState=43,   // Player:GetState() (read)
    Dismount=44,      // Player:DispelBuffByName('坐骑：')
    DoubleTimer=45,   // MainMenuBar_Doub_Watch "Timer" property, 0 when hidden (read)
    VipLevel=46,      // DataPool:GetAccVipLevel() (read)
    MsgBoxText=47,    // MessageBox_Self OK when its text contains a whitelisted phrase
    QuitGame=48,      // QuitApplication('quit'): closes the game client
    XingYunCount=49,  // 幸运快活三: heads without a tooltip on XingYun (read)
    VipRefresh=50,    // Target:SendUpdateVipInfoMsg()
    BagCountIn=51,    // count of a named item in the material bag (1) or the temporary bag (2) (read)
    ItemList=52,      // name/count totals of items whose name contains the text: bag 0, material 1, temporary 2, open bank 3 (read)
    CompoundSelect=53,// CaiLiaoCompound_List:SetItemSelectByItemID(whitelisted id)
    AttackAttr=54,    // index of the first entry of Player:GetAttackAttr() (read)
    CohesionCost=55,  // 凝聚九天玉碎: item count and money for the next cohesion (read)
    LifeCompose=56,   // ComposeItem_Begin(recipe 400-407, 99, -1): 加工材料 life-skill recipes
    BagSpace=57,      // free slots in the bag (0) or the material bag (1) (read)
    WuhunList=58,     // 御瑶盘/琉璃焰 in the bag: slot, bind state, EXTRALEVEL (read)
    WuhunCompound=59, // re-checks both bag slots hold 御瑶盘/琉璃焰, then OnWuHunCompoundNew(a, b, 1)
    MissionDesc=60,   // description text of the mission whose memo equals the text (read)
    UiEnabled=61,     // a whitelisted button's "Disabled" property is "False" (read)
    EquipAdjust=62,   // 装备资质鉴定: FinishAdjust for every bag equipment with zero aptitude points
    CityEnemyHas=63,  // the guild id is already in either city enemy list (read)
    CityEnemyAsk=64,  // City:AskEnemyList(0) and (1)
    OpenAddEnemy=65,  // City:OpenAddEnemyDlg("BenFu", guild id): opens the declaration dialog only
    // 庄园（BieYeUI / BieYeFurniture）
    BieYeScene=66,    // BieYeFurniture:IsBieYeScene() (read)
    BieYeProduct=67,  // BieYeUI:GetBieYeBaseInfo("ProductInfo", slot 0-4): state, time (read)
    BieYeAsk=68,      // BieYeUI:AskBieYeBaseInfo(5)
    BieYeGardeners=69,// free own gardeners (of 2) and free hired gardeners (of 4) (read)
    WuhunText=70,     // WuhunQuest OK when its text contains a whitelisted phrase
    ExamRead=71,      // 科举 Examination question and five answer texts, tab separated (read)
    // Shops: each re-implements one reference purchase routine for a single named item.
    HuoYueBuy=72,     // 活跃代币商店 (1 华玉集/寒纹玉, 2 云锦行): BuyItem(888393)
    DividendBuy=73,   // 元宝商店红利半价页：NpcShop:BulkBuyItem at the half-price tiers
    HonourBuy=74,     // 战功商店：City:DoHonourShopBuy
    GuildShopBuy=75,  // 帮会百宝阁：City:DoGuildShopBuy
    T3ShopBuy=76,     // 中都行商：NpcShop:LuaFnT3ShopBuyItem
    ChongLouBuy=77,   // 玲珑阁：MBuyConfirm(888431)
    GuiShiBuy=78,     // 鬼市千金阁：GUISHI_ONBUY
    GoldGiftRead=79,  // 鎏金礼匣 reward choices (read)
    GoldGiftChoose=80,// 鎏金礼匣 choose 1-3 and claim
    // 活动扫荡、庄园血脉觉醒、绝学引导、武林印
    UseBoxItem=81,    // PlayerPackage:UseItem on the first bag stack with this exact name; the name must contain 宝箱
    HuoDongCount=82,  // Lua_GetSecKillFuBenCount_HuoDong() (read)
    HuoDongEnum=83,   // EnumSecKillTable_HuoDong(idx) and its campaign counts (read)
    AwakeRead=84,     // BieYePetBar_Awake list 1 and 2 item texts (read)
    AwakeAdd=85,      // BieYePetBar_Awake: select a list item (0) or put the selected pet in (1)
    SectOper=86,      // Player:Lua_AskSectOper(0, SectId of zong men talent idx)
    NpcShopBuy=87,    // NpcShop:BulkBuyItem(idx,1,0) for the first booth item with a whitelisted name
    // 修理装备、买卖补给
    EquipDur=88,      // equipped slot 0-21 below the durability threshold: tid, define id, repairs left, name (read)
    EquipRepair=89,   // OnEquipRepairNew(805027) on an equipped slot: VIP remote repair (0) or at 薛菲 (1)
    EquipRestore=90,  // EquipFaileTimesOnEquip(809265): restore repair count with a 润物露 from the bag
    WuhunLife=91,     // equipped 武魂 life below the threshold: 1 and its name (read)
    WuhunRepair=92,   // Kfs_AddLifeNew(809270) on the equipped 武魂 with a 武魂延寿丹 from the bag
    BagSell=93,       // sell one named bag stack to the open NPC shop, optional bind filter
    // 点修炼、点心法
    XiuLianInfo=94,   // Player:GetXiuLianMiJiInfo(idx 0-20): jingjie, level, max level, money, exp (read)
    XinfaRead=95,     // xinfa slot 1-8: id, level, whether money and exp cover the next level (read)
    XinfaStudy=96,    // SkillsStudyFrame_study on the xinfa in slot 1-8
    // 材料点金、名士赠礼、宝石雕琢、合成龙纹
    DianJin=97,       // DianJin(892944) with a 点金玉 and a 3级棉布/秘银 picked by bind mode 0-3
    XZGift=98,        // OpenXZ3_GiveGift(888052) for a whitelisted hero/gift pair when the gift can still be given
    GemCarve=99,      // OnGemCarve(800117): a named material-bag gem with the 宝石雕琢符 of its level
    LwScan=100,       // slot-19 龙纹 equipped, then bag 龙纹 / 龙纹玉灵 / 铸纹玉 with level and bind (read)
    LwUnequip=101,    // SelfEquip_Equip_Click(25,0) while slot 19 holds a 龙纹
    LwCombine=102,    // PlayerPackage:Lw_Op_Do(1, main, material, stuff) after re-checking both are 龙纹 items
    LwEquip=103,      // use a bag 龙纹 (equips it), as Bag:ItemBtnClicked does
    OpenMonthlySign=104, // official welfare UI uses OpenMonthlySign(1)
    SelfTarget=105,   // select the player itself (identity filled in by the bridge) so attacks and chasing stop
    SnippetLast=SelfTarget
};
struct XScriptRule { const char *function; int script; int params; int low[2]; int high[2]; };
// Each entry comes from one reference rule listed in scripts/legacy/manifest.json.
inline constexpr XScriptRule xscripts[]={
    {"GetTodayHuoYuePointGift",892921,0,{0,0},{0,0}},   // 领取良缘会奖励
    {"SafeScoreGetBonus",890643,0,{0,0},{0,0}},         // 领取安全评分奖励
    {"CallByClient",888267,1,{1,0},{10,0}},             // 领取群豪榜奖励
    {"GetExp_ByMoney",892659,1,{0,0},{0,0}},            // 找回经验
    {"MartialLastDayMonsterReward",507010,2,{1,0},{1,0}},// 找回内息
    {"GetPrize",885577,1,{1,0},{4,0}},                  // 祈鸿金
    {"GetDayReward",892664,1,{1,0},{8,0}},              // 战江湖
    {"OnAugury",889336,1,{1,0},{4,0}},                  // 领取活跃好礼（每日 4 档）
    {"OnAugury_week",889336,1,{1,0},{2,0}},             // 领取活跃好礼（每周 2 档）
    {"OnUseVIP",889644,1,{5,0},{5,0}},                  // 领取周道具奖励（VIP 周礼）
    {"OnUseVIP",889644,1,{11,0},{11,0}},                // 双倍经验随身领取/冻结（VIP）
    {"LingQu",501016,1,{1,0},{23,0}},                   // 豪气满江湖：领取红包
    {"Buy",501016,2,{1,1},{3,1}},                       // 豪气满江湖：买红包（花元宝/金币）
    {"DuiHuanOK",890174,0,{0,0},{0,0}},                 // 兑换精金石
    {"OnFuBenSecKill",100003,1,{1,0},{999,0}},          // 活动扫荡
    {"AskXiuLianLevelUp",2099,2,{171,0},{171,20}},      // 点修炼：升级（扫地神僧）
    {"AskXiuLianAdvanceJingJie",2099,2,{171,0},{171,20}},// 点修炼：提升境界
};
struct UiRule { const char *window; const char *function; int args; int low; int high; bool visible; };
inline constexpr UiRule uiCalls[]={
    {"Token_Shop","Token_Shop_GetReward_Click",1,1,5,false},
    {"WuhunQuest","WuhunQuest_Bn1Click",0,0,0,true},
    {"Xichunchi_Prize2","Xichunchi_Prize2_Reward_Clicked",1,1,2,false},
    {"MessageBox_Self3","MessageBox_Self3_OnOk",0,0,0,true},
    {"MessageBox_Self","MessageBox_Self_OK_Clicked",0,0,0,true},
    {"ExorciseEvil","ExorciseEvil_LevelBox_Clicked",0,0,0,false},
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_OpenSecKillBox",0,0,0,false},
    {"Packet","Packet_Temporary_BtnClick",0,0,0,false},
    {"SweepPage","SweepPage_OnBossButton",1,1,6,true},
    {"SweepPage","SweepPage_OnOkClicked",0,0,0,false},
    {"SanShen_BaoXiang","SanShen_BaoXiang_OpenLingfu",0,0,0,true},
    {"SanShen_BaoXiang","SanShen_BaoXiang_OpenFree",0,0,0,true},
    // 战江湖、行笔绘伏夏、山河赴约、霸王别姬颂千年（只放行原规则用到的参数）
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_Clicked",1,35,35,false},
    {"HeXinChun","HeXinChun_ChangeTabIndex",0,0,0,false},
    {"ZhanJiangHu","ZhanJiangHu_ClickGetHFReward",1,1,2,false},
    {"XiGua_Guide","XiGua_Guide_Clicked",1,4,4,false},
    {"XiGuaJie_Activity","XiGuaJie_Activity_Start_Clicked",0,0,0,false},
    {"XiGuaJie_Activity","XiGuaJie_Activity_GetLichengReward_Clicked",1,1,5,false},
    {"XiGuaJie_Activity","XiGuaJie_Activity_GetReward_Clicked",1,1,3,false},
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_TeSeServerCliked",1,33,33,false},
    {"JiangHuShiJi","JiangHuShiJi_Click",1,1,1,false},
    {"JiangHuShiJi_Popup_Two","JiangHuShiJi_Popup_Two_LingQu",0,0,0,false},
    {"QiXi_Guide_2026","QiXi_Guide_2026_ActionClicked",1,3,3,false},
    {"XiQuLianDong","XiQuLianDong_GetGiftClicked",0,0,0,false},
    // 帮庄 / 日常领取：领取战功奖励、提交紫微灵草
    {"T3ZhanGongGet","T3ZhanGongGet_OnOKClicked",0,0,0,true},
    {"MessageBox_Self2","MessageBox_Self2_Ok_Clicked",0,0,0,true},
    {"ThreeCity_ZiWei_Change","ThreeCity_ZiWei_Change_Confirm",0,0,0,true},
    // 幸运快活三、领取周道具奖励（批量使用确认框）
    {"XingYun","Play_Ani",1,1,20,true},
    {"XingYun","XingYun_Close",0,0,0,true},
    {"Item_MultiUse","Item_MultiUse_BuyMulti_Clicked",0,0,0,true},
    // 第二批：勾天彩合成/兑换、兑换王权御玺、合成魂玉
    {"GouTianCai_HC","GouTianCai_HC_OnOK",0,0,0,true},
    {"T3XinTianWai_Guide","T3XinTianWai_Guide_OnClose",0,0,0,true},
    {"ShenqiSX_HY","ShenqiSX_HY_OK_Clicked",0,0,0,true},
    // 合成棉布/秘银/精铁（材料合成界面）、凝聚九天玉碎
    {"CaiLiaoCompound","CaiLiaoCompound_OnMaxNum",0,0,0,true},
    {"CaiLiaoCompound","CaiLiaoCompound_OK_Click",0,0,0,true},
    {"EquipBaoJian_Cohesion","EquipBaoJian_Cohesion_OnOK",0,0,0,true},
    {"EquipBaoJian_YuLuan_Tips","EquipBaoJian_YuLuan_Tips_OnSelect",1,0,10,true},
    {"EquipBaoJian_TianHuo_Tips","EquipBaoJian_TianHuo_Tips_OnSelect",1,0,10,true},
    {"EquipBaoJian_YunShui_Tips","EquipBaoJian_YunShui_Tips_OnSelect",1,0,10,true},
    // 倩心阁兑换
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_Clicked",1,77,77,false},
    {"Qixi_HuaJuan","Qixi_HuaJuan_ShopButton_Clicked",0,0,0,false},
    {"DaHuaQiXi_Shop","DaHuaQiXi_Shop_Clicked",1,1,11,false},
    // 第四批：活动领取
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_Clicked",1,60,60,false},
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_Clicked",1,70,70,false},
    {"Newserver_Hongbao","Newserver_Hongbao_Tab_Click",1,1,3,false},
    {"Newserver_Hongbao","NewServerHongbaoBossReward",0,0,0,false},
    {"Qixi_HuaJuan","Qixi_HuaJuan_Story_Goto",0,0,0,false},
    {"Qixi_HuaJuan","Qixi_HuaJuan_RewardClicked",1,1,1,false},
    {"New_SeasonCard","New_SeasonCard_Icon_GetClick",0,0,0,false},
    {"ErTongJieDaiBi","ErTongJieDaiBi_HuoYueClicked",0,0,0,false},
    {"ErTongJieDaiBi","ErTongJieDaiBi_CostPrize1Clicked",1,1,5,false},
    {"ErTongJieDaiBi","ErTongJieDaiBi_CostPrize2Clicked",1,1,5,false},
    {"Ertongjie_Guide","Ertongjie_Guide_Clicked",1,4,4,false},
    {"ErTongJieDaiBi","ErTongJieDaiBi_DuiHuanClicked",1,1,1,false},
    {"ErTongJieDaiBiPop","ErTongJieDaiBiPop_DuiHuanClicked",0,0,0,false},
    {"XiGua_Shop_Gift","XiGua_Shop_Gift_GetClick",0,0,0,false},
    {"XiGua_Guide","XiGua_Guide_Clicked",1,1,1,false},
    {"ZhongXiaItem","ZhongXia_OnActivate",0,0,0,false},
    {"ZhongXiaItem","ZhongXia_OnPray",0,0,0,false},
    {"Valentine_Gift","Valentine_Gift_GetClick",0,0,0,false},
    {"ShuangYe","ShuangYe_Button_Clicked",1,1,4,false},
    {"ShuangYe","ShuangYe_Reward_Clicked",1,1,4,false},
    {"ShuangYe","ShuangYe_UseQiufengyin_Clicked",0,0,0,false},
    {"Frost","Frost_ButtonClick",1,3,3,false},
    {"GiveGift","GiveGift_GiveOneTime",0,0,0,true},
    // 庄园养鱼 / 种植 / 采矿
    {"BieYe_Mini","BieYe_Mini_Sub",1,3,3,false},
    {"BieYePlanting","BieYePlanting_SwitchPage",1,1,2,true},
    {"BieYePlanting","BieYePlanting_ItemDataChanged",1,2,18,true},
    {"BieYePlanting","BieYePlanting_Buttons_Clicked",0,0,0,true},
    // 科举答题
    {"Examination","Examination_Button_Clicked",1,1,5,true},
    // 商店入口
    {"PlayerQuicklyEnter","PlayerQuicklyEnter_ActivityShedule",0,0,0,false},
    {"TodayCampaignListNew","TodayCampaignListNew_WeeklyShop_Clicked",0,0,0,false},
    // 活动扫荡、庄园血脉觉醒
    {"SweepAll","SweepAll_Tab_2_OnClick",0,0,0,true},
    {"BieYePetBar_Awake","BieYePetBar_Awake_Promote_Click",0,0,0,true},
    // 购买中级路书
    {"MessageBox_Self","MessageBox_Self_Cancel_Clicked",1,0,0,true},
    // 名士赠礼、合成龙纹
    {"GiveGift","GiveGift_GiveTenTime",0,0,0,true},
    {"MainMenuBar","MainMenuBar_SelfEquip_Clicked",0,0,0,false},
};
// WuhunQuest texts a task may confirm (庄园：元宝播撒 / 雇佣园丁).
inline constexpr const wchar_t *wuhunTexts[]={L"元宝",L"均有劳务在身"};
// Buttons whose enabled state a task may read: {window, button}.
struct ButtonRule { const char *window; const char *button; };
inline constexpr ButtonRule uiButtons[]={{"ZhongXiaItem","ZhongXiaItem_Button1"},{"ZhongXiaItem","ZhongXiaItem_Button2"}};
inline constexpr const wchar_t *wuhunItems=L"御瑶盘 琉璃焰";
// CaiLiaoCompound list ids: the material (秘银 10001 / 棉布 10002 / 精铁 10003), then its grade 0-3.
inline bool compoundId(int v){return (v>=0&&v<=3)||(v>=10001&&v<=10003);}
// Items that tasks may use from the bag, each from one reference rule.
inline constexpr const wchar_t *usableItems[]={L"银丝纳福礼箱",L"镂金迎福礼箱",L"镶玉招福礼箱",L"愿灵泉",
    L"豪气红包",L"侠情红包·武魂",L"侠义红包",L"侠情红包·令牌",L"初级灵草礼盒",L"100绑定元宝票",L"萌宠戏夏礼包",L"清荷礼包",
    L"眷梦情思礼包",L"彩蝶恩爱礼匣",L"青鸟悦爱礼匣",L"鸳鸯痴爱礼匣",L"鸾凤唯爱礼匣",L"1级宝石礼盒",L"义行令礼盒",
    L"鎏金礼匣·一",L"鎏金礼匣·二",L"鎏金礼匣·三",L"鎏金礼匣·四",L"鎏金礼匣·五",L"鎏金礼匣·六",L"鎏金礼匣·七",
    L"天龙工资书",L"青铜武林印",L"裹银武林印（1级）",L"镏金武林印（1级）",L"裹银武林印（2级）",L"镏金武林印（2级）",L"裹银武林印（3级）",
    L"镏金武林印（3级）",L"裹银武林印（4级）",L"镏金武林印（4级）",L"裹银武林印（5级）",L"镏金武林印（5级）",L"裹银武林印（6级）",L"镏金武林印（6级）",L"功力丹",
    L"小力丹",L"地力丹",L"天力丹",L"金玉富贵袋",L"小还丹"}; // last five: dungeon drops eaten by EatFubenItem (bag.lua)
// 名士赠礼: {hero, gift} pairs from the reference rule's built-in list.
struct GiftRule { const wchar_t *hero; const wchar_t *gift; };
inline constexpr GiftRule xzGifts[]={{L"乔峰",L"剑谱"},{L"乔峰",L"女儿红"},{L"王语嫣",L"胭脂盒"},{L"阿朱",L"湖州笔"},{L"天山童姥",L"酸角糕"},
    {L"天山童姥",L"澄心纸"},{L"慕容复",L"青玉佩"},{L"李秋水",L"满日弓"},{L"李秋水",L"玄铁矿石"},{L"梦姑",L"徐夫人匕"},{L"慕容复",L"琴箫曲谱"},
    {L"无崖子",L"朱砂印泥"},{L"虚竹",L"义山诗集"},{L"阿朱",L"三段锦紫牙"},{L"段誉",L"桃花泉奕谱"}};
// NPC shop items a task may buy one at a time (武林印：金创药、白玉瓶；买卖补给：药品与珍兽用品).
inline constexpr const wchar_t *shopItems[]={L"金创药",L"白玉瓶",L"归灵丸",L"回旋金球",L"珍兽滋补丹",L"珍兽回春丹",L"珍兽万补丹",L"珍兽回神丹",
    L"超级珍兽滋补丹",L"超级珍兽回春丹",L"珍兽延年丹"};
// MessageBox_Self texts accepted by specific task or route handlers. The last, empty entry is the
// original rules' unconditional MessageBox_Self_OK_Clicked(): OK on whatever box is shown.
inline constexpr const wchar_t *msgBoxTexts[]={L"解冻",L"确定进行冻结",L"需要使用角色自身经验",L"功力丹",L"你确认要开启跨场景自动寻路吗",L""};
inline constexpr const char *closableWindows[]={"SweepPage","Shop","BigBank","Bank","Packet_Temporary","Gemcompose","PS_ShopMag",
    "Quest","EquipBaoJian_YuLuan_Tips","EquipBaoJian_TianHuo_Tips","EquipBaoJian_YunShui_Tips","ZhongXiaItem","WuhunQuest","GoldRecycle_GiftShop","GiveGift","LongwenLevelUp","SelfEquip"};
inline constexpr const char *uiEvents[]={"OPEN_SAFECENTER_SAFESCORE"};
inline constexpr const char *playerKeys[]={"MONEY","MONEY_JZ","YUANBAO","BIND_YUANBAO","HP","MAXHP","MP","MAXMP","LEVEL","TODAYACTIVEPOINT","WEEKACTIVEPOINT","MEMPAI","EXP","HUILIUEXP","POWER"};
template<class T,int N>constexpr int count(const T (&)[N]){return N;}
struct SnippetArgs { int32_t ints[4]{}; double reals[3]{}; wchar_t text[49]{}; };
inline bool readableText(const wchar_t *text,bool identifier){
    size_t n=0;for(;n<48&&text[n];++n){
        const wchar_t c=text[n];
        if(c<32||c==127)return false;
        if(identifier&&!((c>=L'A'&&c<=L'Z')||(c>=L'a'&&c<=L'z')||(c>=L'0'&&c<=L'9')||c==L'_'))return false;
    }
    return n>0&&n<48&&!text[n];
}
inline bool emptyText(const wchar_t *text){return !text[0];}
inline bool flag(int v){return v==0||v==1;}
inline bool coordinate(double v){return v>=0&&v<=2048;}
inline bool validSnippet(uint32_t id,const SnippetArgs &a){
    const int *i=a.ints;
    switch(id){
    case RunTo:return i[0]>=0&&i[0]<=4095&&coordinate(a.reals[0])&&coordinate(a.reals[1])&&emptyText(a.text);
    case TalkNpc:return i[0]>=0&&i[0]<=4095&&coordinate(a.reals[0])&&coordinate(a.reals[1])&&readableText(a.text,false);
    case NpcTarget:case BagCount:return readableText(a.text,false);
    case QuestOption:return (i[0]==0||i[0]==1)&&readableText(a.text,false);
    case QuestButton:return i[0]>=1&&i[0]<=3&&i[1]>=0&&i[1]<=10&&emptyText(a.text);
    case PlayerData:return i[0]>=0&&i[0]<count(playerKeys)&&emptyText(a.text);
    case XScript:{
        if(i[0]<0||i[0]>=count(xscripts)||!emptyText(a.text))return false;
        const auto &r=xscripts[i[0]];
        for(int p=0;p<2;++p)if(p<r.params?(i[1+p]<r.low[p]||i[1+p]>r.high[p]):i[1+p]!=0)return false;
        return true;
    }
    case UiCall:{
        if(i[0]<0||i[0]>=count(uiCalls)||!emptyText(a.text))return false;
        const auto &r=uiCalls[i[0]];return r.args?(i[1]>=r.low&&i[1]<=r.high):i[1]==0;
    }
    case WindowVisible:return readableText(a.text,true);
    case QuestOptions:case TeamCount:case CloseAll:return emptyText(a.text);
    case UiEvent:return i[0]>=0&&i[0]<count(uiEvents)&&emptyText(a.text);
    case BankState:case BankBig:case SweepCount:case SweepData:case SweepBoss:return emptyText(a.text);
    case BankMoney:return (i[0]==1||i[0]==2)&&i[1]>=1&&i[1]<=2000000000&&emptyText(a.text);
    case BankItem:return flag(i[0])&&readableText(a.text,false);
    case BagStore:case BagSell:return i[0]>=0&&i[0]<=2&&readableText(a.text,false);
    case TempBag:return flag(i[0])&&(i[0]==1?emptyText(a.text):readableText(a.text,false));
    case SweepEnum:return i[0]>=0&&i[0]<=63&&emptyText(a.text);
    case SweepOpenPage:return i[0]>=0&&i[0]<=100000&&emptyText(a.text);
    case CloseNamed:return i[0]>=0&&i[0]<count(closableWindows)&&emptyText(a.text);
    case ShopMoney:return i[0]>=1&&i[0]<=2000000000&&emptyText(a.text);
    case GemList:return i[0]>=0&&i[0]<=2&&emptyText(a.text);
    case GemCombine:return i[0]>=0&&i[0]<=2&&i[1]>=3&&i[1]<=5&&i[2]>=1&&i[2]<=3&&readableText(a.text,false);
    case CombatScan:case CombatCast:
        return i[0]>=0&&i[0]<=4095&&i[1]>=-1&&i[1]<=10000000&&i[2]>=-1&&i[2]<=10000000
            &&(id==CombatScan?i[3]==0:(i[1]>=0&&i[2]>=0&&i[3]>=-1&&i[3]<=255))
            &&coordinate(a.reals[0])&&coordinate(a.reals[1])&&a.reals[2]>=3&&a.reals[2]<=60
            &&(id==CombatScan||i[3]==-1?emptyText(a.text):readableText(a.text,false));
    case CombatSkill:return readableText(a.text,false);
    case CombatName:return i[0]>=0&&i[0]<=10000000&&emptyText(a.text);
    case DebugMessages:return emptyText(a.text);
    case DictText:return readableText(a.text,true);
    case NpcEventItem:return i[0]>=0&&i[0]<=31&&emptyText(a.text);
    case NpcEventAll:case GuildInfo:case ActiveBox:return emptyText(a.text);
    case UseBagItem:return i[0]>=0&&i[0]<count(usableItems)&&i[1]>=0&&i[1]<=2&&flag(i[2])&&emptyText(a.text);
    case MissionFind:return readableText(a.text,false);
    case MissionVar:return i[0]>=0&&i[0]<=19&&i[1]>=0&&i[1]<=7&&emptyText(a.text);
    case Dismount:return !std::wcscmp(a.text,L"坐骑：");
    case MsgBoxText:return i[0]>=0&&i[0]<count(msgBoxTexts)&&emptyText(a.text);
    case PlayerState:case DoubleTimer:case VipLevel:case QuitGame:case XingYunCount:case VipRefresh:case OpenMonthlySign:return emptyText(a.text);
    case SelfTarget:return i[0]>=0&&i[1]>=0&&emptyText(a.text); // 0,0 from the caller; the bridge fills the real ids
    case BagCountIn:return (i[0]==1||i[0]==2)&&readableText(a.text,false);
    case ItemList:return i[0]>=0&&i[0]<=3&&readableText(a.text,false);
    case CompoundSelect:return compoundId(i[0])&&emptyText(a.text);
    case AttackAttr:case CohesionCost:return emptyText(a.text);
    case LifeCompose:return i[0]>=400&&i[0]<=407&&emptyText(a.text);
    case BagSpace:return flag(i[0])&&emptyText(a.text);
    case WuhunList:return !std::wcscmp(a.text,wuhunItems);
    case WuhunCompound:return i[0]>=0&&i[0]<=199&&i[1]>=0&&i[1]<=199&&i[0]!=i[1]&&!std::wcscmp(a.text,wuhunItems);
    case MissionDesc:return readableText(a.text,false);
    case UiEnabled:return i[0]>=0&&i[0]<count(uiButtons)&&emptyText(a.text);
    case EquipAdjust:case CityEnemyAsk:return emptyText(a.text);
    case CityEnemyHas:case OpenAddEnemy:return i[0]>=1&&i[0]<=99999999&&emptyText(a.text);
    case BieYeScene:case BieYeAsk:case BieYeGardeners:return emptyText(a.text);
    case BieYeProduct:return i[0]>=0&&i[0]<=4&&emptyText(a.text);
    case WuhunText:return i[0]>=0&&i[0]<count(wuhunTexts)&&emptyText(a.text);
    case ExamRead:case GoldGiftRead:return emptyText(a.text);
    case HuoYueBuy:return (i[0]==1||i[0]==2)&&i[1]>=-1&&i[1]<=9999&&readableText(a.text,false);
    case DividendBuy:return readableText(a.text,false);
    case HonourBuy:case GuildShopBuy:case T3ShopBuy:case ChongLouBuy:case GuiShiBuy:return i[0]>=-1&&i[0]<=9999&&readableText(a.text,false);
    case GoldGiftChoose:return i[0]>=1&&i[0]<=3&&emptyText(a.text);
    case UseBoxItem:return readableText(a.text,false)&&std::wcsstr(a.text,L"宝箱")!=nullptr;
    case HuoDongCount:case AwakeRead:return emptyText(a.text);
    case HuoDongEnum:return i[0]>=0&&i[0]<=63&&emptyText(a.text);
    case AwakeAdd:return (i[0]==1||i[0]==2)&&i[1]>=0&&i[1]<=99&&flag(i[2])&&emptyText(a.text);
    case SectOper:return i[0]>=0&&i[0]<=9&&emptyText(a.text);
    case NpcShopBuy:return i[0]>=0&&i[0]<count(shopItems)&&emptyText(a.text);
    case EquipDur:return i[0]>=0&&i[0]<=21&&i[1]>=1&&i[1]<=100&&emptyText(a.text);
    case EquipRepair:case EquipRestore:return i[0]>=0&&i[0]<=21&&flag(i[1])&&emptyText(a.text);
    case WuhunLife:return i[0]>=1&&i[0]<=100000&&emptyText(a.text);
    case WuhunRepair:return emptyText(a.text);
    case XiuLianInfo:return i[0]>=0&&i[0]<=20&&emptyText(a.text);
    case XinfaRead:case XinfaStudy:return i[0]>=1&&i[0]<=8&&emptyText(a.text);
    case DianJin:return i[0]>=0&&i[0]<=3&&flag(i[1])&&flag(i[2])&&(i[1]||i[2])&&emptyText(a.text);
    case XZGift:return i[0]>=0&&i[0]<count(xzGifts)&&emptyText(a.text);
    case GemCarve:return readableText(a.text,false)&&std::wcsstr(a.text,L"石")!=nullptr;
    case LwScan:case LwUnequip:return emptyText(a.text);
    case LwCombine:return i[0]>=0&&i[0]<=99&&i[1]>=0&&i[1]<=99&&i[0]!=i[1]&&i[2]>=-1&&i[2]<=99&&emptyText(a.text);
    case LwEquip:return i[0]>=0&&i[0]<=99&&emptyText(a.text);
    default:return false;
    }
}
// Risk classes gated by per-task switches in the Worker (allow_spend / allow_transfer).
enum Risk:uint32_t { RiskNone=0,RiskSpend=1,RiskTransfer=2,RiskOffline=4,RiskSell=8,RiskItem=16 };
inline uint32_t snippetRisk(uint32_t id,const SnippetArgs &a){
    // These calls change an existing item or move it between storage containers.
    // BankItem with take=0 only reads the count and must remain available.
    if(id==UseBagItem||id==BagStore||id==TempBag||(id==BankItem&&a.ints[0]==1))return RiskItem;
    if(id==GemCombine)return RiskSpend;                                   // compose fee
    if(id==QuitGame)return RiskOffline;                                   // 下线：关闭游戏客户端
    if(id==EquipAdjust)return RiskSpend;                                  // 资质鉴定：是否收费未核实，按收费处理
    if(id==WuhunText)return RiskSpend;                                    // 庄园：元宝播撒、雇佣园丁
    if(id>=HuoYueBuy&&id<=GuiShiBuy)return RiskSpend;                    // 各类商店购买
    if(id==GoldGiftChoose)return RiskSpend;                               // 鎏金礼匣：花金币领取
    if(id==NpcShopBuy)return RiskSpend;                                   // NPC 商店买药品/杂货
    if(id==EquipRepair||id==WuhunRepair)return RiskSpend;                 // 修理装备 / 武魂续命收费
    if(id==BagSell)return RiskSell;                                       // 卖给 NPC 商店
    if(id==XinfaStudy)return RiskSpend;                                   // 升级心法：花金币和经验
    if(id==DianJin||id==GemCarve||id==LwCombine)return RiskSpend;         // 点金 / 雕琢 / 龙纹合成（是否收费未核实，按收费处理）
    if(id==XScript&&a.ints[0]>=0&&a.ints[0]<count(xscripts)&&!std::strncmp(xscripts[a.ints[0]].function,"AskXiuLian",10))return RiskSpend; // 点修炼
    if(id==QuestOption&&(!std::wcscmp(a.text,L"#{CPBT_260115_06}")||!std::wcscmp(a.text,L"#{CPBT_260115_07}")||!std::wcscmp(a.text,L"#{CPBT_260115_08}")
        ||!std::wcscmp(a.text,L"#{XCBT_260506_05}")))return RiskSpend;    // 购买路书 / 寻宝图
    if(id==XScript&&a.ints[0]>=0&&a.ints[0]<count(xscripts)&&!std::strcmp(xscripts[a.ints[0]].function,"Buy"))return RiskSpend; // 豪气满江湖买红包
    if(id==QuestOption&&!std::wcscmp(a.text,L"幸运快活三"))return RiskSpend;  // 参加快活三可能收费（未核实，按收费处理）
    if(id==QuestOption&&!std::wcscmp(a.text,L"#{BTSM_260114_04}"))return RiskSpend; // 兑换藏宝图：花金币
    if(id==QuestOption&&!std::wcscmp(a.text,L"#{WH_xml_XX(112)}"))return RiskSpend; // 合成魂冰珠：收合成费
    if(id==UiCall&&a.ints[0]>=0&&a.ints[0]<count(uiCalls)){                // 材料合成、凝聚九天玉碎：收费
        const char *f=uiCalls[a.ints[0]].function;
        if(!std::strcmp(f,"CaiLiaoCompound_OK_Click")||!std::strcmp(f,"EquipBaoJian_Cohesion_OnOK"))return RiskSpend;
        if(!std::strcmp(f,"DaHuaQiXi_Shop_Clicked"))return RiskSpend;      // 倩心阁兑换（是否收费未核实，按收费处理）
        if(!std::strcmp(f,"BieYePetBar_Awake_Promote_Click"))return RiskSpend; // 珍兽血脉觉醒（是否收费未核实，按收费处理）
    }
    if(id==XScript&&a.ints[0]>=0&&a.ints[0]<count(xscripts)&&!std::strcmp(xscripts[a.ints[0]].function,"GetExp_ByMoney"))return RiskSpend; // 找回经验
    if(id==UiCall&&a.ints[0]>=0&&a.ints[0]<count(uiCalls)){
        const char *f=uiCalls[a.ints[0]].function;                        // 祈鸿金祈福、找回确认框
        if(!std::strcmp(f,"Xichunchi_Prize2_Reward_Clicked")||!std::strcmp(f,"WuhunQuest_Bn1Click"))return RiskSpend;
    }
    return RiskNone;
}
inline bool snippetIssuesAction(uint32_t id){
    return id==RunTo||id==TalkNpc||id==NpcTarget||id==QuestOption||id==QuestButton||id==XScript||id==UiCall||id==CloseAll||id==UiEvent
        ||id==BankBig||id==BankMoney||id==BankItem||id==BagStore||id==TempBag||id==SweepOpenPage||id==SweepBoss||id==CloseNamed
        ||id==ShopMoney||id==GemCombine||id==CombatCast
        ||id==UseBagItem||id==Dismount||id==MsgBoxText||id==QuitGame||id==VipRefresh||id==CompoundSelect||id==OpenMonthlySign
        ||id==LifeCompose||id==WuhunCompound||id==EquipAdjust||id==CityEnemyAsk||id==OpenAddEnemy||id==BieYeAsk||id==WuhunText
        ||(id>=HuoYueBuy&&id<=GuiShiBuy)||id==GoldGiftChoose||id==UseBoxItem||id==AwakeAdd||id==SectOper||id==NpcShopBuy
        ||id==EquipRepair||id==EquipRestore||id==WuhunRepair||id==BagSell||id==XinfaStudy
        ||id==DianJin||id==XZGift||id==GemCarve||id==LwUnequip||id==LwCombine||id==LwEquip||id==SelfTarget;
}
// Lua 5.0 sources. Each chunk returns one function; its results are at most eight values.
// GBK text constants arrive as arguments from the bridge, so these sources stay ASCII.
inline const char *snippetSource(uint32_t id){
    switch(id){
    case CombatSkill:return
        "return function(name) for i=0,255 do local a=EnumAction(i,'skill') if a and a:GetID()~=0 and a:GetName()==name then "
        "local cd=Lua_CheckActionItemCoolDown(a:GetID()) if type(cd)~='number' then error('skill cooldown unavailable') end return i,a:GetID(),cd end end return -1,0,0 end";
    case CombatName:return "return function(id) return 1,Target:GetNpcName(id) or '' end";
    case DictText:return "return function(k) local v='' if GetDictionaryString then v=GetDictionaryString(k) or '' end return 1,v end";
    case NpcEventItem:return
        "return function(idx)\n"
        " local e=Quest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " if idx>DataPool:GetNPCEventList_Num()-1 then return 0,'' end\n"
        " local k,_,s,x,text=DataPool:GetNPCEventList_Item(idx) if type(text)~='string' then return 0,'' end\n"
        " return 1,text end";
    case NpcEventAll:return
        "return function()\n"
        " local e=Quest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " local n=DataPool:GetNPCEventList_Num() local t=' '\n"
        " for i=0,n-1 do local k,_,s,x,text=DataPool:GetNPCEventList_Item(i) t=t..tostring(text or '')..' ' end\n"
        " return n,t end";
    case GuildInfo:return
        "return function()\n"
        " local id=Guild:GetMyGuildDetailInfo('ID') local name=Guild:GetMyGuildDetailInfo('Name') local city=Guild:GetMyGuildDetailInfo('CityName')\n"
        " if name==nil or name=='' then Guild:AskGuildDetailInfo() end\n"
        " if city==nil or city=='-1' then city='' end\n"
        " return tonumber(id) or -1,city end";
    case UseBagItem:return
        "return function(name,bind,all)\n"
        " local n=DataPool:GetBaseBag_Num() local idx=-1\n"
        " for i=0,n-1 do local a=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and a:GetName()==name and (bind==0 or GetItemBindStatus(i)==bind-1) then\n"
        "   PlayerPackage:UseItem(i) idx=i if all~=1 then return idx end end end\n"
        " return idx end";
    case MissionFind:return
        "return function(memo)\n"
        " for i=0,19 do if DataPool:GetPlayerMission_InUse(i)==1 and DataPool:GetPlayerMission_Memo(i)==memo then\n"
        "  local id=string.gsub(DataPool:GetPlayerMission_Name(i) or '','Mission:','')\n"
        "  local display=-1 if type(DataPool.GetPlayerMission_Display)=='function' then display=tonumber(DataPool:GetPlayerMission_Display(i,7)) or -1 end\n"
        "  return i,tonumber(id) or -1,display end end\n"
        " return -1,-1,-1 end";
    case MissionVar:return
        "return function(slot,n) if DataPool:GetPlayerMission_InUse(slot)==1 then return DataPool:GetPlayerMission_Variable(slot,n) end return -1 end";
    // -1 when this build has no Player:GetState (callers then stop waiting instead of failing).
    case PlayerState:return "return function() if not Player or type(Player.GetState)~='function' then return -1 end return Player:GetState() or -1 end";
    // 1 dismount issued, 0 not mounted, 2 = press the self context menu's 下坐骑 item natively,
    // -1 = no route; the text then lists related functions the game exposes.
    // The game's own route is the self right-click menu item Myself_DisbondRide, whose Clicked handler
    // (ContexMenu layout) is ContexMenu_OtherPlayer_Clicked("Ride").
    case Dismount:return
        "return function(buff) if Player and type(Player.DispelBuffByName)=='function' then if Player:DispelBuffByName(buff) then return 1 end return 0 end\n"
        " if type(GetMountID)=='function' and GetMountID()==-1 then return 0 end\n"
        // Calling ContexMenu_OtherPlayer_Clicked from outside fails (`this:ClosePopMenu`, live test).
        // The mount skill is a toggle, the same call the original uses to mount and to dismount.
        " if type(GetMountID)=='function' and Player and type(Player.UseSkillInLua_Const)=='function' then Player:UseSkillInLua_Const() return 1 end\n"
        " if rawget(_G,'ContexMenu_Env') then return 2 end\n"
        " local seen,names={},{} local function scan(t,prefix) if type(t)~='table' then return end for k,v in pairs(t) do\n"
        "  if type(k)=='string' and not seen[prefix..k] and (string.find(k,'Mount') or string.find(k,'Ride') or string.find(k,'Horse') or string.find(k,'Buff') or string.find(k,'State')) then\n"
        "   seen[prefix..k]=true table.insert(names,prefix..k) end end end\n"
        " scan(Player,'Player.') local mt=Player and getmetatable(Player) if type(mt)=='table' then scan(mt,'Player.') scan(mt.__index,'Player.') end\n"
        " for k,v in pairs(_G) do if type(k)=='string' and type(v)=='function' and (string.find(k,'Mount') or string.find(k,'Ride') or string.find(k,'Horse')) then table.insert(names,k) end end\n"
        " return -1,table.concat(names,' ') end";
    case DoubleTimer:return
        "return function() local e=MainMenuBar_Env local w=type(e)=='table' and e.MainMenuBar_Doub_Watch\n"
        " if w and w:IsVisible() then return tonumber(w:GetProperty('Timer')) or 0 end return 0 end";
    case VipLevel:return "return function() return DataPool:GetAccVipLevel() or 0 end";
    case MsgBoxText:return
        "return function(want) local e=MessageBox_Self_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " local t=e.MessageBox_Self_Text and e.MessageBox_Self_Text:GetText() or ''\n"
        " if not string.find(t,want,1,true) then return 0 end\n"
        // Newer builds no longer expose the OK handler in this table; 2 = matched, press the button natively.
        " local f=rawget(e,'MessageBox_Self_OK_Clicked') if type(f)=='function' then f() return 1 end return 2 end";
    case QuitGame:return "return function() QuitApplication('quit') return 1 end";
    case XingYunCount:return
        "return function() local e=XingYun_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1 end local c=0\n"
        " for i=1,20 do local h=e['XingYun_Head'..i] if h and h:GetToolTip()=='' then c=c+1 end end return c end";
    case VipRefresh:return "return function() Target:SendUpdateVipInfoMsg() return 1 end";
    case LifeCompose:return "return function(id) ComposeItem_Begin(id,99,-1) return 1 end";
    case MissionDesc:return
        "return function(memo) for i=0,19 do if DataPool:GetPlayerMission_InUse(i)==1 then local info,desc=DataPool:GetPlayerMission_Memo(i)\n"
        "  if info==memo then return 1,desc or '' end end end return 0,'' end";
    case UiEnabled:return
        "return function(window,button) local e=_G[window..'_Env'] local b=type(e)=='table' and e[button]\n"
        " if b and tostring(b:GetProperty('Disabled'))=='False' then return 1 end return 0 end";
    case EquipAdjust:return
        "return function() local c=0 for i=0,DataPool:GetBaseBag_Num()-1 do local a=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and LifeAbility:Get_Equip_TableIndex(i)~=-1 and LifeAbility:Get_Equip_Point(i)==0 then\n"
        "   Clear_XSCRIPT() Set_XSCRIPT_Function_Name('FinishAdjust') Set_XSCRIPT_ScriptID(809261) Set_XSCRIPT_Parameter(0,i) Set_XSCRIPT_ParamCount(1) Send_XSCRIPT() c=c+1 end end\n"
        " return c end";
    case CityEnemyHas:return
        "return function(tid) for k=0,1 do for i=0,City:GetEnemyNum(k)-1 do if City:EnumCityEnemy(k,i,'guildid')==tid then return 1 end end end return 0 end";
    case CityEnemyAsk:return "return function() City:AskEnemyList(0) City:AskEnemyList(1) return 1 end";
    case BieYeScene:return "return function() if BieYeFurniture:IsBieYeScene() then return 1 end return 0 end";
    case BieYeProduct:return "return function(slot) local a,b=BieYeUI:GetBieYeBaseInfo('ProductInfo',slot) return tonumber(a) or -1,tonumber(b) or 0 end";
    case BieYeAsk:return "return function() BieYeUI:AskBieYeBaseInfo(5) return 1 end";
    case HuoYueBuy:return
        "return function(shop,count,name)\n"
        " local per=15 local pages=math.ceil(GetHuoYueShopTotalCount(shop)/per) local high,low=GetHuoYueShopDaiBiInfo()\n"
        " for j=1,pages do local t=GetHuoYueShopData(shop,j,per) for i=1,table.getn(t) do local v=t[i]\n"
        "  local have=low if v.daibitype==1 then have=high end local lim,num=0,0\n"
        "  if v.limitday>0 then lim,num=1,v.limitday_self elseif v.limitweek>0 then lim,num=1,v.limitweek_self\n"
        "  elseif v.limitmonth>0 then lim,num=1,v.limitmonth_self elseif v.limitfov>0 then lim,num=1,v.limitfov_self end\n"
        "  local max=HuoYueShopCalcMaxNumCanBuy(v.itemid,v.itemnum,shop,have,v.daibinum,lim,num,0)\n"
        "  if max>0 and DataPool:Lua_GetItemNameByIndex(v.itemid)==name then\n"
        "   if shop==2 then if count>0 then if count<max then max=count end elseif lim~=1 then return 0 end end\n"
        "   Clear_XSCRIPT() Set_XSCRIPT_Function_Name('BuyItem') Set_XSCRIPT_ScriptID(888393) Set_XSCRIPT_Parameter(0,-1)\n"
        "   Set_XSCRIPT_Parameter(1,shop) Set_XSCRIPT_Parameter(2,v.itemid) Set_XSCRIPT_Parameter(3,max) Set_XSCRIPT_ParamCount(4) Send_XSCRIPT() return 1 end end end\n"
        " return 0 end";
    case DividendBuy:return
        "return function(name) local e=YuanbaoShop_Env if type(e)~='table' then return -1 end\n"
        " e.YuanbaoShop_ChangeTabIndex(5) e.YuanbaoShop_UpdateList(5) local n=0\n"
        " for i=0,35 do local a=EnumAction(i,'boothitem') if a:GetID()~=0 and a:GetName()==name then local p=NpcShop:EnumItemPrice(i)\n"
        "  if p==210 or p==220 or p==270 or p==860 then NpcShop:BulkBuyItem(i,1,0) n=1 end end end\n"
        " return n end";
    case HonourBuy:return
        "return function(count,name) local lv=City:GetWeekDuanWei()\n"
        " for i=0,City:GetHonourShopItemNum(lv)-1 do local remain=City:GetHonourShopInfo(i,'remainnum') local a=City:EnumHonourShop(i)\n"
        "  if remain>0 and a:GetID()~=0 and a:GetName()==name then local mine=Player:GetData('MILITARYEXCHANGE') local cost=City:GetHonourShopInfo(i,'honour')\n"
        "   local can=remain if cost*remain>mine then can=math.floor(mine/cost) end if count==-1 or can<count then count=can end\n"
        "   if count>0 then City:DoHonourShopBuy(i,count) return 1 end return 0 end end\n"
        " return 0 end";
    case GuildShopBuy:return
        "return function(count,name) for i=1,City:GetGuildShopInfo(0,'total') do local a,open=City:EnumGuildShop(i)\n"
        "  if open~=0 and a:GetID()~=0 and a:GetName()==name and City:GetGuildShopInfo(i,'MaxNumber')>0 then\n"
        "   local remain=City:GetGuildShopInfo(i,'MaxNumber') local can=math.floor(Guild:GetGuildContri()/City:GetGuildShopInfo(i,'contribute'))\n"
        "   if count==-1 or can<count then count=can end if count>remain then count=remain end\n"
        "   if count>0 then City:DoGuildShopBuy(i,count) end return 1 end end\n"
        " return 0 end";
    case T3ShopBuy:return
        "return function(count,name) local e=T3DaibiShop_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " local state=5 local token=Player:LuaFnGetT3ShopToken() local yb=Player:GetData('YUANBAO')\n"
        " for i=0,GetActionNum('t3shop')-1 do local a=EnumAction(DataPool:LuaFnGetT3ShopItemInfo(i,'SHOPINDEX'),'t3shop') local price=DataPool:LuaFnGetT3ShopItemInfo(i,'PRICE')\n"
        "  if a:GetID()~=0 and price>0 and a:GetName()==name then state=0 local max=math.floor(token/price)\n"
        "   if DataPool:LuaFnGetT3ShopItemInfo(i,'CURRENCY')==0 then max=math.floor(yb/price) end\n"
        "   local kind=DataPool:LuaFnGetT3ShopItemInfo(i,'LIMITTYPE') local mine=DataPool:LuaFnGetT3ShopItemInfo(i,'PLAYERREMAIN')\n"
        "   if kind==1 and mine<max then max=mine end\n"
        "   if kind==2 then local guild=DataPool:LuaFnGetT3ShopItemInfo(i,'GUILDREMAIN')\n"
        "    if mine<0 then if guild<max then max=guild end elseif mine<guild then if mine<max then max=mine end elseif guild<max then max=guild end end\n"
        "   if count>max then count=max if count<=0 then state=3 end end\n"
        "   if count>0 then NpcShop:LuaFnT3ShopBuyItem(i,count) end break end end\n"
        " return state end";
    case ChongLouBuy:return
        "return function(count,name) local e=ChongLou_DaibiShop_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1 end\n"
        " local _,_,m1=string.find(e.ChongLou_DaibiShop_Text2:GetText() or '','(%d+)') local _,_,m2=string.find(e.ChongLou_DaibiShop_Text1:GetText() or '','(%d+)')\n"
        " local money={tonumber(m1) or -1,tonumber(m2) or -1} if money[1]<0 or money[2]<0 then return -1 end\n"
        " for lv=1,2 do local list=DataPool:LuaFnGetChongLouShopByLv(lv) for i=1,table.getn(list) do local v=list[i]\n"
        "  if v.name==name then if v.time_type==0 and count<=0 then return 1 end local can=math.floor(money[lv]/v.price)\n"
        "   if v.count>0 and v.count<can then can=v.count end if count>0 and count<can then can=count end\n"
        "   if can>0 then Clear_XSCRIPT() Set_XSCRIPT_ScriptID(888431) Set_XSCRIPT_Function_Name('MBuyConfirm') Set_XSCRIPT_Parameter(0,40)\n"
        "    Set_XSCRIPT_Parameter(1,v.id) Set_XSCRIPT_Parameter(2,can) Set_XSCRIPT_ParamCount(3) Send_XSCRIPT() return 0 end return 2 end end end\n"
        " return 3 end";
    case GuiShiBuy:return
        "return function(count,name) local e=GuiShi_Shop_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " local state=0 local tong=GuiShiUI:LuaFnGetGuiShiTongBi() local yl=GuiShiUI:LuaFnGetGuiShiYinLiang()\n"
        " for i=0,GuiShiUI:LuaFnGetNPCShopGoodsNum()-1 do\n"
        "  local ok,n,limited,left,bought,t1,n1,s1,t2,n2,s2=GuiShiUI:LuaFnGetNPCShopGoodsInfo(i)\n"
        "  if ok~=0 and EnumAction(i,'gs_npcshop_goodslist'):GetID()~=0 and n==name then\n"
        "   if limited==1 and count>left then count=left if count<=0 then state=3 end end\n"
        "   if count>0 then local need3,need2=0,0 if t1==3 then need3=n1*count end if t2==2 then need2=n2*count end\n"
        "    if tong>=need3 and yl>=need2 then state=2 local id=GuiShiUI:LuaFnGetNPCShopGoodsId(i)\n"
        "     if id~=-1 then state=1 PushEvent('GUISHI_ONBUY',tostring(i),tostring(id),tostring(0),tostring(count),tostring(0)) end\n"
        "    else state=4 end end\n"
        "   break end end\n"
        " return state end";
    case GoldGiftRead:return
        "return function() local e=GoldRecycle_GiftShop_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " return 1,(e.GoldRecycle_GiftShop_Item1_Info:GetText() or '')..'\\t'..(e.GoldRecycle_GiftShop_Item2_Info:GetText() or '')..'\\t'..(e.GoldRecycle_GiftShop_Item3_Info:GetText() or '') end";
    case GoldGiftChoose:return
        "return function(i) local e=GoldRecycle_GiftShop_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " e.GoldRecycle_GiftShop_Choose(i) e.GoldRecycle_GiftShop_GetClick() return 1 end";
    case UseBoxItem:return
        "return function(name) for i=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true and a:GetName()==name then PlayerPackage:UseItem(i) return i end end return -1 end";
    case HuoDongCount:return "return function() return Lua_GetSecKillFuBenCount_HuoDong() or 0 end";
    case HuoDongEnum:return
        "return function(idx)\n"
        " local e=SweepAll_Env local function f(n) if type(e)=='table' and e[n] then return e[n] end return _G[n] end\n"
        " local id,_,name,_,_,n1,n2,n3,_,need,_,_,_,_,_,_,_,kaji=f('EnumSecKillTable_HuoDong')(idx)\n"
        " local done,total=f('LuaGetSeckillCampaignTableNew_HuoDong')(kaji)\n"
        " if name==nil or name=='' then name='nil' end\n"
        " return id or 0,n1 or 0,n2 or 0,n3 or 0,need or 0,done or 0,total or 0,name end";
    case AwakeRead:return
        "return function() local e=BieYePetBar_Awake_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " local t='' for k=1,2 do local l=e['BieYePetBar_Awake_List0'..k]\n"
        "  for i=1,l:GetItemNumber() do t=t..i..'&'..tostring(l:GetItem(i) or '')..' ' end if k==1 then t=t..'\\t' end end\n"
        " return 1,t end";
    case AwakeAdd:return
        "return function(list,idx,input) local e=BieYePetBar_Awake_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " if input==1 then e.BieYePetBar_Awake_PetList_Input_Click(list-1) return 1 end\n"
        " e['BieYePetBar_Awake_List0'..list]:SetItemSelect(idx) e.BieYePetBar_Awake_List_Selected(list-1) return 1 end";
    case SectOper:return
        "return function(idx) local id=DataPool:GetZongMenTalentNormalData(idx,'SectId') Player:Lua_AskSectOper(0,id) return 1 end";
    case NpcShopBuy:return
        "return function(name) for i=0,35 do local a=EnumAction(i,'boothitem')\n"
        "  if a and a:GetID()~=0 and a:GetName()==name then NpcShop:BulkBuyItem(i,1,0) return i end end return -1 end";
    case EquipDur:return
        "return function(index,limit) local a=EnumAction(index,'equip') local tid=a:GetID() local name,def,left='',-1,3\n"
        " if tid~=0 and a:GetEquipDur()<limit/100 then name=a:GetName() or '' def=a:GetDefineID() or -1 left=a:GetRemainRepairCount() end\n"
        " return tid,def,left,name end";
    case EquipRepair:return
        "return function(index,npc) local id,enter=-1,1 if npc==1 then id,enter=140,0 end\n"
        " Clear_XSCRIPT() Set_XSCRIPT_Function_Name('OnEquipRepairNew') Set_XSCRIPT_ScriptID(805027) Set_XSCRIPT_Parameter(0,id) Set_XSCRIPT_Parameter(1,1) Set_XSCRIPT_Parameter(2,index)\n"
        " Set_XSCRIPT_Parameter(3,-1) Set_XSCRIPT_Parameter(4,1) Set_XSCRIPT_Parameter(5,enter) Set_XSCRIPT_ParamCount(6) Send_XSCRIPT() return 1 end";
    case EquipRestore:return
        "return function(index,npc,name) local pos=-1\n"
        " for i=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true and a:GetName()==name then if pos<0 then pos=i end if GetItemBindStatus(i)==1 then pos=i break end end end\n"
        " if pos<0 then return -1 end local id=-1 if npc==1 then id=140 end\n"
        " Clear_XSCRIPT() Set_XSCRIPT_Function_Name('EquipFaileTimesOnEquip') Set_XSCRIPT_ScriptID(809265) Set_XSCRIPT_Parameter(0,id) Set_XSCRIPT_Parameter(1,index) Set_XSCRIPT_Parameter(2,pos)\n"
        " Set_XSCRIPT_ParamCount(3) Send_XSCRIPT() return pos end";
    case WuhunLife:return
        "return function(limit) local name=DataPool:GetKfsData('NAME') local life=DataPool:GetKfsData('LIFE')\n"
        " if name~=nil and life~=nil and life<limit then return 1,name end return 0,'' end";
    case WuhunRepair:return
        "return function(name) local pos=-1\n"
        " for i=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',i) if a and a:GetID()~=0 and locked~=true and a:GetName()==name then pos=i break end end\n"
        " if pos<0 then return -1 end Clear_XSCRIPT() Set_XSCRIPT_Function_Name('Kfs_AddLifeNew') Set_XSCRIPT_ScriptID(809270) Set_XSCRIPT_Parameter(0,1) Set_XSCRIPT_Parameter(1,18)\n"
        " Set_XSCRIPT_Parameter(2,pos) Set_XSCRIPT_Parameter(3,1) Set_XSCRIPT_Parameter(4,1) Set_XSCRIPT_ParamCount(5) Send_XSCRIPT() return pos end";
    case XiuLianInfo:return
        "return function(i) local function g(k) return Player:GetXiuLianMiJiInfo(i,k) end\n"
        " return g('JingJie') or -1,g('Level') or -1,g('MaxLevel') or -1,g('UpLevelNeedMoney') or 0,g('UpLevelNeedExp') or 0 end";
    case XinfaRead:return
        "return function(index) local a=EnumAction(index-1,'xinfa') if a:GetID()==0 then return -1,-1,0 end\n"
        " local id=LifeAbility:GetLifeAbility_Number(a:GetID()) local lv=Player:GetXinfaInfo(id,'level')\n"
        " local money=GetUplevelXinfaSpendMoney(id,lv+1) local exp=GetUplevelXinfaSpendExp(id,lv+1)\n"
        " local ok=0 if money<=(Player:GetData('MONEY') or 0)+(Player:GetData('MONEY_JZ') or 0) and exp<=(Player:GetData('EXP') or 0) then ok=1 end\n"
        " return id,lv,ok end";
    case XinfaStudy:return
        "return function(index) local a=EnumAction(index-1,'xinfa') if a:GetID()==0 then return 0 end\n"
        " SkillsStudyFrame_study(LifeAbility:GetLifeAbility_Number(a:GetID())) return 1 end";
    case DianJin:return
        "return function(mode,mb,my,jade,cloth,silver) local j0,j1,m0,m1=-1,-1,-1,-1\n"
        " for i=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true then local name=a:GetName() local b=GetItemBindStatus(i)\n"
        "   if name==jade then if b==1 then if j1<0 then j1=i end elseif j0<0 then j0=i end\n"
        "   elseif (mb==1 and name==cloth) or (my==1 and name==silver) then if b==1 then if m1<0 then m1=i end elseif m0<0 then m0=i end end end end\n"
        " local j,m=-1,-1\n"
        " if mode==0 then if j0>=0 and m0>=0 then j,m=j0,m0 elseif j1>=0 and m1>=0 then j,m=j1,m1 end\n"
        " elseif mode==1 then if j1>=0 and m1>=0 then j,m=j1,m1 end\n"
        " elseif mode==2 then if j0>=0 and m0>=0 then j,m=j0,m0 end\n"
        " else if j1>=0 then j=j1 else j=j0 end if m1>=0 then m=m1 else m=m0 end end\n"
        " if j<0 or m<0 then return 0 end\n"
        " Clear_XSCRIPT() Set_XSCRIPT_Function_Name('DianJin') Set_XSCRIPT_ScriptID(892944) Set_XSCRIPT_Parameter(0,135) Set_XSCRIPT_Parameter(1,m)\n"
        " Set_XSCRIPT_Parameter(2,j) Set_XSCRIPT_Parameter(3,1) Set_XSCRIPT_ParamCount(4) Send_XSCRIPT() return 1 end";
    case XZGift:return
        "return function(hero,gift) for id=1,DataPool:LuaFnGetXingZhen_YingXiongNum() do\n"
        "  if DataPool:LuaFnGetXingZhen_YingXiongInfo(id,'Name')==hero then\n"
        "   if DataPool:LuaFnGetXingZhen_YingXiongHaoganLevel(id)<10000 then local t={}\n"
        "    t[1],t[2],t[3],t[4],t[5]=DataPool:LuaFnGetXingZhen_YingXiongInfo(id,'Interests')\n"
        "    for i=1,5 do local k=t[i] if k and DataPool:LuaFnGetXingZhen_InterestsInfo(k,'Name')==gift then\n"
        "     if DataPool:LuaFnGetXingZhen_InterestsTotalGiveNum(k)==DataPool:LuaFnGetXingZhen_InterestsInfo(k,'MaxLevel')*10 then return 0 end\n"
        "     Clear_XSCRIPT() Set_XSCRIPT_Function_Name('OpenXZ3_GiveGift') Set_XSCRIPT_ScriptID(888052) Set_XSCRIPT_Parameter(0,id) Set_XSCRIPT_Parameter(1,i)\n"
        "     Set_XSCRIPT_ParamCount(2) Send_XSCRIPT() return 1 end end end\n"
        "   return 0 end end return 0 end";
    case GemCarve:return
        "return function(name,fu,ji) local gem=-1\n"
        " for i=0,DataPool:GetMatBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('material',i)\n"
        "  if a and a:GetID()~=0 and locked~=true and a:GetName()==name then gem=100+i break end end\n"
        " if gem<0 then return 0 end local lv=nil for l=1,8 do if string.find(name,l..ji,1,true) then lv=l break end end\n"
        " if not lv then return -2 end local want=fu..lv..ji local pos,any=-1,-1\n"
        " for j=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',j)\n"
        "  if a and a:GetID()~=0 and locked~=true and a:GetName()==want then if any<0 then any=j end if GetItemBindStatus(j)==1 then pos=j break end end end\n"
        " if pos<0 then pos=any end if pos<0 then return -1 end local count=PlayerPackage:GetBagItemNum(gem)\n"
        " Clear_XSCRIPT() Set_XSCRIPT_Function_Name('OnGemCarve') Set_XSCRIPT_ScriptID(800117) Set_XSCRIPT_Parameter(0,gem) Set_XSCRIPT_Parameter(1,pos)\n"
        " Set_XSCRIPT_Parameter(2,135) Set_XSCRIPT_Parameter(3,1) Set_XSCRIPT_Parameter(4,count) Set_XSCRIPT_ParamCount(5) Send_XSCRIPT() return 1 end";
    case LwScan:return
        "return function() local eq=0 if EnumAction(19,'equip'):GetID()~=0 then eq=1 end\n"
        " local stuff={[38000152]=1,[38000164]=1,[38000165]=1,[38000184]=1,[38000185]=1,[38000186]=1} local t='' local c=0\n"
        " for i=0,99 do local a=PlayerPackage:EnumItem('base',i) if a and a:GetID()~=0 then local kind,lv,bind=0,0,0\n"
        "  if PlayerPackage:IsBagItemLW(i)==1 then lv=PlayerPackage:GetBagLWData(i,'LEVEL') or 0\n"
        "   if PlayerPackage:IsLock(i)~=1 or lv>1 then kind=1 bind=GetItemBindStatus(i) end\n"
        "  else local id=PlayerPackage:GetItemTableIndex(i)\n"
        "   if (id==38002106 or id==38002107) and PlayerPackage:IsLock(i)~=1 then kind=2 lv=1 if id==38002106 then bind=1 end\n"
        "   elseif stuff[id] and PlayerPackage:IsLock(i)~=1 then kind=3 lv=id bind=GetItemBindStatus(i) end end\n"
        "  if kind>0 then local line=i..'\\t'..kind..'\\t'..lv..'\\t'..bind..'\\n' if string.len(t)+string.len(line)<=500 then t=t..line c=c+1 end end end end\n"
        " return eq,c,t end";
    case LwUnequip:return
        "return function() if EnumAction(19,'equip'):GetID()==0 then return 1 end local e=SelfEquip_Env if type(e)~='table' then return -1 end\n"
        " e.SelfEquip_Equip_Click(25,0) return 0 end";
    case LwCombine:return
        "return function(main,mat,stuff) local function lw(i) return PlayerPackage:IsBagItemLW(i)==1 end\n"
        " local id=PlayerPackage:GetItemTableIndex(mat) if not lw(main) or not (lw(mat) or id==38002106 or id==38002107) then return 0 end\n"
        " PlayerPackage:Lw_Op_Do(1,main,mat,stuff) return 1 end";
    case LwEquip:return
        "return function(i) if PlayerPackage:IsBagItemLW(i)~=1 then return 0 end\n"
        " local p=Packet_Env local button=type(p)=='table' and p.Packet_Space_Line10_Row10_button if not button then return -2 end\n"
        " local a=PlayerPackage:EnumItem('base',i) local old=button:GetActionItem() button:SetActionItem(a:GetID()) button:DoAction() button:SetActionItem(old) return 1 end";
    case ExamRead:return
        "return function() local e=Examination_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " local t=e.Examination_Text:GetText() or '' for i=1,5 do local b=e['Examination_Button_'..i] t=t..'\\t'..(b and b:GetText() or '') end\n"
        " return 1,t end";
    case BieYeGardeners:return
        "return function() local free,hired=2,4 for i=0,5 do local w=tonumber((BieYeUI:GetBieYeBaseInfo('GardnerInfo',i))) or 0\n"
        "  if w>0 and w<=9 then if i<2 then free=free-1 else hired=hired-1 end end end return free,hired end";
    case WuhunText:return
        "return function(want) local e=WuhunQuest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " local t=e.WuhunQuest_InfoWindow and e.WuhunQuest_InfoWindow:GetText() or ''\n"
        " if string.find(t,want,1,true) then e.WuhunQuest_Bn1Click() return 1 end return 0 end";
    case OpenAddEnemy:return "return function(tid) City:OpenAddEnemyDlg('BenFu',tid) return 1 end";
    case BagSpace:return
        "return function(kind) local n,c,k=0,0,'base' if kind==1 then n=DataPool:GetMatBag_Num() k='material' else n=DataPool:GetBaseBag_Num() end\n"
        " if type(n)~='number' or n~=math.floor(n) or n<1 or n>512 then return -1 end\n"
        " for i=0,n-1 do local a=PlayerPackage:EnumItem(k,i) if not a or a:GetID()==0 then c=c+1 end end return c end";
    case WuhunList:return
        "return function(names) local t='' local c=0\n"
        " for i=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true and string.find(names,a:GetName(),1,true) then\n"
        "   local lv=PlayerPackage:GetBagKfsData(i,'EXTRALEVEL') or 0 local line=i..'\\t'..(GetItemBindStatus(i) or 0)..'\\t'..lv..'\\n'\n"
        "   if string.len(t)+string.len(line)<=500 then t=t..line c=c+1 end end end\n"
        " return c,t end";
    case WuhunCompound:return
        "return function(a,b,names) for _,i in ipairs({a,b}) do local x=PlayerPackage:EnumItem('base',i)\n"
        "  if not x or x:GetID()==0 or not string.find(names,x:GetName(),1,true) then return 0 end end\n"
        " Clear_XSCRIPT() Set_XSCRIPT_Function_Name('OnWuHunCompoundNew') Set_XSCRIPT_ScriptID(790076)\n"
        " Set_XSCRIPT_Parameter(0,a) Set_XSCRIPT_Parameter(1,b) Set_XSCRIPT_Parameter(2,1) Set_XSCRIPT_ParamCount(3) Send_XSCRIPT() return 1 end";
    case ItemList:return
        "return function(kind,filter)\n"
        " local items={} local keys={}\n"
        " local function add(a) if not a or a:GetID()==0 then return end local name=a:GetName()\n"
        "  if not name or not string.find(name,filter,1,true) then return end\n"
        "  local v=keys[name] if not v then v={name,0} keys[name]=v table.insert(items,v) end v[2]=v[2]+a:GetNum() end\n"
        " if kind==0 then for i=0,DataPool:GetBaseBag_Num()-1 do add(PlayerPackage:EnumItem('base',i)) end\n"
        " elseif kind==1 then for i=0,DataPool:GetMatBag_Num()-1 do add(PlayerPackage:EnumItem('material',i)) end\n"
        " elseif kind==2 then for i=0,119 do add(Bank:EnumTemItem(i)) end\n"
        " else local e=BigBank_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1,'' end\n"
        "  local b,n=Bank:GetRentBoxInfo(0) for i=1,n do add(Bank:EnumItem(b+i-1)) end end\n"
        " local t='' local c=0\n"
        " for i=1,table.getn(items) do local line=items[i][1]..'\\t'..items[i][2]..'\\n'\n"
        "  if string.len(t)+string.len(line)<=500 then t=t..line c=c+1 end end\n"
        " return c,t end";
    case CompoundSelect:return
        "return function(id) local e=CaiLiaoCompound_Env if type(e)~='table' or not e.this or not e.this:IsVisible() or not e.CaiLiaoCompound_List then return 0 end\n"
        " e.CaiLiaoCompound_List:SetItemSelectByItemID(id) return 1 end";
    case AttackAttr:return
        "return function() local t=Player:GetAttackAttr() if type(t)=='table' and t[1] and t[1].index then return t[1].index end return -1 end";
    case CohesionCost:return
        "return function() local items={2,5,8,12,16,20,25,30,40,50} local money={20000,50000,80000,120000,160000,200000,250000,300000,400000,500000}\n"
        " local i=Player:GetFiveElementsIndexCanDoCohesion()\n"
        " if i>=0 and i<5 then local g=math.floor(Player:GetFiveElements_ElementsLevel(i)/10) if items[g+1] and money[g+1] then return items[g+1],money[g+1] end end\n"
        " return -1,-1 end";
    case BagCountIn:return
        "return function(kind,name) local c=0\n"
        " local function add(a) if a and a:GetID()~=0 and a:GetName()==name then local v=a:GetNum()\n"
        "  if type(v)~='number' or v<0 or v>2000000000 or v~=math.floor(v) then error('item count unavailable') end c=c+v end end\n"
        " if kind==1 then local n=DataPool:GetMatBag_Num()\n"
        "  if type(n)~='number' or n<0 or n>512 or n~=math.floor(n) then error('material inventory unavailable') end\n"
        "  for i=0,n-1 do add(PlayerPackage:EnumItem('material',i)) end\n"
        " else for i=0,119 do add(Bank:EnumTemItem(i)) end end\n"
        " return c end";
    case ActiveBox:return
        "return function()\n"
        " local r=DataPool:GetPlayerMission_DataRound(579) if type(r)~='number' then return -1 end\n"
        " local p=2 for i=1,4 do if math.mod(math.floor(r/p),2)~=1 then return i end p=p*2 end return 0 end";
    case CombatCast:return
        "return function(client,server,idx,name) "
        "local can=DataPool:IsCanDoAction() if not can or can==0 then return 0 end "
        "local a=nil local b=nil local old=nil "
        "if idx>=0 then a=EnumAction(idx,'skill') if not a or a:GetID()==0 or a:GetName()~=name then return -2 end "
        "local cd=Lua_CheckActionItemCoolDown(a:GetID()) if type(cd)~='number' then error('skill cooldown unavailable') end if cd~=0 then return 0 end "
        "local e=Packet_Env b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end old=b:GetActionItem() end "
        "DataPool:SelectAsTargetByObjID(server) "
        "local present=Target:IsPresent() if not present or present==0 or Target:GetData('NPCID')~=client then return -3 end "
        "if idx>=0 then local enabled=a:IsEnable() if enabled~=1 and enabled~=true then return 0 end end "
        "if idx<0 then local r=Player:UseSkill() if r==1 then return 1 end return 0 end "
        "b:SetActionItem(a:GetID()) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end return 1 end";
    case RunTo:return "return function(x,y,s) AutoRunToTargetEx(x,y,s) return 1 end";
    case TalkNpc:return "return function(x,y,s,n) AutoRunToTargetEx(x,y,s) SetAutoRunTargetNPCName(n) return 1 end";
    case NpcTarget:return "return function(n) SetAutoRunTargetNPCName(n) return 1 end";
    case QuestOptions:return
        "return function()\n"
        " local e=Quest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,0,'' end\n"
        " local n=DataPool:GetNPCEventList_Num() local c=0 local t=''\n"
        " for i=0,n-1 do local k,_,s,x,text=DataPool:GetNPCEventList_Item(i)\n"
        "  if k=='id' and type(text)=='string' then c=c+1 t=t..text..'\\n' end end\n"
        " return 1,c,t end";
    case QuestOption:return
        "return function(needle,exact)\n"
        " local e=Quest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " local function word(v) local _,_,key=string.find(v,'^#{([%w_]+)}$') if key and GetDictionaryString then return GetDictionaryString(key) end return nil end\n"
        " local alt=word(needle)\n"
        " local function same(a,b) if not a or not b or b=='' then return false end if exact==1 then return a==b end return string.find(a,b,1,true)~=nil end\n"
        " local n=DataPool:GetNPCEventList_Num()\n"
        " for i=0,n-1 do local k,_,s,x,text=DataPool:GetNPCEventList_Item(i)\n"
        "  if k=='id' and type(text)=='string' then local shown=word(text)\n"
        "   if same(text,needle) or same(text,alt) or same(shown,needle) or same(shown,alt) then QuestFrameOptionClicked(i,s,x) return 1,text end end end\n"
        " return 0,'' end";
    case QuestButton:return
        "return function(kind,item,label)\n"
        " local e=Quest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0,'' end\n"
        " if kind==1 then QuestFrameAcceptClicked() return 1,'' end\n"
        " local b=e.Quest_Button_Continue local t='' if b then t=b:GetText() or '' end\n"
        " if t~=label then return 0,t end\n"
        " if kind==2 then QuestFrameMissionContinue() else QuestFrameMissionComplete(item) e.this:Hide() end\n"
        " return 1,t end";
    case BagCount:return
        "return function(name)\n"
        " local n=DataPool:GetBaseBag_Num() local c=0\n"
        " if type(n)~='number' or n<=0 or n>512 or n~=math.floor(n) then error('base inventory unavailable') end\n"
        " for i=0,n-1 do local a=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and a:GetName()==name then local v=a:GetNum()\n"
        "   if type(v)~='number' or v<0 or v>2000000000 or v~=math.floor(v) then error('item count unavailable') end c=c+v end end\n"
        " return c,n end";
    case PlayerData:return "return function(k) local v=Player:GetData(k) if type(v)~='number' then return -1 end return v end";
    case TeamCount:return "return function() return DataPool:GetTeamMemberCount() end";
    case XScript:return
        "return function(name,script,count,a,b)\n"
        " Clear_XSCRIPT() Set_XSCRIPT_Function_Name(name) Set_XSCRIPT_ScriptID(script)\n"
        " if count>=1 then Set_XSCRIPT_Parameter(0,a) end if count>=2 then Set_XSCRIPT_Parameter(1,b) end\n"
        " Set_XSCRIPT_ParamCount(count) Send_XSCRIPT() return 1 end";
    case UiCall:return
        "return function(window,name,count,a,visible)\n"
        " local e=_G[window..'_Env'] if type(e)~='table' or type(e[name])~='function' then return -1 end\n"
        " if visible==1 and (not e.this or not e.this:IsVisible()) then return 0 end\n"
        " if count==1 then e[name](a) else e[name]() end return 1 end";
    case WindowVisible:return
        "return function(window) local e=_G[window..'_Env']\n"
        " if type(e)=='table' and e.this and e.this:IsVisible() then return 1 end return 0 end";
    case CloseAll:return "return function() CloseAllWindow() return 1 end";
    case UiEvent:return "return function(name) PushEvent(name) return 1 end";
    case BankState:return
        "return function()\n"
        " local function vis(n) local e=_G[n..'_Env'] if type(e)=='table' and e.this and e.this:IsVisible() then return 1 end return 0 end\n"
        " return vis('Bank'),vis('BigBank'),Bank:GetBankMoney() or 0,Player:GetData('MONEY') or 0 end";
    case BankBig:return
        "return function() local e=Bank_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end\n"
        " PushEvent('TOGLE_BIGBANK',Bank:GetNpcId()) e.this:Hide() Bank:SetOpenWhichBank(1) return 1 end";
    case BankMoney:return
        "return function(kind,amount)\n"
        " local function vis(n) local e=_G[n..'_Env'] return type(e)=='table' and e.this and e.this:IsVisible() end\n"
        " if not vis('BigBank') and not vis('Bank') then return -1 end\n"
        " local limit if kind==1 then limit=Bank:GetBankMoney() else limit=Player:GetData('MONEY') end\n"
        " if amount>limit then amount=limit end if amount<=0 then return 0 end\n"
        " if kind==1 then Bank:GetMoneyFromBank(amount) else Bank:SaveMoneyToBank(amount) end return amount end";
    case BankItem:return
        "return function(name,take)\n"
        " local e=BigBank_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1,0 end\n"
        " if take==1 and e.BigBank_UpdateFrame then e.BigBank_UpdateFrame(0) end\n"
        " local b,n=Bank:GetRentBoxInfo(0) local total=0 local hit=nil\n"
        " for i=1,n do local a,locked=Bank:EnumItem(b+i-1)\n"
        "  if a and a:GetID()~=0 and a:GetName()==name then total=total+a:GetNum() if not hit and locked~=true then hit=i end end end\n"
        " if take~=1 or not hit then return 0,total end\n"
        " local box=0 while hit-box*20>20 do box=box+1 end\n"
        " local button=e['BigBank_Item'..(box+1)..'_'..(hit-box*20)] if not button then return -2,total end\n"
        " button:DoAction() return 1,total end";
    case BagStore:case BagSell:return id==BagStore?
        "return function(name,bind)\n"
        " local function vis(n) local e=_G[n..'_Env'] return type(e)=='table' and e.this and e.this:IsVisible() end\n"
        " if not vis('BigBank') and not vis('Bank') then return -1 end\n"
        " local p=Packet_Env local button=type(p)=='table' and p.Packet_Space_Line10_Row10_button if not button then return -2 end\n"
        " local n=DataPool:GetBaseBag_Num()\n"
        " for i=0,n-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true and a:GetName()==name and (bind==0 or GetItemBindStatus(i)==bind-1) then\n"
        "   local old=button:GetActionItem() button:SetActionItem(a:GetID()) button:DoAction() button:SetActionItem(old) return 1 end end\n"
        " return 0 end":
        "return function(name,bind) local e=Shop_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1 end\n"
        " local p=Packet_Env local button=type(p)=='table' and p.Packet_Space_Line10_Row10_button if not button then return -2 end\n"
        " for i=0,DataPool:GetBaseBag_Num()-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true and a:GetName()==name and (bind==0 or GetItemBindStatus(i)==bind-1) then\n"
        "   local old=button:GetActionItem() button:SetActionItem(a:GetID()) button:DoAction() button:SetActionItem(old) return i end end\n"
        " return -3 end";
    case TempBag:return
        "return function(list,all)\n"
        " local e=Packet_Temporary_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1,0 end\n"
        " local n=Bank:GetTemBankItemNum()\n"
        " if all==1 then if n>0 then Bank:MoveAllTemBankItemToPacket() return 1,n end return 0,0 end\n"
        " local c=0\n"
        " for i=1,120 do local a,locked=Bank:EnumTemItem(i-1)\n"
        "  if a and a:GetID()~=0 and locked~=true and string.find(list,' '..a:GetName()..' ',1,true) then\n"
        "   local el=e['Packet_Temporary_ActionsList_auto_element'..(i-1)]\n"
        "   if el then local button=el:GetLuaActionButton('Packet_Temporary') if button then button:DoAction() c=c+1 end end end end\n"
        " return c,n end";
    case SweepCount:return "return function() return GetSecKillFuBenCount() end";
    case SweepEnum:return
        "return function(idx)\n"
        " local e=SweepAll_Env local function f(n) if type(e)=='table' and e[n] then return e[n] end return _G[n] end\n"
        " local id,icon,name,level,low,high,needType,needNum,double,yuanbao,action=f('EnumSecKillTable')(idx)\n"
        " local function nonnegative(v) return type(v)=='number' and v>=0 and v==math.floor(v) end\n"
        " if not nonnegative(low) or not nonnegative(high) or not nonnegative(needType) or not nonnegative(needNum) or not nonnegative(action) then error('campaign data unavailable') end\n"
        " local total=f('GetCampaignTotalNum')(action) local used=f('GetCampaignCountNum')(action)\n"
        " if type(total)~='number' or type(used)~='number' or total<0 or used<0 or used>total or total~=math.floor(total) or used~=math.floor(used) then error('campaign counts unavailable') end\n"
        " local left=total-used\n"
        " local fuben=f('Lua_SecKillGetFuBenIndexID_New')(idx)\n"
        " if name==nil or name=='' then name='nil' end\n"
        " return low or 0,high or 0,needType or 0,needNum or 0,action or 0,left,fuben or 0,name end";
    case SweepData:return
        "return function() local inSweep,fuben=GetSecKillData() return inSweep,fuben,Lua_SecKillGetIndexFromFuBenIndexID(fuben) end";
    case SweepOpenPage:return
        "return function(id) local e=SweepAll_Env local f=(type(e)=='table' and e.OpenSecKillPage) or OpenSecKillPage f(id,0) return 1 end";
    case SweepBoss:return
        "return function(title)\n"
        " local e=SweepPage_Env if type(e)~='table' then return -3 end\n"
        " local empty=e.SecKillItemListEmpty or SecKillItemListEmpty\n"
        " if empty()~=1 then return 0 end\n"
        " local caption=e.SweepPage_DragTitle:GetText()\n"
        " for i=1,6 do local boss=e['SweepPage_Boss'..i..'Name'] local done=e['SweepPage_Boss'..i..'finish']\n"
        "  if boss and boss:IsVisible() and done and done:IsVisible()==false then\n"
        "   if i>3 and string.find(caption,title,1,true) then return -2 end\n"
        "   e.SweepPage_OnBossButton(i) return i end end\n"
        " return -1 end";
    case OpenMonthlySign:return "return function() if type(OpenMonthlySign)~='function' then return -1 end OpenMonthlySign(1) return 1 end";
    case SelfTarget:return "return function(client,server) DataPool:SelectAsTargetByObjID(server) local present=Target:IsPresent() if not present or present==0 or Target:GetData('NPCID')~=client then return 0 end return 1 end";
    case CloseNamed:return "return function(n) CloseWindow(n,true) return 1 end";
    case ShopMoney:return
        "return function(amount)\n"
        " local e=PS_ShopMag_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1 end\n"
        " local all=PlayerShop:GetMoney('profit','self') if amount>all then amount=all end\n"
        " if amount<=0 then return 0 end PlayerShop:ApplyMoney('draw_ok',amount) return amount end";
    case GemList:return
        "return function(source,stone,level,talisman)\n"
        " local function vis(n) local e=_G[n..'_Env'] return type(e)=='table' and e.this and e.this:IsVisible() end\n"
        " local items={} local keys={}\n"
        " local function add(a,bind) if not a or a:GetID()==0 then return end local name=a:GetName()\n"
        "  if not name or not string.find(name,stone,1,true) or string.find(name,talisman,1,true) then return end\n"
        "  local _,_,lv=string.find(name,'(%d)'..level) if not lv then return end\n"
        "  local key=name..'\\t'..bind local v=keys[key] if not v then v={name,bind,0,lv} keys[key]=v table.insert(items,v) end v[3]=v[3]+a:GetNum() end\n"
        " if source==0 then local n=DataPool:GetBaseBag_Num()\n"
        "  for i=0,n-1 do local a,locked=PlayerPackage:EnumItem('base',i) if locked~=true then add(a,GetItemBindStatus(i) or 0) end end\n"
        " elseif source==1 then if not vis('BigBank') then return -1,'' end local b,n=Bank:GetRentBoxInfo(0)\n"
        "  for i=1,n do local a,locked=Bank:EnumItem(b+i-1) if locked~=true then add(a,-1) end end\n"
        " else if not vis('Packet_Temporary') then return -1,'' end\n"
        "  for i=1,120 do local a,locked=Bank:EnumTemItem(i-1) if locked~=true then add(a,-1) end end end\n"
        " local t='' local c=0\n"
        " for i=1,table.getn(items) do local v=items[i] local line=v[1]..'\\t'..v[2]..'\\t'..v[3]..'\\t'..v[4]..'\\n'\n"
        "  if string.len(t)+string.len(line)<=500 then t=t..line c=c+1 end end\n"
        " return c,t end";
    case GemCombine:return
        "return function(name,mode,count,title,talisman)\n"
        " local e=Gemcompose_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1 end\n"
        " local caption='' if e.Gemcompose_DragTitle then caption=e.Gemcompose_DragTitle:GetText() or '' end\n"
        " if not string.find(caption,title,1,true) then return -1 end\n"
        " local n=DataPool:GetBaseBag_Num() local gem=nil local tal=nil\n"
        " for i=0,n-1 do local a,locked=PlayerPackage:EnumItem('base',i)\n"
        "  if a and a:GetID()~=0 and locked~=true then local item=a:GetName()\n"
        "   if not gem and item==name and (mode==2 or (GetItemBindStatus(i) or 0)==mode) then gem=i end\n"
        "   if not tal and item==talisman then tal=i end end end\n"
        " if not gem then return -2 end if not tal then return -3 end\n"
        " local sel,odds=0,100 if count==4 then sel,odds=1,75 elseif count==3 then sel,odds=2,50 end\n"
        " LifeAbility:Do_Combine(gem,tal,sel,odds) return 1 end";
    default:return nullptr;
    }
}
}
