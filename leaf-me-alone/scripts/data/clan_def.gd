class_name ClanDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var unlock_cost: int = 0
@export var description: String = ""


static func from_dict(data: Dictionary):
	if not data.has("id") or str(data["id"]).strip_edges().is_empty():
		return null
	var def := new()
	def.id = str(data["id"])
	def.display_name = str(data.get("display_name", def.id))
	def.unlock_cost = maxi(0, int(data.get("unlock_cost", 0)))
	def.description = str(data.get("description", ""))
	return def
