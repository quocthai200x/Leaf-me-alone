extends Node
## Single input router for run — IDLE pan in Story 1.7; placement/care deferred to Epic 2.

const InteractionModeRes := preload("res://scripts/input/interaction_mode.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

@export var map_view_path: NodePath

var _mode: int = InteractionModeRes.Mode.IDLE
var _map_view: Node2D
var _dragging: bool = false
var _last_mouse: Vector2 = Vector2.ZERO


func _ready() -> void:
	if map_view_path != NodePath():
		_map_view = get_node(map_view_path) as Node2D
	set_process_unhandled_input(true)


func get_mode() -> int:
	return _mode


func set_visible_map_width(width: float) -> void:
	if _map_view != null and _map_view.has_method("set_visible_map_size"):
		_map_view.set_visible_map_size(Vector2(width, 1080.0))


func _unhandled_input(event: InputEvent) -> void:
	if _mode != InteractionModeRes.Mode.IDLE:
		return
	if _map_view == null or not _map_view.has_method("can_pan") or not _map_view.can_pan():
		return
	var state := RunManager.get_state()
	if state != RunStateEnumRes.State.PausePhase and state != RunStateEnumRes.State.CombatPhase:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				if _is_over_map(mb.position):
					_dragging = true
					_last_mouse = mb.position
					get_viewport().set_input_as_handled()
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		var delta := motion.position - _last_mouse
		_last_mouse = motion.position
		_map_view.apply_pan_delta(delta)
		get_viewport().set_input_as_handled()


func _is_over_map(screen_pos: Vector2) -> bool:
	var visible_width := 1920.0
	if RunManager.get_state() == RunStateEnumRes.State.PausePhase:
		visible_width = 1248.0
	return screen_pos.x >= 0.0 and screen_pos.x <= visible_width and screen_pos.y >= 0.0 and screen_pos.y <= 1080.0
