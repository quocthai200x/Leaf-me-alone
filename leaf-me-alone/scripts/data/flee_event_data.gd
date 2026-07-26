class_name FleeEventData
extends RefCounted

var cell: Vector2i = Vector2i.ZERO
var species_id: String = ""
var dissatisfaction: int = 0
var wave_index: int = 0


static func from_flee(cell: Vector2i, species_id: String, dissatisfaction: int, wave_index: int) -> Dictionary:
	return {
		"cell": cell,
		"species_id": species_id,
		"dissatisfaction": dissatisfaction,
		"wave_index": wave_index,
	}
