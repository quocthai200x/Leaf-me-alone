extends Node
## Pathfinding stub (Story 3.5) — incremental cell updates after flee; full A* in Epic 4.

const RunEventRes := preload("res://scripts/data/run_event.gd")

var _blocked_cells: Dictionary = {}


func _ready() -> void:
	add_to_group("pathfinding_service")
	EventBus.run_event.connect(_on_run_event)


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.PLANT_FLED:
		return
	var data: Dictionary = payload
	var cell: Vector2i = data.get("cell", Vector2i(-1, -1))
	if cell.x >= 0:
		update_cell(cell)


func update_cell(cell: Vector2i) -> void:
	_blocked_cells[cell] = true


func is_cell_blocked(cell: Vector2i) -> bool:
	return _blocked_cells.has(cell)


func clear_blocked_cells() -> void:
	_blocked_cells.clear()
