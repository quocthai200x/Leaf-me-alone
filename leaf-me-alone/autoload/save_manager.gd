extends Node
## Events emitted: none
## Events listened: none

const META_SAVE_PATH := "user://save/meta.json"


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


func save(data: Dictionary = {}) -> bool:
	if not _ensure_save_dir():
		return false
	var file := FileAccess.open(META_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager.save(): unable to open %s" % META_SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data))
	return true


func load_meta() -> Dictionary:
	if not FileAccess.file_exists(META_SAVE_PATH):
		return {}
	var file := FileAccess.open(META_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager.load_meta(): unable to open %s" % META_SAVE_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_warning("SaveManager.load_meta(): invalid JSON in %s" % META_SAVE_PATH)
	return {}
