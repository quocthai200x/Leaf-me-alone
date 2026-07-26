extends Node2D
## Events emitted: none
## Events listened: STATE_CHANGED

const GridRendererScene := preload("res://scenes/run/grid_renderer.tscn")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const MAIN_MENU_SCENE := "res://scenes/main/main_menu.tscn"

@onready var _status_label: Label = $UI/StatusLabel

var _grid_renderer: Node2D
var _combat_timer: float = 0.0


func _ready() -> void:
	EventBus.run_event.connect(_on_run_event)
	_grid_renderer = GridRendererScene.instantiate()
	_grid_renderer.position = Vector2(320, 120)
	add_child(_grid_renderer)

	if not ContentRegistry.is_loaded():
		_status_label.text = "Content load FAILED"
		return

	var grid := RunManager.grid_data
	if grid == null:
		_status_label.text = "RunRoot — no active run (start from Main Menu)"
		return

	_grid_renderer.sync_from_grid_data(grid)
	_update_status()

	if RunManager.get_state() == RunStateEnumRes.State.PausePhase:
		if not RunManager.begin_combat_wave():
			push_error("RunRoot: failed to begin wave 1")
			RunManager.enter_main_menu()
			get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _process(delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	_combat_timer -= delta
	if _combat_timer <= 0.0:
		RunManager.on_combat_timer_expired()
	_update_status()


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.STATE_CHANGED:
		return
	var data: Dictionary = payload
	var to_state: int = int(data.get("to", -1))
	if to_state == RunStateEnumRes.State.CombatPhase:
		_combat_timer = RunManager.get_current_wave_duration()
	elif to_state == RunStateEnumRes.State.CardPickPhase:
		# Card pick UI deferred to Epic 6 — auto-complete stub for loop testing
		call_deferred("_complete_card_pick_stub")
	_update_status()


func _complete_card_pick_stub() -> void:
	RunManager.complete_card_pick()


func _update_status() -> void:
	var state_name: String = RunStateEnumRes.State.keys()[RunManager.get_state()]
	var wave := RunManager.run_state.wave_index
	var timer_text := ""
	if RunManager.get_state() == RunStateEnumRes.State.CombatPhase:
		timer_text = " | Timer: %.1fs" % maxf(_combat_timer, 0.0)
	_status_label.text = "RunRoot — %s | Wave %d/%d%s" % [
		state_name,
		wave,
		GameConstantsRes.MAX_COMBAT_WAVES,
		timer_text,
	]
