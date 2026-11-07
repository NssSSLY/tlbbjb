-- Adapted from the supplied assistant's WaitForTime examples to this engine's step API.
-- No legacy DLL, blocking Sleep, keyboard, process API or game action is required.
local task = { id = "wait_until", version = "1.0.0", context_schema = 1 }

function task.step(state, config, context)
    local done
    if config.wait_kind == "指定时刻" then
        done = state.now_ms >= config.target_epoch_ms
    elseif config.wait_kind == "等待时长" then
        done = state.active_elapsed_ms >= config.wait_seconds * 1000
    else
        return {kind = "error", message = "等待方式无效", context = context}
    end
    return {
        kind = done and "complete" or "wait",
        message = done and "等待结束，继续下一任务" or "等待时间条件",
        context = context
    }
end

return task
