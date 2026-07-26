extends Control
## Greybox pause prep panel shell — visibility controlled by RunRoot.

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

@onready var _tutorial_actions: VBoxContainer = %TutorialActions


func _ready() -> void:
	refresh_dogecoin()
	%PlacePeanutButton.pressed.connect(_on_place_peanut_pressed)
	%WaterPlantButton.pressed.connect(_on_water_plant_pressed)
	EventBus.run_event.connect(_on_run_event)
	_update_tutorial_actions_visibility()


func refresh_dogecoin() -> void:
	%DogecoinValue.text = str(RunManager.run_state.dogecoin)


func _on_place_peanut_pressed() -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.TUTORIAL_ACTION,
		{"action": "place_peanut"}
	)


func _on_water_plant_pressed() -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.TUTORIAL_ACTION,
		{"action": "water_plant"}
	)


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.TUTORIAL_ACTION:
		var data: Dictionary = payload
		if str(data.get("action", "")) == "prep_complete":
			_update_tutorial_actions_visibility()
	elif event == RunEventRes.Type.STATE_CHANGED:
		_update_tutorial_actions_visibility()


func _update_tutorial_actions_visibility() -> void:
	var show_tutorial := (
		RunManager.run_state.wave_index == 0
		and RunManager.get_state() == RunStateEnumRes.State.PausePhase
	)
	_tutorial_actions.visible = show_tutorial
