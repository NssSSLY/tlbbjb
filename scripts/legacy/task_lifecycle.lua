-- Shared task lifecycle. A script may return {check=...,run=...,verify=...}.
-- Original scripts keep their code and use an external adapter to provide checks.
local reportTask,taskLog=host,log
local function quoted(s)
    return '"'..tostring(s):gsub('[%z\1-\31\\"]',function(c)return string.format("\\u%04x",c:byte()) end)..'"'
end
TaskLifecycle={}
function TaskLifecycle.report(status,message)
    assert(status=="done" or status=="already_done" or status=="limit_reached","Invalid task result")
    local value={status=status,message=tostring(message or status),verified=true}
    TaskResult=value
    reportTask("task_result",'{"status":'..quoted(status)..',"message":'..quoted(value.message)..',"verified":true}')
    taskLog(value.message);return value
end
function TaskLifecycle.skip(status,message) return {__task_terminal=true,status=status,message=message} end
function TaskLifecycle.run(body,verify)
    local ok,result=pcall(body)
    if not ok then
        if type(result)=="table" and result.__task_terminal then return TaskLifecycle.report(result.status,result.message) end
        error(result,0)
    end
    local state,message=verify()
    if state=="done" or state=="already_done" or state=="limit_reached" then return TaskLifecycle.report(state,message) end
    error(message or "任务退出，但完成条件未确认；未进入下一项",0)
end
function RunTaskDefinition(definition)
    assert(type(definition.check)=="function" and type(definition.run)=="function" and type(definition.verify)=="function",
        "模块任务需要 check、run、verify，不能把 Lua 返回当作任务完成")
    local state,message=definition.check(TaskConfig or {})
    if state=="done" or state=="already_done" or state=="limit_reached" then return TaskLifecycle.report(state,message) end
    assert(state=="ready",message or "任务前置条件尚未满足")
    return TaskLifecycle.run(function()return definition.run(TaskConfig or {})end,function()return definition.verify(TaskConfig or {})end)
end
