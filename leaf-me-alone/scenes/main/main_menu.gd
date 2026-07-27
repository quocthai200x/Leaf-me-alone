extends Control
## Events emitted: none
## Events listened: none

const RUN_ROOT_SCENE := "res://scenes/run/run_root.tscn"
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

const LOADING_BIOME_TEXT := "Tropical — Red Soil"
const LOADING_QUIP_TEXT := "Generating island… HR not included."

@onready var _play_button: Button = %PlayButton
@onready var _shop_button: Button = %ShopButton
@onready var _quit_button: Button = %QuitButton
@onready var _carbon_shop: Control = %CarbonShop
@onready var _status_label: Label = %StatusLabel
@onready var _loading_overlay: ColorRect = %LoadingOverlay
@onready var _loading_biome_label: Label = %LoadingBiomeLabel
@onready var _loading_quip_label: Label = %LoadingQuipLabel


func _ready() -> void:
	RunManager.enter_main_menu()
	_play_button.text = tr("PLAY")
	_quit_button.text = tr("QUIT")
	$MenuColumn/TitleLabel.text = tr("Leaf Me Alone")
	$MenuColumn/TaglineLabel.text = tr("Who's righteous? No one — only the strong survive.")
	_play_button.pressed.connect(_on_play_pressed)
	_shop_button.pressed.connect(_on_shop_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_loading_overlay.visible = false
	_update_boot_status()


func _update_boot_status() -> void:
	if not ContentRegistry.is_loaded():
		_status_label.text = tr("Content load failed — cannot start a run")
		_play_button.disabled = true
	else:
		_status_label.text = ""


func _on_play_pressed() -> void:
	if not ContentRegistry.is_loaded():
		_status_label.text = tr("Content load failed — cannot start a run")
		return

	if not RunManager.can_transition_to(RunStateEnumRes.State.RunStart):
		push_warning("MainMenu: PLAY blocked from state %s" % RunManager.get_state())
		_status_label.text = tr("Cannot start run from current state")
		return

	_play_button.disabled = true
	_show_loading_overlay()

	await get_tree().process_frame

	var seed_value := randi()
	if seed_value == 0:
		seed_value = 1

	var grid := RunManager.start_run(seed_value)
	if grid == null:
		push_error("MainMenu: RunManager.start_run failed")
		_hide_loading_overlay()
		_play_button.disabled = false
		return

	if RunManager.run_state.dogecoin != 0:
		push_error("MainMenu: Dogecoin must reset to 0 at run start")
		_hide_loading_overlay()
		_play_button.disabled = false
		return

	get_tree().change_scene_to_file(RUN_ROOT_SCENE)


func _on_shop_pressed() -> void:
	if _carbon_shop != null and _carbon_shop.has_method("open_shop"):
		_carbon_shop.open_shop()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _show_loading_overlay() -> void:
	_loading_biome_label.text = tr(LOADING_BIOME_TEXT)
	_loading_quip_label.text = tr(LOADING_QUIP_TEXT)
	_loading_overlay.visible = true


func _hide_loading_overlay() -> void:
	_loading_overlay.visible = false
