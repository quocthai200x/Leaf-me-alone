extends Node2D
## Events emitted: none
## Events listened: STATE_CHANGED, TUTORIAL_ACTION

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const CardPickStubDataRes := preload("res://scripts/systems/card_pick_stub_data.gd")
const MAIN_MENU_SCENE := "res://scenes/main/main_menu.tscn"

const PAUSE_VISIBLE_MAP_WIDTH := 1248.0
const COMBAT_VISIBLE_MAP_WIDTH := 1920.0

@onready var _status_label: Label = $UI/StatusLabel
@onready var _map_dim_overlay: ColorRect = %MapDimOverlay
@onready var _pause_panel: Control = %PausePanel
@onready var _combat_hud: Control = %CombatHUD
@onready var _map_view: Node2D = %MapView
@onready var _input_router: Node = $InputRouter
@onready var _tutorial_prompt: Control = %TutorialPrompt
@onready var _tutorial_system: Node = $TutorialSystem
@onready var _wave_spawner: Node = $WaveSpawner
@onready var _dissatisfaction_system: Node = $DissatisfactionSystem
@onready var _pathfinding_service: Node = $PathfindingService
@onready var _structure_hp_system: Node = $StructureHpSystem
@onready var _run_end_overlay: Control = %RunEndOverlay
@onready var _card_pick_overlay: Control = %CardPickOverlay

var _combat_timer: float = 0.0


func _ready() -> void:
	EventBus.run_event.connect(_on_run_event)
	_tutorial_system.setup(_tutorial_prompt)

	if not ContentRegistry.is_loaded():
		_status_label.text = "Content load FAILED"
		return

	var grid := RunManager.grid_data
	if grid == null:
		_status_label.text = "RunRoot — no active run (start from Main Menu)"
		return

	_map_view.sync_from_grid_data(grid)
	if _map_view.has_method("spawn_structures"):
		_map_view.spawn_structures(grid)
	_init_pathfinding(grid)
	_apply_phase_ui(RunManager.get_state())
	_update_status()
	_handle_pause_entry()


