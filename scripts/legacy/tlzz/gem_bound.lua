PushDebugMessage("自动仓库取宝石,只合绑定")

g_GemHCnum = 5 --几个宝石合一，可填3、4、5
g_GemHCMS = 1  --宝石合成模式 0:只合不绑定，1只合成绑定，2：混合在一起

LoadScript("fnInterface")        --加载

MainHCGem()                      --执行

LoadScript("[功能] 物品存仓")    --合成结束后存仓

