-- Pure directed planner. The resident navigation_runtime adapter executes its verified hops.
local task = { id = "city_travel", version = "0.1.0", context_schema = 1 }

local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
local function text(s)
    return type(s) == "string" and #s > 0 and #s <= 256
end
local function position(p)
    return type(p) == "table" and finite(p.x) and finite(p.y)
        and p.x >= 0 and p.y >= 0 and p.x <= 10000 and p.y <= 10000
end
local function city_by_id(catalog, id)
    for _, city in ipairs(catalog.cities or {}) do
        if city.city_id == id then return city end
    end
end
local function city_by_map(catalog, map)
    for _, city in ipairs(catalog.cities or {}) do
        if city.map_name == map then return city end
        for _, alias in ipairs(city.map_aliases or {}) do
            if alias == map then return city end
        end
    end
end
local function usable(npc, edge)
    return npc.enabled == true and npc.verified == true and text(npc.name)
        and text(npc.npc_id) and position(npc.position)
        and edge.enabled == true and edge.verified == true
        and type(edge.dialog_option) == "table" and text(edge.dialog_option.text)
end

-- Directed BFS. A reverse link is never invented; only verified edges are used.
function task.find_route(catalog, source_id, target_id)
    if not city_by_id(catalog, source_id) then return nil, "source_city_unknown" end
    if not city_by_id(catalog, target_id) then return nil, "target_city_unknown" end
    if source_id == target_id then return {} end
    local max_hops = catalog.policy and catalog.policy.max_hops or 4
    if not finite(max_hops) or max_hops < 1 or max_hops > 8 or max_hops % 1 ~= 0 then
        return nil, "invalid_max_hops"
    end
    if #(catalog.cities or {}) > 128 then return nil, "catalog_too_large" end
    local queue, cursor, visited = { { id = source_id, route = {} } }, 1, { [source_id] = true }
    while queue[cursor] do
        local current = queue[cursor]
        cursor = cursor + 1
        if #current.route < max_hops then
            local city = city_by_id(catalog, current.id)
            for _, npc in ipairs(city.npcs or {}) do
                for _, edge in ipairs(npc.destinations or {}) do
                    local target = city_by_id(catalog, edge.target_city)
                    if target and not visited[target.city_id] and usable(npc, edge) then
                        local route = {}
                        for i, hop in ipairs(current.route) do route[i] = hop end
                        route[#route + 1] = {
                            from_city = city.city_id, from_map = city.map_name,
                            to_city = target.city_id, to_map = target.map_name,
                            npc_id = npc.npc_id, npc_name = npc.name,
                            x = npc.position.x, y = npc.position.y,
                            radius = npc.interaction_radius or 3,
                            option_text = edge.dialog_option.text,
                            destination_id = edge.destination_id
                        }
                        if target.city_id == target_id then return route end
                        visited[target.city_id] = true
                        queue[#queue + 1] = { id = target.city_id, route = route }
                    end
                end
            end
        end
    end
    return nil, "no_verified_route"
end

function task.step(state, config, context)
    context = context or {}
    local function result(kind, code, action)
        return { kind = kind, code = code, action = action, context = context }
    end
    local function fail(code)
        context.terminal = code
        return result("blocked", code)
    end
    local catalog = config.navigation
    if type(catalog) ~= "table" or catalog.runtime_enabled ~= true then
        return result("blocked", "navigation_disabled")
    end
    if not text(state.session_token) or not finite(state.now_ms) then
        return fail("missing_session_or_clock")
    end
    if context.session_token and context.session_token ~= state.session_token then
        return fail("session_changed")
    end
    if context.terminal then return result("blocked", context.terminal) end
    if not position(config.target) or not finite(config.target.radius)
        or config.target.radius <= 0 or config.target.radius > 10 then
        return fail("invalid_target")
    end
    local destination = city_by_id(catalog, config.target_city)
    if not destination then return fail("target_city_unknown") end
    context.session_token = state.session_token
    context.started_ms = context.started_ms or state.now_ms
    context.sequence = context.sequence or 0
    context.phase = context.phase or "plan"
    context.hop = context.hop or 1
    context.attempts = context.attempts or 0
    local signature = config.target_city .. ":" .. config.target.x .. ":" .. config.target.y
        .. ":" .. config.target.radius
    if context.signature and context.signature ~= signature then return fail("request_changed") end
    context.signature = signature
    if context.last_ms and state.now_ms < context.last_ms then return fail("clock_rewound") end
    context.last_ms = state.now_ms
    local policy = catalog.policy or {}
    local timeout = policy.action_timeout_ms or 45000
    local total_timeout = policy.task_timeout_ms or 180000
    local max_attempts = policy.max_action_attempts or 2
    if not finite(timeout) or timeout < 1000 or timeout > 600000
        or not finite(total_timeout) or total_timeout < timeout or total_timeout > 3600000
        or not finite(max_attempts) or max_attempts < 1 or max_attempts > 5 or max_attempts % 1 ~= 0 then
        return fail("invalid_time_or_retry_policy")
    end
    if state.now_ms - context.started_ms >= total_timeout then return fail("task_timeout") end
    if context.pending and state.now_ms - context.pending.started_ms >= timeout then
        return fail("action_timeout:" .. context.pending.kind)
    end
    if state.manual_control == true then return result("wait", "manual_control") end
    if state.loading == true or state.position_valid ~= true or not position(state) then
        return result("wait", "await_real_position")
    end
    if not state.capabilities or state.capabilities.map_position ~= true then
        return fail("missing_capability:map_position")
    end
    local function arrived(map, x, y, radius)
        local dx, dy = state.x - x, state.y - y
        return state.map == map and dx * dx + dy * dy <= radius * radius
    end
    local function emit(kind, capability, fields)
        if not state.capabilities or state.capabilities[capability] ~= true then
            return fail("missing_capability:" .. capability)
        end
        if kind == "interact_npc" and state.capabilities.dialog_read ~= true then
            return fail("missing_capability:dialog_read")
        end
        if kind == "select_destination" and state.capabilities.map_change_confirm ~= true then
            return fail("missing_capability:map_change_confirm")
        end
        context.sequence = context.sequence + 1
        fields.kind = kind
        fields.request_id = state.session_token .. "/travel/" .. context.sequence
        fields.started_ms = state.now_ms
        context.pending = fields
        return result("action", kind, fields)
    end
    local pending = context.pending
    if pending then
        local feedback = state.feedback or {}
        if feedback.request_id == pending.request_id and feedback.status == "cancelled" then
            context.pending, context.route, context.phase = nil, nil, "plan"
            return result("wait", "replan_after_cancel")
        end
        local completed = false
        if pending.kind == "navigate_to" then
            if state.map ~= pending.map then return fail("map_changed_during_navigation") end
            completed = arrived(pending.map, pending.x, pending.y, pending.radius)
        elseif pending.kind == "interact_npc" then
            if state.map ~= pending.map then return fail("map_changed_during_dialog") end
            if state.dialog and state.dialog.npc_id ~= pending.npc_id then
                return fail("wrong_npc_dialog")
            end
            completed = state.dialog and state.dialog.npc_id == pending.npc_id
                and type(state.dialog.options) == "table"
        elseif pending.kind == "select_destination" then
            completed = state.map == pending.to_map
            if state.map ~= pending.from_map and not completed then return fail("unexpected_arrival_map") end
        else
            return fail("unknown_pending_action")
        end
        if completed then
            context.pending, context.attempts = nil, 0
            if pending.kind == "interact_npc" then context.phase = "select" end
            if pending.kind == "select_destination" then
                context.hop = context.hop + 1
                context.phase = "approach"
            end
        else
            if feedback.request_id ~= pending.request_id then return result("wait", "await_action_confirmation") end
            if feedback.status == "failed" then
                if pending.kind == "select_destination" and feedback.safe_to_retry ~= true then
                    return fail("teleport_result_uncertain")
                end
                context.attempts = context.attempts + 1
                if context.attempts >= max_attempts then return fail("retry_limit") end
                context.pending = nil
                if pending.kind == "select_destination" then context.phase = "select" end
            else
                -- A click/command acknowledgement is not map/position confirmation.
                return result("wait", "await_real_state_after_ack")
            end
        end
    end
    for _ = 1, 8 do
        if context.phase == "plan" then
            local source = city_by_map(catalog, state.map)
            if not source then return fail("source_city_unknown") end
            local route, error_code = task.find_route(catalog, source.city_id, destination.city_id)
            if not route then return fail(error_code) end
            context.route, context.hop, context.phase = route, 1, "approach"
        elseif context.phase == "approach" then
            local hop = context.route[context.hop]
            if not hop then
                context.phase = "final"
            elseif state.map ~= hop.from_map then
                return fail("route_source_changed")
            elseif arrived(hop.from_map, hop.x, hop.y, hop.radius) then
                context.phase = "open_dialog"
            else
                return emit("navigate_to", "pathfind_to", {
                    map = hop.from_map, x = hop.x, y = hop.y, radius = hop.radius,
                    purpose = "approach_transport_npc", npc_id = hop.npc_id
                })
            end
        elseif context.phase == "open_dialog" then
            local hop = context.route[context.hop]
            return emit("interact_npc", "npc_interact", {
                map = hop.from_map, npc_id = hop.npc_id, npc_name = hop.npc_name
            })
        elseif context.phase == "select" then
            local hop = context.route[context.hop]
            if not state.dialog or state.dialog.npc_id ~= hop.npc_id then return fail("dialog_not_confirmed") end
            local matched = false
            for _, option in ipairs(state.dialog.options or {}) do
                if option == hop.option_text then matched = true end
            end
            if not matched then return fail("destination_option_missing") end
            return emit("select_destination", "dialog_select", {
                npc_id = hop.npc_id, destination_id = hop.destination_id,
                option_text = hop.option_text, from_map = hop.from_map, to_map = hop.to_map
            })
        elseif context.phase == "final" then
            if state.map ~= destination.map_name then return fail("target_map_not_confirmed") end
            if arrived(destination.map_name, config.target.x, config.target.y, config.target.radius) then
                context.phase = "complete"
                return result("complete", "target_position_confirmed")
            end
            return emit("navigate_to", "pathfind_to", {
                map = destination.map_name, x = config.target.x, y = config.target.y,
                radius = config.target.radius, purpose = "final_destination"
            })
        elseif context.phase == "complete" then
            return result("complete", "target_position_confirmed")
        else
            return fail("invalid_phase")
        end
    end
    return fail("planner_transition_limit")
end

CityTravelPlanner=task
return task
