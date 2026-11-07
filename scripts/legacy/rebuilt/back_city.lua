-- [功能] 回城：由 dfz64.dll 字节码模块 功能/[功能] 回城.lua 静态还原
-- 模块 SHA256 683be75fea59ff6ffe3bf205183e27c102401f19e9a7db4f08ca466ff3b8015c；调用按反汇编保持；原程序读“通用”页的空闲地图名，本程序改为任务设置里的场景号与坐标。
function _SMain()
    GlobalParam_tysz()
    GoBackCity()
end
_SMain()
