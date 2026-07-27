class_name CardDef
extends Resource

const SoilTypeRes := preload("res://scripts/data/soil_type.gd")

@export var id: String = ""
@export var type: String = ""
@export var stat_key: String = ""
@export var value_pct: float = 0.0
@export var clan: String = "red"
@export var display_name: String = ""
@export var summary: String = ""
@export var hover_detail: String = ""
@export var target_soil: int = SoilTypeRes.Type.RED


static func from_dict(data: Dictionary):
	if not _validate_dict(data):
		return null
	var def := new()
	def.id = str(data["id"])
	def.type = str(data["type"])
	def.display_name = str(data.get("display_name", data.get("title", def.id)))
	def.summary = str(data.get("summary", ""))
	def.hover_detail = str(data.get("hover_detail", ""))
	if data.has("stat_key"):
		def.stat_key = str(data["stat_key"])
	if data.has("value_pct"):
		def.value_pct = float(data["value_pct"])
	if data.has("clan"):
		def.clan = str(data["clan"])
	if data.has("target_soil"):
		def.target_soil = int(data["target_soil"])
	return def


static func _validate_dict(data: Dictionary) -> bool:
	if not data.has("id") or not data.has("type"):
		return false
	if str(data["id"]).strip_edges().is_empty():
		return false
	var card_type := str(data["type"])
	if card_type in ["sin", "risk"]:
		return false
	if card_type == "stat":
		if not data.has("stat_key") or not data.has("value_pct"):
			return false
	return true
