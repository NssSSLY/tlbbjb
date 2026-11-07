-- 领取活跃好礼：由 dfz64.dll 字节码模块 日常/领取活跃好礼.lua 静态还原
-- 模块 SHA256 ca8f496a931467c6629003002b1c08339b56b6628d19ee1443da14d0aae0ca06；活跃度档位与请求见 compat.lua 的 LingQuHuoYueHaoLi（依据 common.lua 同名函数）。
local m_script_name = "领取活跃好礼"
ScriptOnStart(m_script_name, false, false)
LingQuHuoYueHaoLi(true)
ScriptOnStop(m_script_name)
