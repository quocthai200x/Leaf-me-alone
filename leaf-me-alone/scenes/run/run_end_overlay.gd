extends Control
## Run End overlay — win/loss summary, seed, CC earned (Stories 5.3, 5.5, 5.6, 7.2).

const RunEndLogicRes := preload("res://scripts/systems/run_end_logic.gd")
const MAIN_MENU_SCENE := "res://scenes/main/main_menu.tscn"
const CC_EARN_COLOR := Color(0.419608, 0.796078, 0.666667, 1.0)

@onready var _title: Label = %OutcomeTitle
@onready var _copy: Label = %OutcomeCopy
@onready var _seed_label: Label = %SeedLabel
@onready var _cc_label: Label = %CarbonPreviewLabel
@onready var _waves_label: Label = %WavesClearedLabel
@onready var _continue_btn: Button = %ContinueButton

var _cc_tween: Tween


func _ready() -> void:
	add_to_group("run_end_overlay")
	visible = false
	if _continue_btn != null:
		_continue_btn.pressed.connect(_on_continue_pressed)


func show_run_end(outcome: String, loss_reason: String, master_seed: int, waves_cleared: int) -> void:
	var title := RunEndLogicRes.get_outcome_title(outcome)
	var copy := RunEndLogicRes.get_outcome_copy(outcome, loss_reason)
	var cc_earned := RunManager.run_state.cc_earned_this_run
	if cc_earned <= 0:
		cc_earned = RunEndLogicRes.compute_cc_grant(outcome, waves_cleared)
	if _title != null:
		_title.text = title
	if _copy != null:
		_copy.text = copy
	if _seed_label != null:
		_seed_label.text = "Seed: %s" % RunEndLogicRes.format_seed_display(master_seed)
	if _waves_label != null:
		_waves_label.text = "Waves cleared: %d" % waves_cleared
	_play_cc_earned_animation(cc_earned)
	visible = true


func hide_overlay() -> void:
	if _cc_tween != null and _cc_tween.is_valid():
		_cc_tween.kill()
	visible = false


func _play_cc_earned_animation(amount: int) -> void:
	if _cc_label == null:
		return
	if _cc_tween != null and _cc_tween.is_valid():
		_cc_tween.kill()
	_cc_label.theme_type_variation = &"numeric"
	_cc_label.add_theme_color_override("font_color", CC_EARN_COLOR)
	_cc_label.text = "CC +0"
	_cc_label.scale = Vector2(0.9, 0.9)
	_cc_tween = create_tween()
	_cc_tween.set_parallel(true)
	_cc_tween.tween_method(_set_cc_label_value, 0.0, float(amount), 0.35)
	_cc_tween.tween_property(_cc_label, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK)


func _set_cc_label_value(value: float) -> void:
	if _cc_label != null:
		_cc_label.text = "CC +%d" % int(value)


func _on_continue_pressed() -> void:
	RunManager.reset()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
