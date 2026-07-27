extends Control
## Achievements overlay — read-only locked list (Story 7.5).

const AchievementCatalogRes := preload("res://scripts/data/achievement_catalog.gd")

@export var title_text: String = "Achievements"


func _ready() -> void:
	visible = false
	%BackButton.pressed.connect(close_overlay)
	_apply_title()


func open_overlay() -> void:
	_build_list()
	_apply_title()
	visible = true


func close_overlay() -> void:
	visible = false


func _apply_title() -> void:
	var title := get_node_or_null("%TitleLabel")
	if title is Label:
		(title as Label).text = title_text


func _build_list() -> void:
	var container := get_node_or_null("%AchievementList")
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()

	for entry in AchievementCatalogRes.load_locked_entries():
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		var title := Label.new()
		title.text = "🔒 %s" % str(entry.get("title", ""))
		title.theme_type_variation = &"body"
		row.add_child(title)
		var desc := Label.new()
		desc.text = str(entry.get("description", ""))
		desc.theme_type_variation = &"label"
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(desc)
		container.add_child(row)
