extends Control
## Greybox combat HUD shell — wave timer, flee vignette, resignation toast, Dogecoin chip (Stories 1.6, 3.7, 4.6).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const DogecoinFloatLogicRes := preload("res://scripts/systems/dogecoin_float_logic.gd")

@onready var _vignette_top: ColorRect = %FleeVignetteTop
@onready var _vignette_bottom: ColorRect = %FleeVignetteBottom
@onready var _vignette_left: ColorRect = %FleeVignetteLeft
@onready var _vignette_right: ColorRect = %FleeVignetteRight
@onready var _resignation_toast: Label = %ResignationToast
@onready var _dogecoin_value: Label = %DogecoinValue
@onready var _dogecoin_chip: PanelContainer = %DogecoinChip

var _vignette_tween: Tween
var _toast_tween: Tween


func _ready() -> void:
	add_to_group("combat_hud")
	_set_vignette_alpha(0.0)
	_resignation_toast.visible = false
	_resignation_toast.modulate.a = 0.0
	EventBus.run_event.connect(_on_run_event)
	refresh_dogecoin()


func update_wave_timer(wave_index: int, remaining_sec: float, max_waves: int) -> void:
	var minutes := int(maxf(remaining_sec, 0.0)) / 60
	var seconds := int(maxf(remaining_sec, 0.0)) % 60
	%WaveTimerLabel.text = tr("Wave %d/%d — %d:%02d") % [
		wave_index,
		max_waves,
		minutes,
		seconds,
	]


func play_flee_vignette() -> void:
	if _vignette_tween != null and _vignette_tween.is_valid():
		_vignette_tween.kill()
	var half := GameConstantsRes.FLEE_VIGNETTE_DURATION_SEC * 0.5
	_vignette_tween = create_tween()
	_vignette_tween.tween_method(_set_vignette_alpha, 0.0, 0.55, half)
	_vignette_tween.tween_method(_set_vignette_alpha, 0.55, 0.0, half)


func show_resignation_toast(message: String) -> void:
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_resignation_toast.text = message
	_resignation_toast.visible = true
	_resignation_toast.modulate.a = 0.0
	var fade_in := 0.15
	var hold := GameConstantsRes.RESIGNATION_TOAST_DURATION_SEC
	var fade_out := 0.35
	_toast_tween = create_tween()
	_toast_tween.tween_property(_resignation_toast, "modulate:a", 1.0, fade_in)
	_toast_tween.tween_interval(hold)
	_toast_tween.tween_property(_resignation_toast, "modulate:a", 0.0, fade_out)
	_toast_tween.tween_callback(func() -> void:
		_resignation_toast.visible = false
	)


func refresh_dogecoin() -> void:
	var economy := _get_economy_system()
	var balance: int = economy.get_balance() if economy != null else RunManager.run_state.dogecoin
	if _dogecoin_value != null:
		_dogecoin_value.text = str(balance)


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.DOGECOIN_CHANGED:
		return
	var data: Dictionary = payload
	refresh_dogecoin()
	var delta := int(data.get("delta", 0))
	if delta <= 0:
		return
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	_play_dogecoin_float(delta)


func _play_dogecoin_float(amount: int) -> void:
	if _dogecoin_chip == null:
		return
	var popup := Label.new()
	popup.text = DogecoinFloatLogicRes.format_earn_popup(amount)
	popup.add_theme_font_size_override("font_size", 18)
	popup.modulate = GameConstantsRes.DISSATISFACTION_COLOR
	popup.position = _dogecoin_chip.position + Vector2(0, -8)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(popup)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - 28, 0.7)
	tween.tween_property(popup, "modulate:a", 0.0, 0.7)
	tween.chain().tween_callback(popup.queue_free)


func _get_economy_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return null
	return nodes[0]


func _set_vignette_alpha(alpha: float) -> void:
	var color := GameConstantsRes.FLEE_COLOR
	color.a = alpha
	for edge in [_vignette_top, _vignette_bottom, _vignette_left, _vignette_right]:
		if edge != null:
			edge.color = color
