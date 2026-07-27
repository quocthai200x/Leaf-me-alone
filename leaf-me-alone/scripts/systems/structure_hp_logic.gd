class_name StructureHpLogic
extends RefCounted
## Structure HP display math (Story 4.7). Damage application deferred to Epic 5.

const GameConstantsRes := preload("res://scripts/utils/constants.gd")


static func hp_ratio(current_hp: int, max_hp: int) -> float:
	if max_hp <= 0:
		return 0.0
	return clampf(float(current_hp) / float(max_hp), 0.0, 1.0)


static func is_danger(current_hp: int, max_hp: int) -> bool:
	return hp_ratio(current_hp, max_hp) <= GameConstantsRes.STRUCTURE_DANGER_HP_RATIO


static func nests_display_ratio(nest_hps: Array) -> float:
	if nest_hps.is_empty():
		return 1.0
	var min_ratio := 1.0
	for entry in nest_hps:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var current := int(entry.get("current_hp", 0))
		var max_hp := int(entry.get("max_hp", 1))
		min_ratio = minf(min_ratio, hp_ratio(current, max_hp))
	return min_ratio


static func format_pause_summary(core_hp: int, core_max: int, nest_hps: Array) -> String:
	var nest_min := nests_display_ratio(nest_hps)
	var nest_pct := int(round(nest_min * 100.0))
	var core_pct := int(round(hp_ratio(core_hp, core_max) * 100.0))
	return "Structures — Core %d%% · Nests %d%%" % [core_pct, nest_pct]
