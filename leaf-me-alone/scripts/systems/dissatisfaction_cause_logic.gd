class_name DissatisfactionCauseLogic
extends RefCounted
## Pure dissatisfaction cause evaluation (Story 3.1). No flee threshold math.

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SpeciesDefRes := preload("res://scripts/data/species_def.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")

const PEANUT_ID := "peanut"

static var _neighbor_offsets: Array[Vector2i] = [
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(0, 1),
]


static func has_soil_mismatch(grid: GridDataRes, pos: Vector2i, species: SpeciesDefRes) -> bool:
	if grid == null or species == null or not grid.has_plant(pos):
		return false
	return grid.get_soil_type(pos) != species.preferred_soil


static func has_allelopathic_neighbor(grid: GridDataRes, pos: Vector2i) -> bool:
	if grid == null or not grid.has_plant(pos):
		return false
	var species_id := grid.get_plant_species_id(pos)
	if species_id == PEANUT_ID:
		return false
	for offset in _neighbor_offsets:
		var neighbor := pos + offset
		if not grid.is_in_bounds(neighbor):
			continue
		if grid.get_plant_species_id(neighbor) == PEANUT_ID:
			return true
	return false


static func has_weather_mismatch(species: SpeciesDefRes, weather_id: String) -> bool:
	if species == null:
		return false
	return species.weather_preference != weather_id


static func compute_environmental_delta(
	grid: GridDataRes,
	pos: Vector2i,
	species: SpeciesDefRes,
	weather_id: String
) -> int:
	var delta := 0
	if has_soil_mismatch(grid, pos, species):
		delta += GameConstantsRes.DISSATISFACTION_SOIL_MISMATCH_DELTA
	if has_allelopathic_neighbor(grid, pos):
		delta += GameConstantsRes.DISSATISFACTION_ALLELOPATHY_DELTA
	if has_weather_mismatch(species, weather_id):
		delta += GameConstantsRes.DISSATISFACTION_WEATHER_MISMATCH_DELTA
	return delta


static func compute_missed_care_delta(watered: bool, fertilized: bool) -> int:
	var delta := 0
	if not watered:
		delta += GameConstantsRes.DISSATISFACTION_MISSED_CARE_PER_CAUSE
	if not fertilized:
		delta += GameConstantsRes.DISSATISFACTION_MISSED_CARE_PER_CAUSE
	return delta
