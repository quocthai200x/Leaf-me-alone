extends Node
## Meta persistence: Carbon Credit, clan unlocks, settings (Story 7.1).
## Events emitted: meta_changed
## Events listened: none
## Never stores in-run Dogecoin — dual economy separation enforced.

signal meta_changed

const META_SAVE_PATH := "user://save/meta.json"
const SAVE_VERSION := 1
const DEFAULT_CLAN_ID := "red_soil"

var _meta: Dictionary = {}


func _ready() -> void:
	_meta = _load_or_default()


func get_carbon_credit() -> int:
	return int(_meta.get("carbon_credit", 0))


func set_carbon_credit(amount: int) -> void:
	_meta["carbon_credit"] = maxi(0, amount)
	save_meta()
	meta_changed.emit()


func add_carbon_credit(delta: int) -> void:
	set_carbon_credit(get_carbon_credit() + delta)


func get_unlocked_clans() -> Array[String]:
	var clans: Array = _meta.get("unlocked_clans", [])
	var result: Array[String] = []
	for clan_id in clans:
		if clan_id is String:
			result.append(clan_id)
	return result


func is_clan_unlocked(clan_id: String) -> bool:
	return clan_id in get_unlocked_clans()


func unlock_clan(clan_id: String) -> void:
	if clan_id.is_empty() or is_clan_unlocked(clan_id):
		return
	var clans := get_unlocked_clans()
	clans.append(clan_id)
	_meta["unlocked_clans"] = clans
	save_meta()
	meta_changed.emit()


func get_settings() -> Dictionary:
	var settings: Variant = _meta.get("settings", {})
	if settings is Dictionary:
		return settings.duplicate()
	return _default_meta()["settings"].duplicate()


func set_setting(key: String, value: Variant) -> void:
	if key.is_empty():
		return
	var settings := get_settings()
	settings[key] = value
	_meta["settings"] = settings
	save_meta()
	meta_changed.emit()


func save_meta() -> bool:
	return save(_meta)


func load_meta() -> Dictionary:
	return _meta.duplicate(true)


func reset_meta_for_tests() -> void:
	if FileAccess.file_exists(META_SAVE_PATH):
		DirAccess.remove_absolute(META_SAVE_PATH)
	_meta = _default_meta()
	save_meta()


func reload_from_disk_for_tests() -> void:
	_meta = _load_or_default()


func save(data: Dictionary = {}) -> bool:
	if not _ensure_save_dir():
		return false
	var payload := data if not data.is_empty() else _meta
	if not _validate_meta_shape(payload):
		push_error("SaveManager.save(): invalid meta shape — dogecoin must not be stored")
		return false
	var file := FileAccess.open(META_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager.save(): unable to open %s" % META_SAVE_PATH)
		return false
	file.store_string(JSON.stringify(payload))
	return true


func _load_or_default() -> Dictionary:
	if not FileAccess.file_exists(META_SAVE_PATH):
		return _default_meta()
	var file := FileAccess.open(META_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager.load_meta(): unable to open %s" % META_SAVE_PATH)
		return _default_meta()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and _validate_meta_shape(parsed):
		return _normalize_meta(parsed)
	push_warning("SaveManager.load_meta(): invalid JSON in %s" % META_SAVE_PATH)
	return _default_meta()


func _default_meta() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"carbon_credit": 0,
		"unlocked_clans": [DEFAULT_CLAN_ID],
		"settings": {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
		},
	}


func _normalize_meta(data: Dictionary) -> Dictionary:
	var normalized := _default_meta()
	normalized["version"] = int(data.get("version", SAVE_VERSION))
	normalized["carbon_credit"] = maxi(0, int(data.get("carbon_credit", 0)))
	var clans: Array = data.get("unlocked_clans", [DEFAULT_CLAN_ID])
	var unlocked: Array[String] = []
	for clan_id in clans:
		if clan_id is String and not clan_id.is_empty() and clan_id not in unlocked:
			unlocked.append(clan_id)
	if unlocked.is_empty():
		unlocked.append(DEFAULT_CLAN_ID)
	normalized["unlocked_clans"] = unlocked
	var settings: Variant = data.get("settings", {})
	if settings is Dictionary:
		for key in settings.keys():
			normalized["settings"][key] = settings[key]
	return normalized


func _validate_meta_shape(data: Dictionary) -> bool:
	if data.has("dogecoin"):
		return false
	return true


func _ensure_save_dir() -> bool:
	var dir := DirAccess.open("user://")
	if dir == null:
		push_error("SaveManager: unable to open user://")
		return false
	if not dir.dir_exists("save"):
		var error := dir.make_dir("save")
		if error != OK:
			push_error("SaveManager: failed to create user://save/")
			return false
	return true
