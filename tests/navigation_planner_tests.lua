local root = assert(arg[1], "Pass project root")
local planner = dofile(root .. "/scripts/navigation/city_travel.lua")
local passed = {}
local function clone(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, item in pairs(value) do copy[key] = clone(item) end
    return copy
end
local function fixture()
    local catalog = {
        runtime_enabled = true,
        policy = { max_hops = 4, max_action_attempts = 2, action_timeout_ms = 45000, task_timeout_ms = 180000 },
        cities = {
            { city_id = "suzhou", map_name = "苏州", npcs = {
                { npc_id = "fixture_npc", name = "测试传送员", enabled = true, verified = true,
                  position = { x = 10, y = 10 }, interaction_radius = 3,
                  destinations = {
                    { destination_id = "fixture_edge", target_city = "luoyang", enabled = true,
                      verified = true, dialog_option = { text = "前往洛阳" } }
                  } }
            } },
            { city_id = "luoyang", map_name = "洛阳", npcs = {} }
        }
    }
    local config = { navigation = catalog, target_city = "luoyang", target = { x = 360, y = 317, radius = 0.3 } }
    local state = {
        session_token = "fixture-session", now_ms = 0, map = "苏州", position_valid = true, x = 0, y = 0,
        capabilities = { map_position = true, pathfind_to = true, npc_interact = true,
                         dialog_read = true, dialog_select = true, map_change_confirm = true }
    }
    return state, config, {}
end
local function check(name, run)
    run()
    passed[#passed + 1] = name
end

check("disabled_data_never_produces_action", function()
    local s, c, ctx = fixture()
    c.navigation.runtime_enabled = false
    local r = planner.step(s, c, ctx)
    assert(r.kind == "blocked" and r.code == "navigation_disabled" and r.action == nil)
end)
check("unverified_npc_and_missing_coordinate_not_routable", function()
    local _, c = fixture()
    c.navigation.cities[1].npcs[1].verified = false
    local route, code = planner.find_route(c.navigation, "suzhou", "luoyang")
    assert(route == nil and code == "no_verified_route")
    c.navigation.cities[1].npcs[1].verified = true
    c.navigation.cities[1].npcs[1].position.x = nil
    assert(planner.find_route(c.navigation, "suzhou", "luoyang") == nil)
end)
check("directed_routes_do_not_invent_reverse_link", function()
    local _, c = fixture()
    assert(#assert(planner.find_route(c.navigation, "suzhou", "luoyang")) == 1)
    assert(planner.find_route(c.navigation, "luoyang", "suzhou") == nil)
end)
check("multi_hop_search_is_bounded_and_handles_cycles", function()
    local _, c = fixture()
    local mid = clone(c.navigation.cities[1])
    mid.city_id, mid.map_name = "mid", "测试中转"
    mid.npcs[1].npc_id = "mid_npc"
    mid.npcs[1].destinations[1].destination_id = "mid_to_luoyang"
    c.navigation.cities[1].npcs[1].destinations[1].target_city = "mid"
    table.insert(c.navigation.cities, mid)
    assert(#assert(planner.find_route(c.navigation, "suzhou", "luoyang")) == 2)
    c.navigation.policy.max_hops = 1
    assert(planner.find_route(c.navigation, "suzhou", "luoyang") == nil)
    c.navigation.policy.max_hops = 4
    mid.npcs[1].destinations[1].target_city = "suzhou"
    assert(planner.find_route(c.navigation, "suzhou", "luoyang") == nil)
end)
check("missing_pathfinding_does_not_abuse_nearby_move", function()
    local s, c, ctx = fixture()
    s.capabilities.pathfind_to = false
    local r = planner.step(s, c, ctx)
    assert(r.kind == "blocked" and r.code == "missing_capability:pathfind_to" and not r.action)
end)
check("pending_navigation_not_resubmitted_without_confirmation", function()
    local s, c, ctx = fixture()
    local r = planner.step(s, c, ctx)
    assert(r.kind == "action" and r.action.kind == "navigate_to")
    local id = r.action.request_id
    s.now_ms = 500
    r = planner.step(s, c, ctx)
    assert(r.kind == "wait" and not r.action and ctx.pending.request_id == id and ctx.sequence == 1)
end)
check("full_planned_sequence_requires_real_map_and_final_position", function()
    local s, c, ctx = fixture()
    local r = planner.step(s, c, ctx)
    assert(r.action.kind == "navigate_to")
    s.x, s.y, s.now_ms = 10, 10, 500
    r = planner.step(s, c, ctx)
    assert(r.action.kind == "interact_npc")
    s.dialog = { npc_id = "fixture_npc", options = { "前往洛阳" } }
    s.now_ms = 1000
    r = planner.step(s, c, ctx)
    assert(r.action.kind == "select_destination")
    s.feedback = { request_id = r.action.request_id, status = "success" }
    s.now_ms = 1500
    r = planner.step(s, c, ctx)
    assert(r.kind == "wait" and r.code == "await_real_state_after_ack")
    s.map, s.x, s.y, s.now_ms, s.dialog, s.feedback = "洛阳", 1, 1, 2000, nil, nil
    r = planner.step(s, c, ctx)
    assert(r.action.kind == "navigate_to" and r.action.purpose == "final_destination")
    s.x, s.y, s.now_ms = 359.95, 317.1, 2500
    r = planner.step(s, c, ctx)
    assert(r.kind == "complete" and r.code == "target_position_confirmed")
end)
check("already_in_target_city_skips_teleporter", function()
    local s, c, ctx = fixture()
    s.map, s.x, s.y = "洛阳", 360, 317
    s.capabilities = { map_position = true }
    assert(planner.step(s, c, ctx).kind == "complete")
end)
check("wrong_npc_and_missing_option_block_instead_of_clicking", function()
    local s, c, ctx = fixture()
    s.x, s.y = 10, 10
    assert(planner.step(s, c, ctx).action.kind == "interact_npc")
    s.dialog = { npc_id = "wrong_npc", options = { "前往洛阳" } }
    assert(planner.step(s, c, ctx).code == "wrong_npc_dialog")
    s, c, ctx = fixture()
    s.x, s.y = 10, 10
    planner.step(s, c, ctx)
    s.dialog = { npc_id = "fixture_npc", options = { "其他选项" } }
    assert(planner.step(s, c, ctx).code == "destination_option_missing")
end)
check("session_change_and_unexpected_map_do_not_reuse_pending_action", function()
    local s, c, ctx = fixture()
    planner.step(s, c, ctx)
    s.session_token = "different-session"
    assert(planner.step(s, c, ctx).code == "session_changed")
    s, c, ctx = fixture()
    planner.step(s, c, ctx)
    s.map = "其他城市"
    assert(planner.step(s, c, ctx).code == "map_changed_during_navigation")
end)
check("action_and_total_timeouts_are_finite", function()
    local s, c, ctx = fixture()
    planner.step(s, c, ctx)
    s.loading, s.position_valid, s.now_ms = true, false, 45000
    assert(planner.step(s, c, ctx).code == "action_timeout:navigate_to")
    s, c, ctx = fixture()
    s.manual_control = true
    planner.step(s, c, ctx)
    s.now_ms = 180000
    assert(planner.step(s, c, ctx).code == "task_timeout")
end)
check("retry_limit_and_stale_feedback_prevent_action_storm", function()
    local s, c, ctx = fixture()
    local r = planner.step(s, c, ctx)
    s.feedback = { request_id = "stale", status = "failed" }
    assert(planner.step(s, c, ctx).kind == "wait")
    s.feedback = { request_id = r.action.request_id, status = "failed" }
    r = planner.step(s, c, ctx)
    assert(r.kind == "action" and ctx.sequence == 2)
    s.feedback.request_id = r.action.request_id
    assert(planner.step(s, c, ctx).code == "retry_limit")
end)
check("confirmed_cancel_allows_safe_replan_after_manual_city_change", function()
    local s, c, ctx = fixture()
    local r = planner.step(s, c, ctx)
    s.map, s.x, s.y = "洛阳", 360, 317
    s.feedback = { request_id = r.action.request_id, status = "cancelled" }
    assert(planner.step(s, c, ctx).code == "replan_after_cancel")
    assert(planner.step(s, c, ctx).kind == "complete")
end)
check("invalid_goal_and_clock_are_rejected", function()
    local s, c, ctx = fixture()
    c.target.x = -1
    assert(planner.step(s, c, ctx).code == "invalid_target")
    s, c, ctx = fixture()
    s.now_ms = 100
    planner.step(s, c, ctx)
    s.now_ms = 90
    assert(planner.step(s, c, ctx).code == "clock_rewound")
end)

local quoted = {}
for _, name in ipairs(passed) do quoted[#quoted + 1] = string.format("%q", name) end
io.write('{"status":"pass","count":' .. #passed .. ',"checks":[' .. table.concat(quoted, ",")
    .. '],"real_game_actions":0,"scope":"pure planner fixtures only"}\n')
