-- 游戏界面坐标；真实执行需要已验证的地图/位置/种植状态与动作适配器。
-- 此脚本不会直接调用系统键鼠、进程或内存 API。
local task = {
    id = "luoyang_plant",
    version = "0.2.0",
    context_schema = 1
}

function task.step(state, config, context)
    local function result(kind, message, extra)
        local r = extra or {}
        r.kind = kind
        r.message = message
        r.context = context
        return r
    end
    if config.operation ~= "move" and (not config.crop or config.crop == "") then
        return result("error", "请在面板填写作物参数")
    end
    if not state.position_valid then
        return result("error", "缺少已验证的角色位置")
    end
    if state.map ~= "洛阳" then
        return result("error", "请先进入洛阳；此测试不包含跨地图导航")
    end
    local dx, dy = state.x - config.x, state.y - config.y
    if config.operation == "move" then
        if dx * dx + dy * dy <= config.tolerance * config.tolerance then
            return result("complete", "真实位置已确认到达目标坐标")
        end
        context.phase = "moving"
        return result("move", "移动到目标坐标，等待真实位置确认", { x = config.x, y = config.y })
    end
    if context.start_count == nil then
        context.start_count = state.planted_count
    end
    local completed = state.planted_count - context.start_count
    if completed >= config.rounds then
        return result("complete", "已由状态确认完成指定次数")
    end
    if state.pending then
        return result("wait", "等待上一动作结果确认")
    end
    if dx * dx + dy * dy > config.tolerance * config.tolerance then
        context.phase = "moving"
        return result("move", "前往指定种植位置", { x = config.x, y = config.y })
    end
    if not state.seed_available then
        return result("error", "没有可用作物或种子")
    end
    if not state.can_plant then
        return result("wait", "当前位置暂不可种植，等待状态变化")
    end
    context.phase = "planting"
    return result("plant", "请求种植，等待结果确认", { crop = config.crop })
end

return task
