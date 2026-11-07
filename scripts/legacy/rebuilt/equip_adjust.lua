-- 装备资质鉴定：由 dfz64.dll 字节码模块 其他/装备资质鉴定.lua 静态还原
-- 模块 SHA256 82ab88d8760478df21f5af1b8bb933d43f2b35c33745bb5f5c8148d231781c48；原规则逐格判断“可鉴定且资质点为 0”后发送 FinishAdjust，本程序在游戏内一次完成同样的逐格判断和发送（间隔原为 50 毫秒）。
PushDebugMessage("鉴定：自动鉴定武器资质")
function _SMain()
    EquipAdjustAll()
end
_SMain()
