extends Node
## Pre-warmed ape pool — acquire on APE_SPAWNED, release on despawn (Story 4.1).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const ObjectPoolRes := preload("res://scripts/utils/object_pool.gd")
const ApeBaseScene := preload("res://scenes/entities/ape_base.tscn")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")

var _pool: ObjectPoolRes
var _entities_root: Node2D
var _pathfinding: Node
var _spawn_count: int = 0
var _pool_ready: bool = false
var _pending_spawns: Array[Dictionary] = []


func _ready() -> void:
	add_to_group("ape_pool")
	EventBus.run_event.connect(_on_run_event)
	call_deferred("_bootstrap")


func _bootstrap() -> void:
	_entities_root = _find_entities_root()
	_pathfinding = _find_pathfinding_service()
	_pool = ObjectPoolRes.new(Callable(self, "_create_ape"), GameConstantsRes.APE_POOL_SIZE, Callable(self, "_reset_ape"))
	_pool_ready = true
	for payload in _pending_spawns:
		_handle_ape_spawned(payload)
	_pending_spawns.clear()


func get_active_count() -> int:
	if _pool == null:
		return 0
	return _pool.get_active_count()


func get_active_items() -> Array:
	if _pool == null:
		return []
	return _pool.get_active_items()


func get_spawn_count() -> int:
	return _spawn_count


func reroute_pathing_apes() -> void:
	if _pathfinding == null or not _pathfinding.has_method("select_goal_and_path"):
		return
	for ape in _get_active_apes():
		if ape.state != ApeBaseScript.State.PATH:
			continue
		var result: Dictionary = _pathfinding.select_goal_and_path(ape.grid_cell)
		ape.reroute_path(result.get("path", PackedVector2Array()), result.get("goal", Vector2i.ZERO))


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.APE_SPAWNED:
		_handle_ape_spawned(payload)
	elif event == RunEventRes.Type.PLANT_FLED:
		reroute_pathing_apes()
	elif event == RunEventRes.Type.STATE_CHANGED:
		var data: Dictionary = payload
		var to_state: int = int(data.get("to", -1))
		if to_state == RunStateEnum.State.MainMenu or to_state == RunStateEnum.State.RunEnd:
			_despawn_all()


func _handle_ape_spawned(payload: Variant) -> void:
	var data: Dictionary = payload
	if not _pool_ready:
		_pending_spawns.append(data)
		return

	var ape_id := str(data.get("ape_id", ""))
	if ape_id.is_empty() or not ContentRegistry.has_ape(ape_id):
		push_error("[ApePool] Unknown ape id: %s" % ape_id)
		return
	if _pool == null:
		push_error("[ApePool] Pool not initialized")
		return

	var ape: Node2D = _pool.acquire()
	if ape == null:
		push_error("[ApePool] Pool exhausted — cannot spawn %s" % ape_id)
		return

	_spawn_count += 1
	var role_def := ContentRegistry.get_ape(ape_id)
	var spawn_cell: Vector2i = data.get("spawn_cell", Vector2i.ZERO)
	var move_mult := float(data.get("move_speed_multiplier", 1.0))
	var hp_mult := float(data.get("hp_multiplier", 1.0))
	ape.configure(role_def, spawn_cell, move_mult, hp_mult)

	var goal := Vector2i.ZERO
	var route := PackedVector2Array()
	if _pathfinding != null and _pathfinding.has_method("select_goal_and_path"):
		var result: Dictionary = _pathfinding.select_goal_and_path(spawn_cell)
		goal = result.get("goal", Vector2i.ZERO)
		route = result.get("path", PackedVector2Array())
	ape.activate(spawn_cell, route, goal)


func release_ape(ape: Node2D) -> void:
	if _pool == null or ape == null:
		return
	if ape.has_method("despawn"):
		ape.despawn()
	_pool.release(ape)


func _create_ape() -> Node2D:
	var ape: Node2D = ApeBaseScene.instantiate()
	if _entities_root != null:
		_entities_root.add_child(ape)
	else:
		add_child(ape)
	ape.visible = false
	return ape


func _reset_ape(ape: Node2D) -> void:
	if ape.has_method("despawn"):
		ape.despawn()


func _despawn_all() -> void:
	if _pool == null:
		return
	for ape in _get_active_apes():
		release_ape(ape)
	_spawn_count = 0


func _get_active_apes() -> Array:
	if _pool == null:
		return []
	return _pool.get_active_items()


func _find_entities_root() -> Node2D:
	var map_nodes := get_tree().get_nodes_in_group("map_view")
	if not map_nodes.is_empty():
		var map_view: Node = map_nodes[0]
		var entities := map_view.get_node_or_null("Entities")
		if entities is Node2D:
			return entities
	return null


func _find_pathfinding_service() -> Node:
	var nodes := get_tree().get_nodes_in_group("pathfinding_service")
	if nodes.is_empty():
		return null
	return nodes[0]
