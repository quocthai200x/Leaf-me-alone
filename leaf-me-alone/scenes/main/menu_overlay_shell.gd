extends Control
## Shared menu overlay shell — level-2 navigation (Story 7.4).

signal closed

@export var title_text: String = ""


func _ready() -> void:
	visible = false
	var back := get_node_or_null("%BackButton")
	if back != null and back is Button:
		(back as Button).pressed.connect(close_overlay)
	_apply_title()


func open_overlay() -> void:
	_apply_title()
	visible = true


func close_overlay() -> void:
	visible = false
	closed.emit()


func _apply_title() -> void:
	var title := get_node_or_null("%TitleLabel")
	if title != null and title is Label:
		(title as Label).text = title_text
