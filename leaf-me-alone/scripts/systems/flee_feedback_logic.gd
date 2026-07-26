class_name FleeFeedbackLogic
extends RefCounted
## Mass flee feedback rules (Story 3.7).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")


static func crossed_warning_threshold(previous: int, current: int) -> bool:
	if previous >= GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD:
		return false
	return current >= GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD


static func should_show_mass_flee_vignette(active_flee_count: int, is_hr_flee: bool) -> bool:
	if is_hr_flee:
		return true
	return active_flee_count >= GameConstantsRes.MASS_FLEE_MIN_COUNT


static func format_resignation_toast(species_display_name: String) -> String:
	return "%s has resigned effective immediately" % species_display_name
