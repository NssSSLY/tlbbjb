-- [功能] 领取双倍经验：由 dfz64.dll 字节码模块 功能/[功能] 领取双倍经验.lua 静态还原
-- 模块 SHA256 4cb2bf699cc79c00d084af410b2fa7e3a2e642c33a0e9ba8a65fdd76a22c43db；调用与参数按反汇编保持；领取流程见 compat.lua 的 DoubleExp_Get（依据 functions.lua 同名函数）。
PushDebugMessage("领双：就近领取或解冻双倍经验!")
DoubleExp_Get(120)
