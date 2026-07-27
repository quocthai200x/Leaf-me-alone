extends Control
## Card Pick overlay — full-screen scrim, three clickable panel-cards (Story 6.1+).
## Events emitted: CARD_PICKED (via CardEffectApplier → EventBus)
## Events listened: none

const CardPickStubDataRes := preload("res://scripts/systems/card_pick_stub_data.gd")
const CardEffectApplierRes := preload("res://scripts/systems/card_effect_applier.gd")

const CARD_MAX_WIDTH := 320.0
const CARD_MIN_WIDTH := 240.0
const FLIP_DURATION_SEC := 0.15

@onready var _heading: Label = %HeadingLabel
@onready var _subtitle: Label = %SubtitleLabel
@onready var _cards_row: HBoxContainer = %CardsRow

var _wave_index: int = 0
var _committed: bool = false
var _card_buttons: Array[PanelContainer] = []


func _ready() -> void:
	add_to_group("card_pick_overlay")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP


func show_pick(wave_index: int, options: Array) -> void:
	_wave_index = wave_index
	_committed = false
	if _heading != null:
		_heading.text = "Choose Your Upgrade"
	if _subtitle != null:
		_subtitle.text = "After Wave %d — pick 1 of 3 cards" % wave_index
	_rebuild_cards(options)
	visible = true


func hide_overlay() -> void:
	visible = false
	_clear_cards()


func _rebuild_cards(options: Array) -> void:
	_clear_cards()
	if _cards_row == null:
		return
	for option in options:
		var card := _build_card_panel(option as Dictionary)
		_cards_row.add_child(card)


func _build_card_panel(option: Dictionary) -> Control:
	var wrapper := MarginContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wrapper.custom_minimum_size = Vector2(CARD_MIN_WIDTH, 0.0)

	var card_root := PanelContainer.new()
	card_root.custom_minimum_size = Vector2(CARD_MIN_WIDTH, 280.0)
	card_root.custom_maximum_size = Vector2(CARD_MAX_WIDTH, 400.0)
	card_root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card_root.mouse_filter = Control.MOUSE_FILTER_STOP
	card_root.focus_mode = Control.FOCUS_NONE
	card_root.pivot_offset = Vector2(CARD_MIN_WIDTH * 0.5, 140.0)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)

	var accent := ColorRect.new()
	accent.custom_minimum_size = Vector2(0.0, 6.0)
	accent.color = option.get("accent_color", CardPickStubDataRes.STAT_ACCENT)
	vbox.add_child(accent)

	var body := MarginContainer.new()
	body.add_theme_constant_override("margin_left", 16)
	body.add_theme_constant_override("margin_top", 12)
	body.add_theme_constant_override("margin_right", 16)
	body.add_theme_constant_override("margin_bottom", 16)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = str(option.get("title", "Card"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 20)
	content.add_child(title)

	var summary := Label.new()
	summary.text = str(option.get("summary", ""))
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("#A8B5A0"))
	content.add_child(summary)

	var detail := Label.new()
	detail.text = str(option.get("hover_detail", ""))
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.visible = false
	detail.add_theme_color_override("font_color", Color("#F5F0E6"))
	detail.add_theme_font_size_override("font_size", 14)
	content.add_child(detail)

	body.add_child(content)
	vbox.add_child(body)
	card_root.add_child(vbox)

	card_root.gui_input.connect(_on_card_gui_input.bind(option, card_root, accent))
	card_root.mouse_entered.connect(func() -> void: detail.visible = true)
	card_root.mouse_exited.connect(func() -> void:
		if not _committed:
			detail.visible = false
	)

	wrapper.add_child(card_root)
	_card_buttons.append(card_root)
	return wrapper


func _on_card_gui_input(
	event: InputEvent,
	option: Dictionary,
	card_root: PanelContainer,
	accent: ColorRect
) -> void:
	if _committed:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_commit_pick(option, card_root, accent)


func _commit_pick(option: Dictionary, card_root: PanelContainer, accent: ColorRect = null) -> void:
	if _committed:
		return
	_committed = true
	for panel in _card_buttons:
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var detail := _find_detail_label(card_root)
	if detail != null:
		detail.visible = true
	var card_id := str(option.get("id", ""))
	var card_type := str(option.get("type", ""))
	if card_type == "stat" and accent != null:
		_play_select_juice(card_root, accent)
	CardEffectApplierRes.apply(card_id, _wave_index)
	await get_tree().create_timer(FLIP_DURATION_SEC).timeout
	RunManager.complete_card_pick()
	hide_overlay()


func _play_select_juice(card_root: PanelContainer, accent: ColorRect) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_root, "scale", Vector2(1.05, 1.05), FLIP_DURATION_SEC * 0.5)
	tween.tween_property(card_root, "rotation_degrees", 4.0, FLIP_DURATION_SEC * 0.5)
	tween.chain().tween_property(card_root, "scale", Vector2.ONE, FLIP_DURATION_SEC * 0.5)
	tween.parallel().tween_property(card_root, "rotation_degrees", 0.0, FLIP_DURATION_SEC * 0.5)
	if accent != null:
		var flash := accent.color
		tween.parallel().tween_property(accent, "color", flash.lightened(0.35), FLIP_DURATION_SEC * 0.4)
		tween.chain().tween_property(accent, "color", flash, FLIP_DURATION_SEC * 0.4)


func _find_detail_label(card_root: PanelContainer) -> Label:
	var vbox := card_root.get_child(0) as VBoxContainer
	if vbox == null or vbox.get_child_count() < 2:
		return null
	var body := vbox.get_child(1) as MarginContainer
	if body == null or body.get_child_count() < 1:
		return null
	var content := body.get_child(0) as VBoxContainer
	if content == null or content.get_child_count() < 3:
		return null
	return content.get_child(2) as Label


func _clear_cards() -> void:
	_card_buttons.clear()
	if _cards_row == null:
		return
	for child in _cards_row.get_children():
		child.queue_free()
