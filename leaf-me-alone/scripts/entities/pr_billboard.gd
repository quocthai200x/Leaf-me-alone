class_name PrBillboard
extends Node2D
## Diegetic PR billboard prop (Story 4.5).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")

var grid_cell: Vector2i = Vector2i.ZERO


func configure(cell: Vector2i) -> void:
	grid_cell = cell
	position = GameConstantsRes.grid_cell_to_local(cell)
	_build_visual()


func _build_visual() -> void:
	for child in get_children():
		child.queue_free()

	var board := ColorRect.new()
	board.color = GameConstantsRes.DISSATISFACTION_COLOR
	board.size = Vector2(14, 18)
	board.position = Vector2(-7, -16)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(board)

	var label := Label.new()
	label.text = "PR"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 8)
	label.position = Vector2(-8, -15)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

	var glow := ColorRect.new()
	glow.color = Color(
		GameConstantsRes.DISSATISFACTION_COLOR.r,
		GameConstantsRes.DISSATISFACTION_COLOR.g,
		GameConstantsRes.DISSATISFACTION_COLOR.b,
		0.25
	)
	glow.size = Vector2(56, 56)
	glow.position = Vector2(-28, -40)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	move_child(glow, 0)
