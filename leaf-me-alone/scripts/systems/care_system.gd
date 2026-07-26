extends Node
## Water and fertilize care actions during Pause — EconomySystem spend + GridData plant state.

const RunEventRes := preload("res://scripts/data/run_event.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")

const WATER_DISSAT_REDUCTION := 15
const FERTILIZE_DISSAT_REDUCTION := 10
const FERTILIZE_HP_RESTORE := 20


func _ready() -> void:
	add_to_group("care_system")


func try_water(cell: Vector2i) -> bool:
	return _try_care(cell, "water")


func try_fertilize(cell: Vector2i) -> bool:
	return _try_care(cell, "fertilize")


func _try_care(cell: Vector2i, care_type: String) -> bool:
	var grid := RunManager.grid_data
	if grid == null or not grid.has_plant(cell):
		return false
	var economy_def := ContentRegistry.get_economy()
	if economy_def == null:
		return false
	var cost := economy_def.water_cost if care_type == "water" else economy_def.fertilize_cost
	var economy := _get_economy()
	if economy == null or not economy.try_spend(cost):
		return false

	if care_type == "water":
		grid.adjust_plant_dissatisfaction(cell, -WATER_DISSAT_REDUCTION)
	elif care_type == "fertilize":
		grid.adjust_plant_dissatisfaction(cell, -FERTILIZE_DISSAT_REDUCTION)
		grid.set_plant_hp(cell, grid.get_plant_hp(cell) + FERTILIZE_HP_RESTORE)

	EventBus.emit_run_event(
		RunEventRes.Type.PLANT_CARED,
		{"cell": cell, "care_type": care_type, "cost": cost}
	)
	return true


func _get_economy() -> EconomySystemScript:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return null
	return nodes[0] as EconomySystemScript
