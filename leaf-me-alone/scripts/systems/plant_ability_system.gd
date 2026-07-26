extends Node
## Species combat abilities — Peanut N-fixation buff and allelopathy ape slow (Story 2.6).
## Events emitted: none
## Events listened: none

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

const PEANUT_ID := "peanut"
const ADJACENT_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
]


func _ready() -> void:
	add_to_group("plant_ability_system")


func is_combat_active() -> bool:
	return RunManager.get_state() == RunStateEnumRes.State.CombatPhase


func get_combat_stats(cell: Vector2i) -> Dictionary:
	var grid := RunManager.grid_data
	if grid == null or not grid.has_plant(cell):
		return {}
	var species_id := grid.get_plant_species_id(cell)
	var species := ContentRegistry.get_species(species_id)
	if species == null:
		return {}
	var attack := species.attack
	var defense := species.defense
	if is_combat_active():
		var buff := _get_n_fixation_buff(cell)
		attack = roundi(float(attack) * (1.0 + float(buff.get("attack_pct", 0.0))))
		defense = roundi(float(defense) * (1.0 + float(buff.get("defense_pct", 0.0))))
	return {
		"species_id": species_id,
		"attack": attack,
		"defense": defense,
		"hp": grid.get_plant_hp(cell),
	}


func get_ape_move_speed_multiplier(ape_cell: Vector2i) -> float:
	if not is_combat_active():
		return 1.0
	var grid := RunManager.grid_data
	if grid == null:
		return 1.0
	var slow_pct := 0.0
	for y in grid.height:
		for x in grid.width:
			var peanut_cell := Vector2i(x, y)
			if grid.get_plant_species_id(peanut_cell) != PEANUT_ID:
				continue
			var allelopathy := _get_peanut_allelopathy()
			var radius := int(allelopathy.get("radius_tiles", 1))
			if _manhattan_distance(ape_cell, peanut_cell) <= radius:
				slow_pct = maxf(slow_pct, float(allelopathy.get("ape_slow_pct", 0.0)))
	return maxf(1.0 - slow_pct, 0.1)


func has_adjacent_peanut(cell: Vector2i) -> bool:
	var grid := RunManager.grid_data
	if grid == null:
		return false
	for offset in ADJACENT_OFFSETS:
		var neighbor := cell + offset
		if grid.get_plant_species_id(neighbor) == PEANUT_ID:
			return true
	return false


func _get_n_fixation_buff(cell: Vector2i) -> Dictionary:
	var grid := RunManager.grid_data
	if grid == null:
		return {"attack_pct": 0.0, "defense_pct": 0.0}
	var attack_pct := 0.0
	var defense_pct := 0.0
	for offset in ADJACENT_OFFSETS:
		var neighbor := cell + offset
		if grid.get_plant_species_id(neighbor) != PEANUT_ID:
			continue
		var fixation := _get_peanut_n_fixation()
		attack_pct = maxf(attack_pct, float(fixation.get("attack_buff_pct", 0.0)))
		defense_pct = maxf(defense_pct, float(fixation.get("defense_buff_pct", 0.0)))
	return {"attack_pct": attack_pct, "defense_pct": defense_pct}


func _get_peanut_n_fixation() -> Dictionary:
	var peanut := ContentRegistry.get_species(PEANUT_ID)
	if peanut == null:
		return {}
	return peanut.abilities.get("n_fixation", {}) as Dictionary


func _get_peanut_allelopathy() -> Dictionary:
	var peanut := ContentRegistry.get_species(PEANUT_ID)
	if peanut == null:
		return {}
	return peanut.abilities.get("allelopathy", {}) as Dictionary


func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
