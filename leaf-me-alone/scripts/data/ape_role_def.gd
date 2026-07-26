class_name ApeRoleDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var hp: int = 0
@export var speed: int = 0
@export var role: String = ""


static func from_dict(data: Dictionary) -> ApeRoleDef:
	if not _validate_dict(data):
		return null
	var def := ApeRoleDef.new()
	def.id = str(data["id"])
	def.display_name = str(data["display_name"])
	def.hp = int(data["hp"])
	def.speed = int(data["speed"])
	def.role = str(data["role"])
	return def


static func _validate_dict(data: Dictionary) -> bool:
	var required := ["id", "display_name", "hp", "speed", "role"]
	for key in required:
		if not data.has(key):
			return false
	if str(data["id"]).strip_edges().is_empty():
		return false
	for key in ["hp", "speed"]:
		if typeof(data[key]) not in [TYPE_INT, TYPE_FLOAT]:
			return false
	return true
