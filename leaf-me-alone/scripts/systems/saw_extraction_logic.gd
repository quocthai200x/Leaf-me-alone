class_name SawExtractionLogic
extends RefCounted
## Pure saw extraction tick logic (Story 4.3).

const SoilTypeRes := preload("res://scripts/data/soil_type.gd")


static func apply_extract_tick(
	plant_abilities: Node,
	target_cell: Vector2i,
	incoming_damage: int
) -> Dictionary:
	var result := {
		"plant_damaged": false,
		"tile_depleted": false,
		"reflect_damage": 0,
		"species_id": "",
	}
	var grid := RunManager.grid_data
	if grid == null or not grid.is_in_bounds(target_cell):
		return result

	if grid.has_plant(target_cell):
		result["species_id"] = grid.get_plant_species_id(target_cell)
		var hit := {"plant_damage_taken": 0, "reflect_damage": 0}
		if plant_abilities != null and plant_abilities.has_method("resolve_plant_hit"):
			hit = plant_abilities.resolve_plant_hit(target_cell, incoming_damage)
		result["reflect_damage"] = int(hit.get("reflect_damage", 0))
		var damage_taken := int(hit.get("plant_damage_taken", 0))
		if damage_taken > 0:
			result["plant_damaged"] = true
			var new_hp := grid.get_plant_hp(target_cell) - damage_taken
			grid.set_plant_hp(target_cell, new_hp)
			if new_hp <= 0:
				grid.set_depleted_after_extraction(target_cell)
				result["tile_depleted"] = true
		return result

	if grid.is_depleted(target_cell):
		return result
	if grid.get_soil_type(target_cell) == SoilTypeRes.Type.RED:
		grid.set_depleted_after_extraction(target_cell)
		result["tile_depleted"] = true
	return result
