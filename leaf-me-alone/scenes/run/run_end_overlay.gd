extends Control
## Run End overlay — win/loss summary, seed, CC preview (Stories 5.3, 5.5, 5.6).

const RunEndLogicRes := preload("res://scripts/systems/run_end_logic.gd")
const MAIN_MENU_SCENE := "res://scenes/main/main_menu.tscn"

@onready var _title: Label = %OutcomeTitle
@onready var _copy: Label = %OutcomeCopy
@onready var _seed_label: Label = %SeedLabel
@onready var _cc_label: Label = %CarbonPreviewLabel
@onready var _waves_label: Label = %WavesClearedLabel
@onready var _continue_btn: Button = %ContinueButton


func _ready() -> void:
	add_to_group("run_end_overlay")
	visible = false
	if _continue_btn != null:
		_continue_btn.pressed.connect(_on_continue_pressed)


func show_run_end(outcome: String, loss_reason: String, master_seed: int, waves_cleared: int) -> void:
	var title := RunEndLogicRes.get_outcome_title(outcome)
	var copy := RunEndLogicRes.get_outcome_copy(outcome, loss_reason)
	var cc_preview := RunEndLogicRes.compute_cc_preview(outcome, waves_cleared)
	if _title != null:
		_title.text = title
	if _copy != null:
		_copy.text = copy
	if _seed_label != null:
		_seed_label.text = "Seed: %s" % RunEndLogicRes.format_seed_display(master_seed)
	if _cc_label != null:
		_cc_label.text = "Carbon Credit preview: +%d CC" % cc_preview
	if _waves_label != null:
		_waves_label.text = "Waves cleared: %d" % waves_cleared
	visible = true


func hide_overlay() -> void:
	visible = false


func _on_continue_pressed() -> void:
	RunManager.reset()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
