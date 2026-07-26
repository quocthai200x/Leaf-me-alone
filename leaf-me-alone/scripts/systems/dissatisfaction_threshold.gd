class_name DissatisfactionThreshold
extends RefCounted
## Sole owner of flee threshold math (Story 3.3). HR emits modifiers; never mutates directly.

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const SpeciesDefRes := preload("res://scripts/data/species_def.gd")


static func get_flee_threshold(
	species: SpeciesDefRes,
	cell: Vector2i,
	hr_modifiers: Array
) -> int:
	if is_hr_modifier_active(cell, hr_modifiers):
		return GameConstantsRes.HR_FLEE_THRESHOLD
	if species != null and species.dissatisfaction_sensitive:
		return GameConstantsRes.SENSITIVE_FLEE_THRESHOLD
	return GameConstantsRes.STANDARD_FLEE_THRESHOLD


static func should_flee(dissatisfaction: int, threshold: int) -> bool:
	return dissatisfaction >= threshold


static func is_hr_modifier_active(cell: Vector2i, hr_modifiers: Array) -> bool:
	for mod in hr_modifiers:
		if typeof(mod) != TYPE_DICTIONARY:
			continue
		var center: Vector2i = mod.get("center", Vector2i(-999, -999))
		var radius: int = int(mod.get("radius", 0))
		if radius <= 0:
			continue
		var delta := cell - center
		var dist := maxi(absi(delta.x), absi(delta.y))
		if dist <= radius:
			return true
	return false
