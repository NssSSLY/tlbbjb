for i = 1, 5 do
    DelBagItem(-1) --清理
    local bRet1 = T_eatBindItem() --消化绑定物品、开宝箱
    DelBagItem(-1) --清理
    local bRet2 = BankTemp2Bag("ALL_ITEM", 1) --从锦囊取出物品.参数1填物品名称，空格分开。ALL_ITEM代表所有物品
    if bRet1 == false and bRet2 == false then
        break --
    end
    Sleep(100)
end
