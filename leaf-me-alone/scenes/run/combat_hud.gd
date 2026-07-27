extends Control
## Greybox combat HUD — wave timer, structure HP, wave banner, flee feedback (Stories 1.6, 3.7, 4.6, 4.7).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const DogecoinFloatLogicRes := preload("res://scripts/systems/dogecoin_float_logic.gd")
const StructureHpLogicRes := preload("res://scripts/systems/structure_hp_logic.gd")
const WaveBannerLogicRes := preload("res://scripts/systems/wave_banner_logic.gd")

const WAVE_STING_PATH := "res://assets/audio/wave_sting.wav"

@onready var _vignette_top: ColorRect = %FleeVignetteTop
@onready var _vignette_bottom: ColorRect = %FleeVignetteBottom
@onready var _vignette_left: ColorRect = %FleeVignetteLeft
@onready var _vignette_right: ColorRect = %FleeVignetteRight
@onready var _resignation_toast: Label = %ResignationToast
@onready var _dogecoin_value: Label = %DogecoinValue
@onready var _dogecoin_chip: PanelContainer = %DogecoinChip
@onready var _wave_banner: PanelContainer = %WaveBanner
@onready var _wave_banner_label: Label = %WaveBannerLabel
@onready var _core_hp_bar: ProgressBar = %CoreHpBar
@onready var _nests_hp_bar: ProgressBar = %NestsHpBar
@onready var _wave_sting_player: AudioStreamPlayer = %WaveStingPlayer

var _vignette_tween: Tween
var _toast_tween: Tween
var _banner_tween: Tween
var _danger_pulse_tween: Tween
var _shake_tween: Tween
var _core_danger: bool = false
var _nests_danger: bool = false
var _banner_home_y: float = 0.0


func _ready() -> void:
	add_to_group("combat_hud")
	_set_vignette_alpha(0.0)
	_resignation_toast.visible = false
	_resignation_toast.modulate.a = 0.0
	if _wave_banner != null:
		_wave_banner.visible = false
		_wave_banner.modulate.a = 0.0
		_banner_home_y = _wave_banner.position.y
		_wave_banner.position.y = _banner_home_y - 24.0
	if _wave_sting_player != null:
		_wave_sting_player.bus = GameConstantsRes.STINGS_AUDIO_BUS
		if ResourceLoader.exists(WAVE_STING_PATH):
			_wave_sting_player.stream = load(WAVE_STING_PATH)
	EventBus.run_event.connect(_on_run_event)
	refresh_dogecoin()
	refresh_structure_hp()


func _process(_delta: float) -> void:
	_update_danger_pulse()


func update_wave_timer(wave_index: int, remaining_sec: float, max_waves: int) -> void:
	var minutes := int(maxf(remaining_sec, 0.0)) / 60
	var seconds := int(maxf(remaining_sec, 0.0)) % 60
	%WaveTimerLabel.text = tr("Wave %d/%d — %d:%02d") % [
		wave_index,
		max_waves,
		minutes,
		seconds,
	]


