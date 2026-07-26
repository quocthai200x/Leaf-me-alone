extends Control
## Greybox combat HUD shell — wave timer, flee vignette, resignation toast (Stories 1.6, 3.7).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")

@onready var _vignette_top: ColorRect = %FleeVignetteTop
@onready var _vignette_bottom: ColorRect = %FleeVignetteBottom
@onready var _vignette_left: ColorRect = %FleeVignetteLeft
@onready var _vignette_right: ColorRect = %FleeVignetteRight
@onready var _resignation_toast: Label = %ResignationToast

var _vignette_tween: Tween
var _toast_tween: Tween


func _ready() -> void:
	add_to_group("combat_hud")
	_set_vignette_alpha(0.0)
	_resignation_toast.visible = false
	_resignation_toast.modulate.a = 0.0


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


func _set_vignette_alpha(alpha: float) -> void:
	var color := GameConstantsRes.FLEE_COLOR
	color.a = alpha
	for edge in [_vignette_top, _vignette_bottom, _vignette_left, _vignette_right]:
		if edge != null:
			edge.color = color
