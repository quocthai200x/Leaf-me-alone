class_name DissatisfactionIndicatorSystem
extends RefCounted
## Tease-only dissatisfaction indicators (Story 2.9). No flee trigger.

const GameConstantsRes := preload("res://scripts/utils/constants.gd")


static func get_tease_state(dissatisfaction: int) -> Dictionary:
	var show := dissatisfaction >= GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD
	var show_meter := dissatisfaction > GameConstantsRes.DISSATISFACTION_METER_THRESHOLD
	return {
		"show_emoji": show,
		"show_meter": show and show_meter,
		"dissatisfaction": dissatisfaction,
		"meter_fill": clampf(float(dissatisfaction) / 100.0, 0.0, 1.0),
	}


static func should_show_tease(dissatisfaction: int) -> bool:
	return dissatisfaction >= GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD
