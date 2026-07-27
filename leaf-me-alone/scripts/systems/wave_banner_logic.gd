class_name WaveBannerLogic
extends RefCounted
## Wave banner text and debut role detection (Story 4.7).

const ROLE_ICONS: Dictionary = {
	"saw_ape": "🪚",
	"hr_ape": "🦍",
	"pr_ape": "📢",
}

const GameConstantsRes := preload("res://scripts/utils/constants.gd")

const ROLE_LABELS: Dictionary = {
	"saw_ape": "Saw",
	"hr_ape": "HR",
	"pr_ape": "PR",
}


static func get_wave_role_ids(wave_entry: Dictionary) -> Array[String]:
	var roles: Array[String] = []
	var spawns: Array = wave_entry.get("spawns", [])
	for entry in spawns:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var ape_id := str(entry.get("ape_id", ""))
		if ape_id.is_empty() or roles.has(ape_id):
			continue
		roles.append(ape_id)
	return roles


static func get_debut_role_ids(wave_number: int, waves: Array) -> Array[String]:
	if wave_number <= 1:
		return []
	var seen: Dictionary = {}
	for wave_entry in waves:
		if typeof(wave_entry) != TYPE_DICTIONARY:
			continue
		if int(wave_entry.get("wave_number", -1)) >= wave_number:
			break
		for role_id in get_wave_role_ids(wave_entry):
			seen[role_id] = true
	var debut: Array[String] = []
	for wave_entry in waves:
		if typeof(wave_entry) != TYPE_DICTIONARY:
			continue
		if int(wave_entry.get("wave_number", -1)) != wave_number:
			continue
		for role_id in get_wave_role_ids(wave_entry):
			if not seen.has(role_id) and not debut.has(role_id):
				debut.append(role_id)
		break
	return debut


static func format_banner_text(wave_index: int, debut_roles: Array[String]) -> String:
	if debut_roles.is_empty():
		return "Wave %d — Fight!" % wave_index
	var parts: PackedStringArray = []
	for role_id in debut_roles:
		var icon := str(ROLE_ICONS.get(role_id, ""))
		var label := str(ROLE_LABELS.get(role_id, role_id))
		parts.append("%s %s Ape incoming!" % [icon, label])
	return "Wave %d — %s" % [wave_index, " · ".join(parts)]


static func load_slice_waves() -> Array:
	if not ResourceLoader.exists(GameConstantsRes.SLICE_WAVES_PATH):
		return []
	var file := FileAccess.open(GameConstantsRes.SLICE_WAVES_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		return []
	return parsed


static func get_banner_text_for_wave(wave_index: int) -> String:
	var debut := get_debut_role_ids(wave_index, load_slice_waves())
	return format_banner_text(wave_index, debut)
