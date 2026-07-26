extends Node

const SPECIES_DIR := "res://data/species/"
const APES_DIR := "res://data/apes/"
const FALLBACK_SPECIES_PATH := "res://data/fallback/species.json"
const FALLBACK_APES_PATH := "res://data/fallback/apes.json"
const MIN_SPECIES := 3
const MIN_APES := 2

var _species: Dictionary = {}
var _apes: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	var ok := load_all()
	if ok:
		print(
			"[ContentRegistry] Boot load OK — %d species, %d apes"
			% [_species.size(), _apes.size()]
		)
	else:
		push_error("[ContentRegistry] Boot load failed — critical content missing")


func load_all() -> bool:
	_species.clear()
	_apes.clear()
	_loaded = false

	var species_ok := _load_species()
	var apes_ok := _load_apes()
	if not (species_ok and apes_ok):
		_species.clear()
		_apes.clear()
		_loaded = false
		return false
	_loaded = true
	return true


func is_loaded() -> bool:
	return _loaded


func get_species(species_id: String) -> SpeciesDef:
	if not _species.has(species_id):
		push_warning("[ContentRegistry] Unknown species id: %s" % species_id)
		return null
	return _species[species_id].duplicate(true) as SpeciesDef


func get_ape(role_id: String) -> ApeRoleDef:
	if not _apes.has(role_id):
		push_warning("[ContentRegistry] Unknown ape role id: %s" % role_id)
		return null
	return _apes[role_id].duplicate(true) as ApeRoleDef


func has_species(id: String) -> bool:
	return _species.has(id)


func has_ape(id: String) -> bool:
	return _apes.has(id)


func get_all_species_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in _species.keys():
		ids.append(key)
	ids.sort()
	return ids


func get_all_ape_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in _apes.keys():
		ids.append(key)
	ids.sort()
	return ids


func _load_species() -> bool:
	if _load_species_from_dir():
		return true
	push_warning("[ContentRegistry] Primary species load failed; trying fallback")
	if _load_species_from_fallback():
		return true
	push_error("[ContentRegistry] Failed to load species from primary and fallback")
	return false


func _load_apes() -> bool:
	if _load_apes_from_dir():
		return true
	push_warning("[ContentRegistry] Primary apes load failed; trying fallback")
	if _load_apes_from_fallback():
		return true
	push_error("[ContentRegistry] Failed to load apes from primary and fallback")
	return false


func _load_species_from_dir() -> bool:
	var entries := _load_json_objects_from_dir(SPECIES_DIR)
	if entries.is_empty():
		return false
	return _store_species_entries(entries)


func _load_species_from_fallback() -> bool:
	var entries := _load_json_array(FALLBACK_SPECIES_PATH)
	if entries.is_empty():
		return false
	return _store_species_entries(entries)


func _load_apes_from_dir() -> bool:
	var entries := _load_json_objects_from_dir(APES_DIR)
	if entries.is_empty():
		return false
	return _store_ape_entries(entries)


func _load_apes_from_fallback() -> bool:
	var entries := _load_json_array(FALLBACK_APES_PATH)
	if entries.is_empty():
		return false
	return _store_ape_entries(entries)


func _store_species_entries(entries: Array) -> bool:
	var loaded := 0
	for entry in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			push_error("[ContentRegistry] Species entry is not a dictionary")
			continue
		var def := SpeciesDef.from_dict(entry)
		if def == null:
			push_error("[ContentRegistry] Invalid species entry: %s" % str(entry))
			continue
		if _species.has(def.id):
			push_error("[ContentRegistry] Duplicate species id: %s" % def.id)
			continue
		_species[def.id] = def
		loaded += 1
	if loaded < MIN_SPECIES:
		push_error(
			"[ContentRegistry] Expected at least %d species, got %d"
			% [MIN_SPECIES, loaded]
		)
		_species.clear()
		return false
	return true


func _store_ape_entries(entries: Array) -> bool:
	var loaded := 0
	for entry in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			push_error("[ContentRegistry] Ape entry is not a dictionary")
			continue
		var def := ApeRoleDef.from_dict(entry)
		if def == null:
			push_error("[ContentRegistry] Invalid ape entry: %s" % str(entry))
			continue
		if _apes.has(def.id):
			push_error("[ContentRegistry] Duplicate ape id: %s" % def.id)
			continue
		_apes[def.id] = def
		loaded += 1
	if loaded < MIN_APES:
		push_error(
			"[ContentRegistry] Expected at least %d apes, got %d"
			% [MIN_APES, loaded]
		)
		_apes.clear()
		return false
	return true


func _load_json_objects_from_dir(dir_path: String) -> Array:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return []
	var entries: Array = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var file_path := dir_path.path_join(file_name)
			var data := _parse_json_file(file_path)
			if typeof(data) == TYPE_DICTIONARY:
				entries.append(data)
		file_name = dir.get_next()
	dir.list_dir_end()
	return entries


func _load_json_array(path: String) -> Array:
	var data := _parse_json_file(path)
	if data == null:
		return []
	if typeof(data) != TYPE_ARRAY:
		push_error("[ContentRegistry] Expected JSON array in: %s" % path)
		return []
	return data


func _parse_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("[ContentRegistry] Missing JSON file: %s" % path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[ContentRegistry] Cannot open JSON file: %s" % path)
		return null
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("[ContentRegistry] Malformed JSON in: %s" % path)
		return null
	return parsed
