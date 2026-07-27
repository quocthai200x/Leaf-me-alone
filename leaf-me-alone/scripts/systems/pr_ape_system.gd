extends Node
## PR Ape billboard deployment and dissatisfaction sync (Story 4.5).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")
const PrBillboardRes := preload("res://scripts/entities/pr_billboard.gd")

var _billboards: Array[Dictionary] = []
var _deployed_ape_ids: Dictionary = {}
var _visual_nodes: Dictionary = {}


func _ready() -> void:
	add_to_group("pr_ape_system")
	EventBus.run_event.connect(_on_run_event)


func _process(_delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	_try_deploy_billboards()
	_sync_dissatisfaction_billboards()


func get_billboards() -> Array:
	return _billboards.duplicate(true)


func _try_deploy_billboards() -> void:
	var pool := _get_ape_pool()
	if pool == null:
		return
	for ape in pool.get_active_items():
		if ape.role_id != "pr_ape" or ape.state != ApeBaseScript.State.ACT:
			continue
		var ape_key := ape.get_instance_id()
		if _deployed_ape_ids.has(ape_key):
			continue
		var cell: Vector2i = ape.goal_cell
		if cell == Vector2i.ZERO:
			cell = ape.grid_cell
		_deployed_ape_ids[ape_key] = cell
		_billboards.append({"center": cell, "radius": -1})
		_spawn_billboard_visual(cell)


func _sync_dissatisfaction_billboards() -> void:
	var dissat := _get_dissatisfaction_system()
	if dissat == null:
		return
	dissat.clear_billboards()
	for board in _billboards:
		dissat.register_billboard(board.get("center", Vector2i.ZERO))


func _spawn_billboard_visual(cell: Vector2i) -> void:
	var key := "%d,%d" % [cell.x, cell.y]
	if _visual_nodes.has(key):
		return
	var entities := _get_entities_root()
	if entities == null:
		return
	var board: Node2D = PrBillboardRes.new()
	board.configure(cell)
	entities.add_child(board)
	_visual_nodes[key] = board


func _clear_all() -> void:
	_billboards.clear()
	_deployed_ape_ids.clear()
	for node in _visual_nodes.values():
		if is_instance_valid(node):
			node.queue_free()
	_visual_nodes.clear()
	var dissat := _get_dissatisfaction_system()
	if dissat != null:
		dissat.clear_billboards()


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.STATE_CHANGED:
		return
	var to_state: int = int(payload.get("to", -1))
	if to_state in [
		RunStateEnumRes.State.PausePhase,
		RunStateEnumRes.State.MainMenu,
		RunStateEnumRes.State.RunEnd,
	]:
		_clear_all()


func _get_dissatisfaction_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("dissatisfaction_system")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_ape_pool() -> Node:
	var nodes := get_tree().get_nodes_in_group("ape_pool")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_entities_root() -> Node2D:
	var map_nodes := get_tree().get_nodes_in_group("map_view")
	if map_nodes.is_empty():
		return null
	var map_view: Node = map_nodes[0]
	var entities := map_view.get_node_or_null("Entities")
	if entities is Node2D:
		return entities
	return null
