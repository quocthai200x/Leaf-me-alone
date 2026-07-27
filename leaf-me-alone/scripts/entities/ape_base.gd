extends Node2D
## Pooled ape entity — FSM: SPAWN → PATH → ACT → DEAD (Story 4.1).

enum State { SPAWN, PATH, ACT, DEAD }

const GameConstantsRes := preload("res://scripts/utils/constants.gd")

var state: State = State.DEAD
var grid_cell: Vector2i = Vector2i.ZERO
var goal_cell: Vector2i = Vector2i.ZERO
var role_id: String = ""
var max_hp: int = 0
var current_hp: int = 0

var _role_def: ApeRoleDef
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _move_speed_multiplier: float = 1.0
var _speed_pixels_per_sec: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func configure(
	role_def: ApeRoleDef,
	spawn_cell: Vector2i,
	move_speed_multiplier: float,
	hp_multiplier: float = 1.0
) -> void:
	_role_def = role_def
	role_id = role_def.id
	grid_cell = spawn_cell
	_move_speed_multiplier = move_speed_multiplier
	max_hp = int(round(float(role_def.hp) * hp_multiplier))
	current_hp = max_hp
	_recompute_speed()
	_reset_path()


func activate(spawn_cell: Vector2i, path: PackedVector2Array, goal: Vector2i) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	state = State.SPAWN
	grid_cell = spawn_cell
	goal_cell = goal
	_set_path(path)
	_sync_position_from_cell()
	state = State.PATH


func set_path(path: PackedVector2Array, goal: Vector2i) -> void:
	goal_cell = goal
	_set_path(path)
	if state == State.SPAWN:
		state = State.PATH


func reroute_path(path: PackedVector2Array, goal: Vector2i) -> void:
	if state != State.PATH:
		return
	set_path(path, goal)


func despawn() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	state = State.DEAD
	visible = false
	role_id = ""
	max_hp = 0
	current_hp = 0
	_role_def = null
	_reset_path()


func get_role_def() -> ApeRoleDef:
	return _role_def


func take_damage(amount: int) -> void:
	if state == State.DEAD or amount <= 0:
		return
	current_hp = maxi(current_hp - amount, 0)
	if current_hp <= 0:
		_request_death()


func _request_death() -> void:
	if state == State.DEAD:
		return
	var pools := get_tree().get_nodes_in_group("ape_pool")
	if pools.is_empty():
		state = State.DEAD
		visible = false
		return
	var pool: Node = pools[0]
	if pool.has_method("kill_ape"):
		pool.kill_ape(self)


func _process(delta: float) -> void:
	if state != State.PATH:
		return
	if _path.is_empty() or _path_index >= _path.size():
		state = State.ACT
		return

	var target_cell := Vector2i(_path[_path_index])
	var target_pos := GameConstantsRes.grid_cell_to_local(target_cell)
	var offset := target_pos - position
	var distance := offset.length()
	var step := _speed_pixels_per_sec * delta
	if distance <= step or distance <= 0.001:
		position = target_pos
		grid_cell = target_cell
		_path_index += 1
		if _path_index >= _path.size():
			state = State.ACT
		return

	position += offset / distance * step


func _recompute_speed() -> void:
	assert(_role_def != null, "ApeBase.configure must set role_def before movement")
	var base_speed := float(_role_def.speed)
	var tiles_per_sec := base_speed / 100.0 * _move_speed_multiplier
	var tile_px := float(GameConstantsRes.APE_TILE_SIZE) * GameConstantsRes.APE_DISPLAY_SCALE
	_speed_pixels_per_sec = tiles_per_sec * tile_px


func _set_path(path: PackedVector2Array) -> void:
	_path = path
	_path_index = 0
	if _path.size() > 0:
		var first := Vector2i(_path[0])
		if first == grid_cell and _path.size() > 1:
			_path_index = 1


func _reset_path() -> void:
	_path = PackedVector2Array()
	_path_index = 0
	goal_cell = Vector2i.ZERO


func _sync_position_from_cell() -> void:
	position = GameConstantsRes.grid_cell_to_local(grid_cell)
