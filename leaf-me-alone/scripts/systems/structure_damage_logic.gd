class_name StructureDamageLogic
extends RefCounted
## Structure damage and loss evaluation (Story 5.2).

const StructureTypeRes := preload("res://scripts/data/structure_type.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")


static func get_damage_for_role(role_id: String) -> int:
	return int(GameConstantsRes.STRUCTURE_DAMAGE_BY_ROLE.get(role_id, GameConstantsRes.STRUCTURE_ATTACK_DAMAGE))


static func evaluate_loss(core_hp: int, nest_states: Array) -> String:
	if core_hp <= 0:
		return "forest_core_destroyed"
	var living := count_living_nests(nest_states)
	if living <= 0:
		return "all_nests_destroyed"
	return ""


static func count_living_nests(nest_states: Array) -> int:
	var count := 0
	for entry in nest_states:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if int(entry.get("current_hp", 0)) > 0:
			count += 1
	return count


static func is_attackable_structure_cell(grid: GridData, cell: Vector2i) -> bool:
	if grid == null or not grid.is_in_bounds(cell):
		return false
	var entry := grid.get_structure_at(cell)
	if entry.is_empty():
		return false
	return int(entry.get("current_hp", 0)) > 0
