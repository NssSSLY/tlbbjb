-- 反编译自 dfz64.dll 内嵌字节码 00462a35（unluac 2025-12-23；仅供分析）
local m_script_name = "商会存物"
ScriptOnStart(m_script_name, false, false)
GlobalParam_shgl()
g_config.shcw = {}
g_config.shcw.id_text = g_config.shgl.id_text
g_config.shcw.open_item = GetItemConfigText(g_self.name, "物品", "商会存")
g_config.shcw.close_item = GetItemConfigText(g_self.name, "物品", "商会存打烊")
g_config.shcw.with_list_item = ReadConfigBool("ZH", "xzk32")
g_config.shcw.with_sh_item = ReadConfigBool("ZH", "xzk43")
g_config.shcw.bank_take = ReadConfigBool("ZH", "xzk268")
local m_param = {}
m_param.sh_ID_text = g_config.shcw.id_text
m_param.sh_ID = {}
m_param.list_item = {}
m_param.sh_open_item = {}
m_param.sh_close_item = {}

local function SHCW_insert_item(aItem, aOpen)
  for i = 1, #aItem do
    local tmp = aItem[i]
    if aOpen then
      if FindTableFieldValue(m_param.list_item, "name", tmp.name) == false and false == FindTableFieldValue(m_param.sh_open_item, "name", tmp.name) then
        table.insert(m_param.sh_open_item, {
          name = tmp.name,
          price_mode = 0,
          price_query_single = 0,
          price_min_single = 0,
          price_gd_single = 0,
          split_num = 0,
          price_query = 0
        })
      end
    elseif false == FindTableFieldValue(m_param.sh_close_item, "name", tmp.name) then
      table.insert(m_param.sh_close_item, {
        name = tmp.name,
        price_mode = 0,
        price_query_single = 0,
        price_min_single = 0,
        price_gd_single = 0,
        split_num = 0,
        price_query = 0
      })
    end
  end
end

function _SMain()
  LoadScript("shanghui")
  ClearBag()
  CloseAllWindow()
  if not CheckMibao(true) then
    LogMsg(m_script_name .. ":未解锁密保")
    return
  end
  m_param.sh_ID = SH_init_SHID(m_param.sh_ID_text)
  if 0 == #m_param.sh_ID then
    PushDebugMessage(m_script_name .. "：未解析到正确的商会ID,请检查！")
    return
  end
  if g_config.shcw.with_list_item then
    m_param.list_item = SHGL_EnumItemList()
  end
  if g_config.shcw.with_sh_item then
    local tSHID = SH_init_SHID(m_param.sh_ID_text)
    while true do
      local openID = SH_OpenManage(tSHID)
      if openID > 0 then
        local nStallNum = PlayerShop_GetStallNum()
        for page = 1, nStallNum do
          PlayerShop_ClickPage(page)
          local tItem = PlayerShop_EnumPageObj(page)
          if 2 == PlayerShop_IsOpenStall(page) then
            SHCW_insert_item(tItem, true)
          else
            SHCW_insert_item(tItem, false)
          end
        end
        tSHID = DeleteTableFieldValue(tSHID, "id", {openID})
        CloseWindow("PS_ShopMag")
      elseif -2 == openID then
        PushDebugMessage(m_script_name .. "：统计需存入的物品完成")
        break
      end
      Sleep(500)
      DebugStr(m_script_name .. "：,正在统计需存入的物品")
    end
  end
  local strSaveBankItem = ""
  local ItemText_open = HandleText_AddFuHao(HandleText(g_config.shcw.open_item))
  local ItemText_close = HandleText_AddFuHao(HandleText(g_config.shcw.close_item))
  for i = 1, #m_param.list_item do
    local tmp = m_param.list_item[i]
    local str = tmp.name .. "|" .. tmp.split_num
    ItemText_open = ItemText_open .. str .. " "
    strSaveBankItem = strSaveBankItem .. tmp.name .. " "
  end
  for i = 1, #m_param.sh_open_item do
    local tmp = m_param.sh_open_item[i]
    local str = tmp.name .. "|" .. tmp.split_num
    ItemText_open = ItemText_open .. str .. " "
    strSaveBankItem = strSaveBankItem .. tmp.name .. " "
  end
  for i = 1, #m_param.sh_close_item do
    local tmp = m_param.sh_close_item[i]
    local str = tmp.name .. "|" .. tmp.split_num
    ItemText_close = ItemText_close .. str .. " "
    strSaveBankItem = strSaveBankItem .. tmp.name .. " "
  end
  SHCW_OnStart(m_param.sh_ID_text, ItemText_open, ItemText_close, g_config.shcw.bank_take)
  if g_config.shcw.bank_take then
    PushColorMsg("商会存物:剩余物品存入仓库")
    Bank_SaveItem(strSaveBankItem, -1, 1)
    Bag_Move2TempBank()
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
