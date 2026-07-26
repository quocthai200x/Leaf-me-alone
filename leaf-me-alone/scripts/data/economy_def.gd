class_name EconomyDef
extends Resource

@export var water_cost: int = 0
@export var fertilize_cost: int = 0
@export var species_costs: Dictionary = {}


static func from_dict(data: Dictionary) -> EconomyDef:
	if not _validate_dict(data):
		return null
	var def := EconomyDef.new()
	def.water_cost = int(data["water_cost"])
	def.fertilize_cost = int(data["fertilize_cost"])
	var costs: Dictionary = {}
	for key in data["species_costs"].keys():
		costs[str(key)] = int(data["species_costs"][key])
	def.species_costs = costs
	return def


func get_species_cost(species_id: String) -> int:
	if not species_costs.has(species_id):
		return -1
	return int(species_costs[species_id])


static func _validate_dict(data: Dictionary) -> bool:
	var required := ["water_cost", "fertilize_cost", "species_costs"]
	for key in required:
		if not data.has(key):
			return false
	if typeof(data["species_costs"]) != TYPE_DICTIONARY:
		return false
	if data["species_costs"].is_empty():
		return false
	for key in ["water_cost", "fertilize_cost"]:
		if typeof(data[key]) not in [TYPE_INT, TYPE_FLOAT]:
			return false
	for species_id in data["species_costs"].keys():
		if typeof(data["species_costs"][species_id]) not in [TYPE_INT, TYPE_FLOAT]:
			return false
		if str(species_id).strip_edges().is_empty():
			return false
	return true
