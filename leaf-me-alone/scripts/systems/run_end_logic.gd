class_name RunEndLogic
extends RefCounted
## Run End display copy and CC preview (Stories 5.3, 5.5).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")


static func get_outcome_title(outcome: String) -> String:
	if outcome == "win":
		return "Victory"
	return "Defeat"


static func get_outcome_copy(outcome: String, loss_reason: String) -> String:
	if outcome == "win":
		return "The jungle survives another quarterly review."
	match loss_reason:
		"all_nests_destroyed":
			return "All Root Nests lost. The forest falls silent."
		"director_survived":
			return "Director escaped. HR schedules a follow-up."
		_:
			return "Forest Core terminated. HR sends condolences."


static func compute_cc_preview(outcome: String, waves_cleared: int) -> int:
	if outcome == "win":
		return GameConstantsRes.RUN_END_CC_WIN_PREVIEW
	var partial := GameConstantsRes.RUN_END_CC_LOSS_BASE + waves_cleared * GameConstantsRes.RUN_END_CC_LOSS_PER_WAVE
	return mini(partial, GameConstantsRes.RUN_END_CC_LOSS_CAP)


static func format_seed_display(master_seed: int) -> String:
	return str(master_seed)
