extends Node
## Warning chirp, mass-flee vignette, and resignation toast (Story 3.7).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const FleeFeedbackLogicRes := preload("res://scripts/systems/flee_feedback_logic.gd")
const DissatisfactionThresholdRes := preload(
	"res://scripts/systems/dissatisfaction_threshold.gd"
)

const WARNING_CHIRP_PATH := "res://assets/audio/warning_chirp.wav"

@onready var _chirp_player: AudioStreamPlayer = $WarningChirpPlayer

var _last_dissatisfaction: Dictionary = {}
var _resignation_toast_wave: int = -1


func _ready() -> void:
	add_to_group("flee_feedback_system")
	EventBus.run_event.connect(_on_run_event)
	if _chirp_player != null:
		_chirp_player.bus = GameConstantsRes.COMBAT_AUDIO_BUS
		if ResourceLoader.exists(WARNING_CHIRP_PATH):
			_chirp_player.stream = load(WARNING_CHIRP_PATH)


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.PLANT_PLACED:
		var place_payload: Dictionary = payload
		var cell: Vector2i = place_payload.get("cell", Vector2i(-1, -1))
		if cell.x >= 0:
			_last_dissatisfaction[cell] = 0
		return
	if event == RunEventRes.Type.PLANT_FLED:
		var fled_payload: Dictionary = payload
		var cell: Vector2i = fled_payload.get("cell", Vector2i(-1, -1))
		if cell.x >= 0:
			_last_dissatisfaction.erase(cell)
		return
	if event == RunEventRes.Type.DISSATISFACTION_UPDATED:
		_handle_dissatisfaction_updated()
		return
	if event == RunEventRes.Type.FLEE_TRIGGERED:
		_handle_flee_triggered(payload)
		return
	if event != RunEventRes.Type.STATE_CHANGED:
		return
	var state_payload: Dictionary = payload
	if int(state_payload.get("to", -1)) == RunStateEnumRes.State.CombatPhase:
		_resignation_toast_wave = -1


func _handle_dissatisfaction_updated() -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	var grid := RunManager.grid_data
	if grid == null:
		return
	var should_chirp := false
	for y in grid.height:
		for x in grid.width:
			var cell := Vector2i(x, y)
			if not grid.has_plant(cell):
				_last_dissatisfaction.erase(cell)
				continue
			var current := grid.get_plant_dissatisfaction(cell)
			var previous := int(_last_dissatisfaction.get(cell, 0))
			if FleeFeedbackLogicRes.crossed_warning_threshold(previous, current):
				should_chirp = true
			_last_dissatisfaction[cell] = current
	if should_chirp:
		_play_warning_chirp()


func _handle_flee_triggered(payload: Variant) -> void:
	var data: Dictionary = payload
	var cell: Vector2i = data.get("cell", Vector2i(-1, -1))
	if cell.x < 0:
		return
	var active_count := _get_active_flee_count()
	var is_hr_flee := _is_hr_flee(cell)
	if FleeFeedbackLogicRes.should_show_mass_flee_vignette(active_count, is_hr_flee):
		var hud := _get_combat_hud()
		if hud != null and hud.has_method("play_flee_vignette"):
			hud.play_flee_vignette()
	_maybe_show_resignation_toast(str(data.get("species_id", "")))


func _maybe_show_resignation_toast(species_id: String) -> void:
	var wave := RunManager.run_state.wave_index
	if wave <= 0 or wave == _resignation_toast_wave:
		return
	var species := ContentRegistry.get_species(species_id)
	var display_name := species.display_name if species != null else species_id.capitalize()
	_resignation_toast_wave = wave
	var hud := _get_combat_hud()
	if hud != null and hud.has_method("show_resignation_toast"):
		hud.show_resignation_toast(FleeFeedbackLogicRes.format_resignation_toast(display_name))


func _is_hr_flee(cell: Vector2i) -> bool:
	var dissat_nodes := get_tree().get_nodes_in_group("dissatisfaction_system")
	if dissat_nodes.is_empty():
		return false
	var dissat = dissat_nodes[0]
	if not dissat.has_method("get_hr_modifiers"):
		return false
	return DissatisfactionThresholdRes.is_hr_modifier_active(
		cell,
		dissat.get_hr_modifiers()
	)


func _get_active_flee_count() -> int:
	var dissat_nodes := get_tree().get_nodes_in_group("dissatisfaction_system")
	if dissat_nodes.is_empty():
		return 0
	var dissat = dissat_nodes[0]
	if "active_flee_count" in dissat:
		return int(dissat.active_flee_count)
	return 0


func _play_warning_chirp() -> void:
	if _chirp_player == null or _chirp_player.stream == null:
		return
	_chirp_player.play()


func _get_combat_hud() -> Node:
	var nodes := get_tree().get_nodes_in_group("combat_hud")
	if nodes.is_empty():
		return null
	return nodes[0]
