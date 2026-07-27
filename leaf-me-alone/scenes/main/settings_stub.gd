extends Control
## Settings overlay — Master/SFX volume sliders (Story 7.5).

const SettingsLogicRes := preload("res://scripts/utils/settings_logic.gd")

@export var title_text: String = "Settings"

@onready var _master_slider: HSlider = %MasterSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _master_value: Label = %MasterValueLabel
@onready var _sfx_value: Label = %SfxValueLabel


func _ready() -> void:
	visible = false
	%BackButton.pressed.connect(close_overlay)
	_master_slider.value_changed.connect(_on_master_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_apply_title()


func open_overlay() -> void:
	_sync_from_save()
	_apply_title()
	visible = true


func close_overlay() -> void:
	visible = false


func _apply_title() -> void:
	var title := get_node_or_null("%TitleLabel")
	if title is Label:
		(title as Label).text = title_text


func _sync_from_save() -> void:
	var settings := SaveManager.get_settings()
	_master_slider.set_value_no_signal(float(settings.get("master_volume", 1.0)))
	_sfx_slider.set_value_no_signal(float(settings.get("sfx_volume", 1.0)))
	_update_value_labels()


func _on_master_changed(value: float) -> void:
	SaveManager.set_setting("master_volume", value)
	SettingsLogicRes.apply_audio_settings(SaveManager.get_settings())
	_update_value_labels()


func _on_sfx_changed(value: float) -> void:
	SaveManager.set_setting("sfx_volume", value)
	SettingsLogicRes.apply_audio_settings(SaveManager.get_settings())
	_update_value_labels()


func _update_value_labels() -> void:
	_master_value.text = "%d%%" % int(round(_master_slider.value * 100.0))
	_sfx_value.text = "%d%%" % int(round(_sfx_slider.value * 100.0))
