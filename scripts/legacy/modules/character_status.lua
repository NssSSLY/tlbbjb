-- 常驻引擎扩展示例：新增模块无需改 C++。
-- 任务中 LoadScript("character_status") 后调用 ReadCharacterVitals()。
function ReadCharacterVitals()
    local hp,maximum=GetLuaValue("return Player:GetData('HP'),Player:GetData('MAXHP')","nn",2)
    return hp,maximum
end
