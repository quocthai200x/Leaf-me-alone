class_name SettingsLogic
extends RefCounted
## Audio settings helpers (Story 7.5).

const MASTER_BUS := &"Master"
const SFX_BUS := &"SFX"
const MUTE_DB := -80.0


static func linear_to_bus_db(linear: float) -> float:
	var clamped := clampf(linear, 0.0, 1.0)
	if clamped <= 0.001:
		return MUTE_DB
	return linear_to_db(clamped)


static func apply_audio_settings(settings: Dictionary) -> void:
	_set_bus_linear(MASTER_BUS, float(settings.get("master_volume", 1.0)))
	_set_bus_linear(SFX_BUS, float(settings.get("sfx_volume", 1.0)))


static func _set_bus_linear(bus_name: StringName, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		push_warning("[SettingsLogic] Missing audio bus: %s" % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, linear_to_bus_db(linear))
