extends Node
## Guided wave-1 tutorial prompts (FR76) — non-blocking, dismiss on action (UX-DR17).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

enum Step {
	NONE,
	PLACE_PEANUT,
	WATER_PLANT,
	DISSATISFACTION_WARNING,
	DONE,
}

const PEANUT_COST := 20
const PREP_STIPEND := 50
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")

var _step: int = Step.NONE
var _prompt_ui: Control
var _prep_complete: bool = false
var _dissatisfaction_complete: bool = false


func setup(prompt_ui: Control) -> void:
	_prompt_ui = prompt_ui
	EventBus.run_event.connect(_on_run_event)


func is_prep_complete() -> bool:
	return _prep_complete


func notify_place_peanut() -> void:
	if _step != Step.PLACE_PEANUT:
		return
	_advance_from(Step.PLACE_PEANUT)


func notify_water_plant() -> void:
	if _step != Step.WATER_PLANT:
		return
	_advance_from(Step.WATER_PLANT)


func notify_dissatisfaction_seen() -> void:
	if _step != Step.DISSATISFACTION_WARNING:
		return
	_advance_from(Step.DISSATISFACTION_WARNING)


func start_prep_tutorial() -> void:
	if _prep_complete:
		return
	_grant_prep_stipend()
	_step = Step.PLACE_PEANUT
	_show_prompt(
		"Place a Peanut here — cheap and cheerful. (Ð%d)" % PEANUT_COST
	)


func _grant_prep_stipend() -> void:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return
	var economy := nodes[0] as EconomySystemScript
	if economy != null and economy.get_balance() < PREP_STIPEND:
		economy.try_earn(PREP_STIPEND - economy.get_balance())


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.TUTORIAL_ACTION:
		var action_data: Dictionary = payload
		match str(action_data.get("action", "")):
			"place_peanut":
				notify_place_peanut()
			"water_plant":
				notify_water_plant()
			"dissatisfaction_seen":
				notify_dissatisfaction_seen()


func show_dissatisfaction_prompt() -> void:
	if _dissatisfaction_complete:
		return
	_step = Step.DISSATISFACTION_WARNING
	_show_prompt(
		"Watch for 😤 — unhappy plants need water before apes arrive. No flee in wave 1."
	)


func _advance_from(completed_step: int) -> void:
	_hide_prompt()
	match completed_step:
		Step.PLACE_PEANUT:
			_step = Step.WATER_PLANT
			_show_prompt("Water your moody employees before the apes arrive.")
		Step.WATER_PLANT:
			_step = Step.DONE
			_prep_complete = true
			_hide_prompt()
			EventBus.emit_run_event(
				RunEventRes.Type.TUTORIAL_ACTION,
				{"action": "prep_complete"}
			)
		Step.DISSATISFACTION_WARNING:
			_dissatisfaction_complete = true
			_step = Step.DONE
			_hide_prompt()


func _show_prompt(text: String) -> void:
	if _prompt_ui != null and _prompt_ui.has_method("show_prompt"):
		_prompt_ui.show_prompt(text)


func _hide_prompt() -> void:
	if _prompt_ui != null and _prompt_ui.has_method("hide_prompt"):
		_prompt_ui.hide_prompt()
