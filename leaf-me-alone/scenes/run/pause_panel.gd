extends Control
## Greybox pause prep panel shell — visibility controlled by RunRoot.

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")

@onready var _tutorial_actions: VBoxContainer = %TutorialActions
@onready var _dogecoin_icon: Label = %DogecoinIcon
@onready var _dogecoin_value: Label = %DogecoinValue


func _ready() -> void:
	_apply_chip_theme()
	refresh_dogecoin()
	%PlacePeanutButton.pressed.connect(_on_place_peanut_pressed)
	%WaterPlantButton.pressed.connect(_on_water_plant_pressed)
	EventBus.run_event.connect(_on_run_event)
	_update_tutorial_actions_visibility()


func refresh_dogecoin() -> void:
	var economy := _get_economy_system()
	var balance := economy.get_balance() if economy != null else RunManager.run_state.dogecoin
	_dogecoin_value.text = str(balance)


func _apply_chip_theme() -> void:
	_dogecoin_icon.theme_type_variation = &"numeric"
	_dogecoin_value.theme_type_variation = &"numeric"


func _get_economy_system() -> EconomySystemScript:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return null
	return nodes[0] as EconomySystemScript


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
	if event == RunEventRes.Type.DOGECOIN_CHANGED:
		refresh_dogecoin()
	elif event == RunEventRes.Type.TUTORIAL_ACTION:
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