func _process(delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	_combat_timer -= delta
	if _combat_timer <= 0.0:
		if _get_active_flee_count() > 0:
			return
		RunManager.on_combat_timer_expired()
	_update_status()


func _get_active_flee_count() -> int:
	if _dissatisfaction_system != null and "active_flee_count" in _dissatisfaction_system:
		return int(_dissatisfaction_system.active_flee_count)
	return 0


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.TUTORIAL_ACTION:
		var data: Dictionary = payload
		if str(data.get("action", "")) == "prep_complete":
			_start_combat_if_ready()
		return

	if event == RunEventRes.Type.PLANT_PLACED:
		var place_data: Dictionary = payload
		var cell: Vector2i = place_data.get("cell", Vector2i(-1, -1))
		if RunManager.grid_data != null and _map_view.has_method("sync_from_grid_data"):
			_map_view.sync_from_grid_data(RunManager.grid_data)
		if cell.x >= 0 and _map_view.has_method("play_place_juice"):
			_map_view.play_place_juice(cell)
		if _pause_panel.has_method("refresh_dogecoin"):
			_pause_panel.refresh_dogecoin()
		return

	if event == RunEventRes.Type.PLANT_CARED:
		var care_data: Dictionary = payload
		var cell: Vector2i = care_data.get("cell", Vector2i(-1, -1))
		if RunManager.grid_data != null and _map_view.has_method("sync_from_grid_data"):
			_map_view.sync_from_grid_data(RunManager.grid_data)
		if cell.x >= 0 and _map_view.has_method("play_care_juice"):
			_map_view.play_care_juice(cell)
		if _pause_panel.has_method("refresh_dogecoin"):
			_pause_panel.refresh_dogecoin()
		if _pause_panel.has_method("refresh_care_affordability"):
			_pause_panel.refresh_care_affordability()
		return

	if event == RunEventRes.Type.DISSATISFACTION_UPDATED:
		if RunManager.grid_data != null and _map_view.has_method("sync_dissatisfaction_indicators"):
			_map_view.sync_dissatisfaction_indicators(RunManager.grid_data)
		return

	if event == RunEventRes.Type.APE_SPAWNED:
		var spawn_data: Dictionary = payload
		if int(spawn_data.get("wave", 0)) == 1 and int(spawn_data.get("index", 0)) >= 2:
			if _tutorial_system.has_method("notify_dissatisfaction_seen"):
				_tutorial_system.notify_dissatisfaction_seen()
		return

	if event != RunEventRes.Type.STATE_CHANGED:
		return

	var data: Dictionary = payload
	var to_state: int = int(data.get("to", -1))
	if to_state == RunStateEnumRes.State.CombatPhase:
		_combat_timer = RunManager.get_current_wave_duration()
		if RunManager.grid_data != null:
			_init_pathfinding(RunManager.grid_data)
		var wave_index := RunManager.run_state.wave_index
		if _wave_spawner.has_method("start_wave"):
			_wave_spawner.start_wave(wave_index)
		if wave_index == 1:
			if _tutorial_system.has_method("show_dissatisfaction_prompt"):
				_tutorial_system.show_dissatisfaction_prompt()
		if _combat_hud.has_method("show_wave_banner"):
			_combat_hud.show_wave_banner(wave_index)
		if _combat_hud.has_method("refresh_structure_hp"):
			_combat_hud.refresh_structure_hp()
	elif to_state == RunStateEnumRes.State.PausePhase:
		if _wave_spawner.has_method("stop_wave"):
			_wave_spawner.stop_wave()
		if _pause_panel.has_method("refresh_dogecoin"):
			_pause_panel.refresh_dogecoin()
		if _pause_panel.has_method("refresh_structure_summary"):
			_pause_panel.refresh_structure_summary()
		if _structure_hp_system != null:
			if _structure_hp_system.has_method("can_apply_between_wave_restoration"):
				if _structure_hp_system.can_apply_between_wave_restoration():
					if _structure_hp_system.has_method("apply_between_wave_restoration_stub"):
						_structure_hp_system.apply_between_wave_restoration_stub()
		_handle_pause_entry()
	elif to_state == RunStateEnumRes.State.CardPickPhase:
		if _wave_spawner.has_method("stop_wave"):
			_wave_spawner.stop_wave()
		_show_card_pick_overlay()
	elif to_state == RunStateEnumRes.State.RunEnd:
		if _wave_spawner.has_method("stop_wave"):
			_wave_spawner.stop_wave()
		_show_run_end_overlay()

	_apply_phase_ui(to_state)
	_update_status()


func _handle_pause_entry() -> void:
	if RunManager.get_state() != RunStateEnumRes.State.PausePhase:
		return
	var wave := RunManager.run_state.wave_index
	if wave == 0:
		if _tutorial_system.has_method("start_prep_tutorial"):
			_tutorial_system.start_prep_tutorial()
		return
	if wave > 0 and wave < GameConstantsRes.MAX_COMBAT_WAVES:
		call_deferred("_start_combat_if_ready")


func _start_combat_if_ready() -> void:
	if RunManager.get_state() != RunStateEnumRes.State.PausePhase:
		return
	if RunManager.run_state.wave_index == 0 and _tutorial_system.has_method("is_prep_complete"):
		if not _tutorial_system.is_prep_complete():
			return
	if not RunManager.begin_combat_wave():
		push_error("RunRoot: failed to begin combat wave")


func _show_card_pick_overlay() -> void:
	if _card_pick_overlay == null:
		push_error("RunRoot: CardPickOverlay missing")
		return
	var wave_index := RunManager.run_state.wave_index
	var options := CardPickStubDataRes.build_options_for_wave(
		wave_index,
		RunManager.run_state.master_seed
	)
	if _card_pick_overlay.has_method("show_pick"):
		_card_pick_overlay.show_pick(wave_index, options)


func _show_run_end_overlay() -> void:
	if _run_end_overlay == null:
		return
	var outcome := RunManager.run_state.run_outcome
	if outcome.is_empty():
		outcome = "loss"
	var waves_cleared := RunManager.run_state.wave_index
	if outcome == "loss":
		waves_cleared = maxi(RunManager.run_state.wave_index - 1, 0)
	if _run_end_overlay.has_method("show_run_end"):
		_run_end_overlay.show_run_end(
			outcome,
			RunManager.run_state.loss_reason,
			RunManager.run_state.master_seed,
			waves_cleared
		)


func _init_pathfinding(grid: GridDataRes) -> void:
	if _pathfinding_service != null and _pathfinding_service.has_method("initialize_from_grid"):
		_pathfinding_service.initialize_from_grid(grid)


func _apply_phase_ui(state: int) -> void:
	var is_pause := state == RunStateEnumRes.State.PausePhase
	var is_combat := state == RunStateEnumRes.State.CombatPhase
	var is_card_pick := state == RunStateEnumRes.State.CardPickPhase
	var is_run_end := state == RunStateEnumRes.State.RunEnd

	_map_dim_overlay.visible = is_pause and not is_run_end
	_pause_panel.visible = is_pause and not is_run_end
	_combat_hud.visible = is_combat and not is_run_end
	if _card_pick_overlay != null:
		if not is_card_pick and _card_pick_overlay.has_method("hide_overlay"):
			_card_pick_overlay.hide_overlay()
	if _run_end_overlay != null:
		if not is_run_end and _run_end_overlay.has_method("hide_overlay"):
			_run_end_overlay.hide_overlay()
	if _map_view.has_method("set_combat_phase"):
		_map_view.set_combat_phase(is_combat)
	if is_card_pick and _map_view.has_method("set_combat_phase"):
		_map_view.set_combat_phase(false)
	if RunManager.grid_data != null and _map_view.has_method("sync_dissatisfaction_indicators"):
		_map_view.sync_dissatisfaction_indicators(RunManager.grid_data)

	var map_width := PAUSE_VISIBLE_MAP_WIDTH if is_pause else COMBAT_VISIBLE_MAP_WIDTH
	if is_card_pick:
		map_width = COMBAT_VISIBLE_MAP_WIDTH
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
	var spawn_text := ""
	if _wave_spawner.has_method("get_spawned_count"):
		spawn_text = " | Apes: %d" % _wave_spawner.get_spawned_count()
	_status_label.text = "RunRoot — %s | Wave %d/%d%s%s" % [
		state_name,
		wave,
		GameConstantsRes.MAX_COMBAT_WAVES,
		timer_text,
		spawn_text,
	]
