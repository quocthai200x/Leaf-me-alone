class_name PrBillboardLogic
extends RefCounted
## PR billboard AoE dissatisfaction rules (Story 4.5).


static func is_in_aoe(cell: Vector2i, billboards: Array) -> bool:
	for board in billboards:
		if typeof(board) != TYPE_DICTIONARY:
			continue
		var center: Vector2i = board.get("center", Vector2i(-999, -999))
		var radius: int = int(board.get("radius", 0))
		if radius <= 0:
			continue
		var delta := cell - center
		var dist := maxi(absi(delta.x), absi(delta.y))
		if dist <= radius:
			return true
	return false
