class_name SpeciesDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var plant_cost: int = 0
@export var hp: int = 0
@export var attack: int = 0
@export var defense: int = 0
@export var abilities: Dictionary = {}


static func from_dict(data: Dictionary) -> SpeciesDef:
	if not _validate_dict(data):
		return null
	var def := SpeciesDef.new()
	def.id = str(data["id"])
	def.display_name = str(data["display_name"])
	def.plant_cost = int(data["plant_cost"])
	def.hp = int(data["hp"])
	def.attack = int(data["attack"])
	def.defense = int(data["defense"])
	if data.has("abilities") and typeof(data["abilities"]) == TYPE_DICTIONARY:
		def.abilities = (data["abilities"] as Dictionary).duplicate(true)
	return def


static func _validate_dict(data: Dictionary) -> bool:
	var required := ["id", "display_name", "plant_cost", "hp", "attack", "defense"]
	for key in required:
		if not data.has(key):
			return false
	if str(data["id"]).strip_edges().is_empty():
		return false
	for key in ["plant_cost", "hp", "attack", "defense"]:
		if typeof(data[key]) not in [TYPE_INT, TYPE_FLOAT]:
			return false
	return true
