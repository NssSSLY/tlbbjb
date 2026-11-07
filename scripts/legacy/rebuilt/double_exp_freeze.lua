-- [功能] 冻结双倍经验：由 dfz64.dll 字节码模块 功能/[功能] 冻结双倍经验.lua 静态还原
-- 模块 SHA256 390bf7bcd08d0bb1c16b4461ce032753ec8affe11099f294a9961e249a31e54c；调用与参数按反汇编保持；冻结流程见 compat.lua 的 DoubleExp_Freeze（依据 functions.lua 同名函数）。
PushDebugMessage("冻双：就近冻结双倍经验！")
DoubleExp_Freeze()
