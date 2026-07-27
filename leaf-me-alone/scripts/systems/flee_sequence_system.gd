extends Node
## Async flee sequence handler (Story 3.4): 😤→🏃 animation, whoosh SFX, PLANT_FLED.

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const FleeEventDataRes := preload("res://scripts/data/flee_event_data.gd")
const FleeFeedbackLogicRes := preload("res://scripts/systems/flee_feedback_logic.gd")
const DissatisfactionThresholdRes := preload(
	"res://scripts/systems/dissatisfaction_threshold.gd"
)

const WHOOSH_PATH := "res://assets/audio/flee_whoosh.wav"
const HR_STING_PATH := "res://assets/audio/hr_sting.wav"

@onready var _whoosh_player: AudioStreamPlayer = $WhooshPlayer
@onready var _hr_sting_player: AudioStreamPlayer = $HrStingPlayer

var _last_hr_sting_time_sec: float = -1.0


func _ready() -> void:
	add_to_group("flee_sequence_system")
	EventBus.run_event.connect(_on_run_event)
	if _whoosh_player != null:
		_whoosh_player.bus = GameConstantsRes.FLEE_WHOOSH_BUS
		if ResourceLoader.exists(WHOOSH_PATH):
			_whoosh_player.stream = load(WHOOSH_PATH)
	if _hr_sting_player != null:
		_hr_sting_player.bus = GameConstantsRes.COMBAT_AUDIO_BUS
		if ResourceLoader.exists(HR_STING_PATH):
			_hr_sting_player.stream = load(HR_STING_PATH)


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.FLEE_TRIGGERED:
		return
	var data: Dictionary = payload
	var cell: Vector2i = data.get("cell", Vector2i(-1, -1))
	if cell.x < 0:
		return
	_run_flee_sequence(cell, data)


func _run_flee_sequence(cell: Vector2i, trigger_data: Dictionary) -> void:
	var grid := RunManager.grid_data
	if grid == null or not grid.has_plant(cell):
		_notify_dissatisfaction_completed(cell)
		return
	var species_id := str(trigger_data.get("species_id", grid.get_plant_species_id(cell)))
	var dissat := int(trigger_data.get("dissatisfaction", grid.get_plant_dissatisfaction(cell)))
	var is_hr_flee := _is_hr_flee(cell)
	if is_hr_flee:
		_schedule_hr_sting_at_run_phase()
	await _play_flee_animation(cell)
	_play_whoosh_sfx()
	if grid.has_plant(cell):
		grid.set_depleted_after_flee(cell)
	var flee_payload := FleeEventDataRes.from_flee(
		cell, species_id, dissat, RunManager.run_state.wave_index
	)
	EventBus.emit_run_event(RunEventRes.Type.PLANT_FLED, flee_payload)
	_sync_map_after_flee()
	_notify_dissatisfaction_completed(cell)


func _play_flee_animation(cell: Vector2i) -> void:
	var map_view := _get_map_view()
	if map_view != null and map_view.has_method("play_flee_animation"):
		await map_view.play_flee_animation(cell)
		return
	await get_tree().create_timer(
		GameConstantsRes.get_flee_angry_phase_sec() + GameConstantsRes.get_flee_run_phase_sec()
	).timeout


func _play_whoosh_sfx() -> void:
	if _whoosh_player == null or _whoosh_player.stream == null:
		return
	_whoosh_player.play()


func _schedule_hr_sting_at_run_phase() -> void:
	_play_hr_sting_at_run_phase()


func _play_hr_sting_at_run_phase() -> void:
	await get_tree().create_timer(GameConstantsRes.get_flee_angry_phase_sec()).timeout
	_maybe_play_hr_sting()


func _maybe_play_hr_sting() -> void:
	var now_sec := Time.get_ticks_msec() / 1000.0
	if not FleeFeedbackLogicRes.should_play_hr_sting(_last_hr_sting_time_sec, now_sec):
		return
	_last_hr_sting_time_sec = now_sec
	if _hr_sting_player == null or _hr_sting_player.stream == null:
		return
	_hr_sting_player.play()


func _is_hr_flee(cell: Vector2i) -> bool:
	var nodes := get_tree().get_nodes_in_group("dissatisfaction_system")
	if nodes.is_empty():
		return false
	var dissat = nodes[0]
	if not dissat.has_method("get_hr_modifiers"):
		return false
	return DissatisfactionThresholdRes.is_hr_modifier_active(
		cell,
		dissat.get_hr_modifiers()
	)


func _sync_map_after_flee() -> void:
	var map_view := _get_map_view()
	var grid := RunManager.grid_data
	if map_view != null and grid != null and map_view.has_method("sync_from_grid_data"):
		map_view.sync_from_grid_data(grid)


func _notify_dissatisfaction_completed(cell: Vector2i) -> void:
	var nodes := get_tree().get_nodes_in_group("dissatisfaction_system")
	if nodes.is_empty():
		return
	var dissat = nodes[0]
	if dissat.has_method("notify_flee_completed"):
		dissat.notify_flee_completed(cell)


func _get_map_view() -> Node:
	var nodes := get_tree().get_nodes_in_group("map_view")
	if nodes.is_empty():
		return null
	return nodes[0]
