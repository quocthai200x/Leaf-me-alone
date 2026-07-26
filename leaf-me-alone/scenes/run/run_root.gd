extends Node2D
## Events emitted: none
## Events listened: STATE_CHANGED

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const MAIN_MENU_SCENE := "res://scenes/main/main_menu.tscn"

const PAUSE_VISIBLE_MAP_WIDTH := 1248.0
const COMBAT_VISIBLE_MAP_WIDTH := 1920.0

@onready var _status_label: Label = $UI/StatusLabel
@onready var _map_dim_overlay: ColorRect = %MapDimOverlay
@onready var _pause_panel: Control = %PausePanel
@onready var _combat_hud: Control = %CombatHUD
@onready var _map_view: Node2D = %MapView
@onready var _input_router: Node = $InputRouter

var _combat_timer: float = 0.0


func _ready() -> void:
	EventBus.run_event.connect(_on_run_event)

	if not ContentRegistry.is_loaded():
		_status_label.text = "Content load FAILED"
		return

	var grid := RunManager.grid_data
	if grid == null:
		_status_label.text = "RunRoot — no active run (start from Main Menu)"
		return

	_map_view.sync_from_grid_data(grid)
	_apply_phase_ui(RunManager.get_state())
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
	elif to_state == RunStateEnumRes.State.PausePhase:
		if _pause_panel.has_method("refresh_dogecoin"):
			_pause_panel.refresh_dogecoin()
	elif to_state == RunStateEnumRes.State.CardPickPhase:
		call_deferred("_complete_card_pick_stub")
	_apply_phase_ui(to_state)
	_update_status()


func _complete_card_pick_stub() -> void:
	RunManager.complete_card_pick()


func _apply_phase_ui(state: int) -> void:
	var is_pause := state == RunStateEnumRes.State.PausePhase
	var is_combat := state == RunStateEnumRes.State.CombatPhase

	_map_dim_overlay.visible = is_pause
	_pause_panel.visible = is_pause
	_combat_hud.visible = is_combat

	var map_width := PAUSE_VISIBLE_MAP_WIDTH if is_pause else COMBAT_VISIBLE_MAP_WIDTH
	if _map_view.has_method("set_visible_map_size"):
		_map_view.set_visible_map_size(Vector2(map_width, 1080.0))
	if _input_router.has_method("set_visible_map_width"):
		_input_router.set_visible_map_width(map_width)


func _update_status() -> void:
	var state_name: String = RunStateEnumRes.State.keys()[RunManager.get_state()]
	var wave := RunManager.run_state.wave_index
	var timer_text := ""
	if RunManager.get_state() == RunStateEnumRes.State.CombatPhase:
		timer_text = " | Timer: %.1fs" % maxf(_combat_timer, 0.0)
		if _combat_hud.has_method("update_wave_timer"):
			_combat_hud.update_wave_timer(
				wave,
				_combat_timer,
				GameConstantsRes.MAX_COMBAT_WAVES
			)
	_status_label.text = "RunRoot — %s | Wave %d/%d%s" % [
		state_name,
		wave,
		GameConstantsRes.MAX_COMBAT_WAVES,
		timer_text,
	]
