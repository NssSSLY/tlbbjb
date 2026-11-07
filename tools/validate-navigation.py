"""Validate user-editable transport data; never enables routes or connects to games."""
from pathlib import Path
import json
import math

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "scripts/navigation"
catalog = json.loads((BASE / "catalog.json").read_text(encoding="utf-8"))
assert catalog["schema_version"] == 1 and isinstance(catalog["runtime_enabled"], bool)
assert 1 <= len(catalog["city_files"]) <= 128
assert len(set(catalog["city_files"])) == len(catalog["city_files"])
cities, pending, pending_routes, ids, npc_ids, edge_ids, names = [], [], [], set(), set(), set(), set()

def valid_number(n):
    return isinstance(n, (int, float)) and not isinstance(n, bool) and math.isfinite(n)

policy = catalog["policy"]
for key, low, high in [("max_hops", 1, 8), ("max_action_attempts", 1, 5), ("action_timeout_ms", 1000, 600000), ("task_timeout_ms", 1000, 3600000), ("poll_interval_ms", 100, 10000)]:
    assert type(policy[key]) is int and low <= policy[key] <= high, f"Invalid {key}"
assert policy["task_timeout_ms"] >= policy["action_timeout_ms"]

for relative in catalog["city_files"]:
    file = (BASE / relative).resolve()
    assert file.is_relative_to(BASE.resolve()) and not file.is_symlink(), "City path escapes data directory"
    city = json.loads(file.read_text(encoding="utf-8"))
    assert city["schema_version"] == 1
    assert city["city_id"] and city["city_id"] not in ids
    ids.add(city["city_id"])
    for name in [city["map_name"], *city["map_aliases"]]:
        assert isinstance(name, str) and name.strip() and name not in names, "Ambiguous map name"
        names.add(name)
    assert len(city["npcs"]) <= 32
    for npc in city["npcs"]:
        assert npc["npc_id"] not in npc_ids
        npc_ids.add(npc["npc_id"])
        assert isinstance(npc["enabled"], bool) and isinstance(npc["verified"], bool)
        missing = []
        if not npc["name"]:
            missing.append("NPC 名称")
        elif not isinstance(npc["name"], str) or len(npc["name"]) > 64:
            raise AssertionError("Invalid NPC name")
        for coordinate in ("x", "y"):
            value = npc["position"][coordinate]
            if value is None:
                missing.append(f"NPC {coordinate.upper()} 坐标")
            else:
                assert valid_number(value) and 0 <= value <= 10000, "Invalid coordinate"
        assert valid_number(npc["interaction_radius"]) and 0 < npc["interaction_radius"] <= 10
        assert len(npc["approach_waypoints"]) <= 128
        for waypoint in npc["approach_waypoints"]:
            assert all(valid_number(waypoint[key]) and 0 <= waypoint[key] <= 10000 for key in ("x", "y"))
        assert len(npc["destinations"]) <= 32
        for edge in npc["destinations"]:
            assert isinstance(edge["enabled"], bool) and isinstance(edge["verified"], bool)
            assert edge["destination_id"] not in edge_ids
            edge_ids.add(edge["destination_id"])
            option = edge["dialog_option"]
            text = option["text"]
            assert text is None or isinstance(text, str) and 0 < len(text) <= 128
            index = option["index_1_based"]
            assert index is None or type(index) is int and 1 <= index <= 128
            if edge["enabled"] or edge["verified"]:
                assert npc["enabled"] and npc["verified"] and not missing and text, "Enabled route lacks verified data"
            if not text or not edge["verified"]:
                pending_routes.append({"city": city["map_name"], "npc_id": npc["npc_id"], "target_city": edge["target_city"], "missing": (["传送菜单文字"] if not text else []) + (["线路核对"] if not edge["verified"] else [])})
        if npc["enabled"] or npc["verified"]:
            assert not missing, "NPC enabled before required data supplied"
        if missing or not npc["verified"]:
            pending.append({"city": city["map_name"], "npc_id": npc["npc_id"], "missing": missing, "enabled": npc["enabled"], "verified": npc["verified"]})
    cities.append(city)

by_id = {c["city_id"]: c for c in cities}
for city in cities:
    for npc in city["npcs"]:
        for edge in npc["destinations"]:
            assert edge["target_city"] in ids, "Unknown destination city"
            assert edge["expected_arrival"]["map_name"] == by_id[edge["target_city"]]["map_name"]

merged = {**catalog, "cities": cities}
out = ROOT / "artifacts/navigation"
out.mkdir(parents=True, exist_ok=True)
(out / "compiled-catalog.json").write_text(json.dumps(merged, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
report = {"status": "pass", "runtime_enabled": catalog["runtime_enabled"], "city_count": len(cities), "npc_count": len(npc_ids), "pending_data": pending, "pending_routes": pending_routes, "real_game_actions": 0, "scope": "data validation only; no Worker integration"}
(out / "catalog-validation.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, ensure_ascii=False))