func show_wave_banner(wave_index: int) -> void:
	if _wave_banner == null or _wave_banner_label == null:
		return
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	_wave_banner_label.text = WaveBannerLogicRes.get_banner_text_for_wave(wave_index)
	_wave_banner.visible = true
	_wave_banner.modulate.a = 0.0
	_wave_banner.position.y = _banner_home_y - 24.0
	_play_wave_sting()
	_banner_tween = create_tween()
	_banner_tween.set_parallel(true)
	_banner_tween.tween_property(_wave_banner, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_property(_wave_banner, "position:y", _banner_home_y, 0.35).set_trans(Tween.TRANS_BACK)
	_banner_tween.chain().tween_interval(GameConstantsRes.WAVE_BANNER_DURATION_SEC)
	_banner_tween.chain().tween_property(_wave_banner, "modulate:a", 0.0, 0.25)
	_banner_tween.chain().tween_callback(func() -> void:
		_wave_banner.visible = false
	)


func show_boss_banner(message: String) -> void:
	if _wave_banner == null or _wave_banner_label == null:
		return
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	_wave_banner_label.text = message
	_wave_banner.visible = true
	_wave_banner.modulate.a = 0.0
	_wave_banner.position.y = _banner_home_y - 24.0
	_play_wave_sting()
	_banner_tween = create_tween()
	_banner_tween.set_parallel(true)
	_banner_tween.tween_property(_wave_banner, "modulate:a", 1.0, 0.25)
	_banner_tween.tween_property(_wave_banner, "position:y", _banner_home_y, 0.35).set_trans(Tween.TRANS_BACK)
	_banner_tween.chain().tween_interval(GameConstantsRes.WAVE_BANNER_DURATION_SEC)
	_banner_tween.chain().tween_property(_wave_banner, "modulate:a", 0.0, 0.25)
	_banner_tween.chain().tween_callback(func() -> void:
		_wave_banner.visible = false
	)


func play_core_hit_feedback() -> void:
	play_flee_vignette()
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	var base := position
	_shake_tween = create_tween()
	_shake_tween.tween_property(self, "position:x", base.x + 6.0, 0.05)
	_shake_tween.tween_property(self, "position:x", base.x - 6.0, 0.05)
	_shake_tween.tween_property(self, "position:x", base.x + 4.0, 0.05)
	_shake_tween.tween_property(self, "position:x", base.x, 0.05)


func refresh_structure_hp() -> void:
	var structure := _get_structure_hp_system()
	if structure == null:
		return
	var core: Dictionary = structure.get_core_state()
	var nests: Array = structure.get_nest_states()
	var core_ratio := StructureHpLogicRes.hp_ratio(
		int(core.get("current_hp", 0)),
		int(core.get("max_hp", 1))
	)
	var nests_ratio := StructureHpLogicRes.nests_display_ratio(nests)
	if _core_hp_bar != null:
		_core_hp_bar.value = core_ratio * 100.0
	_core_danger = StructureHpLogicRes.is_danger(
		int(core.get("current_hp", 0)),
		int(core.get("max_hp", 1))
	)
	if _nests_hp_bar != null:
		_nests_hp_bar.value = nests_ratio * 100.0
	_nests_danger = nests_ratio <= GameConstantsRes.STRUCTURE_DANGER_HP_RATIO


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
	if event == RunEventRes.Type.DOGECOIN_CHANGED:
		var data: Dictionary = payload
		refresh_dogecoin()
		var delta := int(data.get("delta", 0))
		if delta > 0 and RunManager.get_state() == RunStateEnumRes.State.CombatPhase:
			_play_dogecoin_float(delta)
		return
	if event == RunEventRes.Type.STRUCTURE_DAMAGED:
		var hit: Dictionary = payload
		refresh_structure_hp()
		if bool(hit.get("is_core", false)):
			play_core_hit_feedback()
		return
	if event != RunEventRes.Type.STATE_CHANGED:
		return
	if int(payload.get("to", -1)) == RunStateEnumRes.State.CombatPhase:
		refresh_structure_hp()


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


func _play_wave_sting() -> void:
	if _wave_sting_player == null or _wave_sting_player.stream == null:
		return
	_wave_sting_player.play()


func _update_danger_pulse() -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		if _danger_pulse_tween != null and _danger_pulse_tween.is_valid():
			_danger_pulse_tween.kill()
		_reset_bar_modulate(_core_hp_bar)
		_reset_bar_modulate(_nests_hp_bar)
		return
	var pulse_target: Control = null
	if _core_danger:
		pulse_target = _core_hp_bar
	elif _nests_danger:
		pulse_target = _nests_hp_bar
	if pulse_target == null:
		if _danger_pulse_tween != null and _danger_pulse_tween.is_valid():
			_danger_pulse_tween.kill()
		_reset_bar_modulate(_core_hp_bar)
		_reset_bar_modulate(_nests_hp_bar)
		return
	if _danger_pulse_tween != null and _danger_pulse_tween.is_valid():
		return
	_reset_bar_modulate(_core_hp_bar if pulse_target != _core_hp_bar else null)
	_reset_bar_modulate(_nests_hp_bar if pulse_target != _nests_hp_bar else null)
	var base := pulse_target.modulate
	_danger_pulse_tween = create_tween()
	_danger_pulse_tween.set_loops()
	_danger_pulse_tween.tween_property(pulse_target, "modulate", GameConstantsRes.FLEE_COLOR, 0.35)
	_danger_pulse_tween.tween_property(pulse_target, "modulate", base, 0.35)


func _reset_bar_modulate(bar: Control) -> void:
	if bar == null:
		return
	bar.modulate = Color.WHITE


func _get_economy_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_structure_hp_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("structure_hp_system")
	if nodes.is_empty():
		return null
	return nodes[0]


func _set_vignette_alpha(alpha: float) -> void:
	var color := GameConstantsRes.FLEE_COLOR
	color.a = alpha
	for edge in [_vignette_top, _vignette_bottom, _vignette_left, _vignette_right]:
		if edge != null:
			edge.color = color
