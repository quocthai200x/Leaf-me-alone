class_name AchievementCatalog
extends RefCounted
## Read-only achievement stub data (Story 7.5).

const ACHIEVEMENTS_PATH := "res://data/achievements.json"


static func load_locked_entries() -> Array[Dictionary]:
	var file := FileAccess.open(ACHIEVEMENTS_PATH, FileAccess.READ)
	if file == null:
		push_warning("[AchievementCatalog] Missing %s" % ACHIEVEMENTS_PATH)
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	var entries: Array = parsed.get("achievements", [])
	var result: Array[Dictionary] = []
	for entry in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		result.append({
			"id": str(entry.get("id", "")),
			"title": str(entry.get("title", "Unknown")),
			"description": str(entry.get("description", "")),
		})
	return result
