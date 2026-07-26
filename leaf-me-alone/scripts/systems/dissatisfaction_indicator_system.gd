class_name DissatisfactionIndicatorSystem
extends RefCounted
## In-world dissatisfaction indicators (Story 2.9 tease, Story 3.2 combat visibility).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")


static func get_indicator_state(dissatisfaction: int, in_combat: bool) -> Dictionary:
	if in_combat:
		return get_combat_state(dissatisfaction)
	return get_tease_state(dissatisfaction)


static func get_tease_state(dissatisfaction: int) -> Dictionary:
	var show := dissatisfaction >= GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD
	var show_meter := dissatisfaction > GameConstantsRes.DISSATISFACTION_METER_THRESHOLD
	return _build_state(dissatisfaction, show, show_meter)


static func get_combat_state(dissatisfaction: int) -> Dictionary:
	var show := dissatisfaction >= 1
	var show_meter := dissatisfaction > GameConstantsRes.DISSATISFACTION_METER_THRESHOLD
	return _build_state(dissatisfaction, show, show_meter)


static func _build_state(dissatisfaction: int, show_emoji: bool, show_meter: bool) -> Dictionary:
	return {
		"show_emoji": show_emoji,
		"show_meter": show_emoji and show_meter,
		"dissatisfaction": dissatisfaction,
		"meter_fill": clampf(float(dissatisfaction) / 100.0, 0.0, 1.0),
		"meter_color": GameConstantsRes.DISSATISFACTION_COLOR,
	}


static func should_show_tease(dissatisfaction: int) -> bool:
	return dissatisfaction >= GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD
