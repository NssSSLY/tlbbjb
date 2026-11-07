--支持输入负数 例：local nNeedMoney = -5*10000,表示仓库只保留5金，其他全部取出来,可用于将多余金币交易给老板
-- 默认取5J 自己可修改
local nNeedMoney = 5 * 10000



--下面的看不懂不要改
PushDebugMessage("前往银行自动取钱,修改取钱数量请在界面点编辑后保存")

Bank_GetMoney(nNeedMoney)