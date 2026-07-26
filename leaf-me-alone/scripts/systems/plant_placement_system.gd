extends Node
## Validates and executes plant placement — EconomySystem spend + GridData authority.
## Events emitted: PLANT_PLACED (via EventBus)

const RunEventRes := preload("res://scripts/data/run_event.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")


func _ready() -> void:
	add_to_group("plant_placement_system")


func can_preview_place(cell: Vector2i, species_id: String) -> bool:
	var grid := RunManager.grid_data
	if grid == null or not grid.can_place_plant(cell):
		return false
	var species := ContentRegistry.get_species(species_id)
	if species == null:
		return false
	var economy := _get_economy()
	if economy == null or economy.get_balance() < species.plant_cost:
		return false
	return true


func try_place_plant(cell: Vector2i, species_id: String) -> bool:
	var grid := RunManager.grid_data
	if grid == null:
		return false
	if not grid.can_place_plant(cell):
		return false
	var species := ContentRegistry.get_species(species_id)
	if species == null:
		return false
	var economy := _get_economy()
	if economy == null or not economy.try_spend(species.plant_cost):
		return false
	if not grid.place_plant(cell, species_id):
		if economy.has_method("try_earn"):
			economy.try_earn(species.plant_cost)
		return false
	EventBus.emit_run_event(
		RunEventRes.Type.PLANT_PLACED,
		{"cell": cell, "species_id": species_id, "cost": species.plant_cost}
	)
	return true


func _get_economy() -> EconomySystemScript:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return null
	return nodes[0] as EconomySystemScript
