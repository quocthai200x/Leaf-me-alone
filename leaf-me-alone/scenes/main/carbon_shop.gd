extends Control
## Carbon Shop stub — clan unlock purchases (Story 7.3).

const CC_COLOR := Color(0.419608, 0.796078, 0.666667, 1.0)

@onready var _balance_label: Label = %BalanceLabel
@onready var _rows_container: VBoxContainer = %ClanRows
@onready var _back_button: Button = %BackButton

var _row_nodes: Dictionary = {}


func _ready() -> void:
	visible = false
	_back_button.pressed.connect(_on_back_pressed)
	SaveManager.meta_changed.connect(_refresh_ui)


func open_shop() -> void:
	_refresh_ui()
	visible = true


func close_shop() -> void:
	visible = false


func open_overlay() -> void:
	open_shop()


func _refresh_ui() -> void:
	if _balance_label != null:
		_balance_label.text = "CC %d" % SaveManager.get_carbon_credit()
		_balance_label.add_theme_color_override("font_color", CC_COLOR)
	_build_rows()


func _build_rows() -> void:
	if _rows_container == null:
		return
	for child in _rows_container.get_children():
		child.queue_free()
	_row_nodes.clear()

	for clan_id in ContentRegistry.get_all_clan_ids():
		var clan := ContentRegistry.get_clan(clan_id)
		if clan == null:
			continue
		var row := _create_clan_row(clan)
		_rows_container.add_child(row)
		_row_nodes[clan.id] = row


func _create_clan_row(clan) -> PanelContainer:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = clan.display_name
	vbox.add_child(title)

	if not clan.description.is_empty():
		var desc := Label.new()
		desc.text = clan.description
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_color_override("font_color", Color(0.658824, 0.709804, 0.627451, 1.0))
		vbox.add_child(desc)

	var owned := SaveManager.is_clan_unlocked(clan.id)
	var action := Button.new()
	if owned:
		action.text = "Owned"
		action.disabled = true
	else:
		action.text = "Unlock — %d CC" % clan.unlock_cost
		var affordable := SaveManager.get_carbon_credit() >= clan.unlock_cost
		action.disabled = not affordable
		if not affordable:
			panel.modulate = Color(0.55, 0.55, 0.55, 1.0)
			var shortfall := SaveManager.get_clan_shortfall(clan.unlock_cost)
			action.tooltip_text = "Need %d more CC" % shortfall
		action.pressed.connect(_on_unlock_pressed.bind(clan.id, clan.unlock_cost, panel))
	vbox.add_child(action)
	return panel


func _on_unlock_pressed(clan_id: String, cost: int, row: PanelContainer) -> void:
	if not SaveManager.try_purchase_clan(clan_id, cost):
		return
	_play_unlock_animation(row)
	_refresh_ui()


func _play_unlock_animation(row: PanelContainer) -> void:
	if row == null:
		return
	row.scale = Vector2(0.92, 0.92)
	var tween := create_tween()
	tween.tween_property(row, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK)


func _on_back_pressed() -> void:
	close_shop()
