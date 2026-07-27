extends Node
## HR Ape flee-threshold modifier sync (Story 4.4).

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")

var _modifiers_active: bool = false


func _ready() -> void:
	add_to_group("hr_ape_system")


func _process(_delta: float) -> void:
	var dissat := _get_dissatisfaction_system()
	if dissat == null:
		return
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		if _modifiers_active:
			dissat.clear_hr_modifiers()
			_modifiers_active = false
		return

	dissat.clear_hr_modifiers()
	_modifiers_active = false
	var pool := _get_ape_pool()
	if pool == null:
		return
	for ape in pool.get_active_items():
		if ape.role_id != "hr_ape":
			continue
		if ape.state != ApeBaseScript.State.PATH and ape.state != ApeBaseScript.State.ACT:
			continue
		dissat.register_hr_modifier(ape.grid_cell)
		_modifiers_active = true


func _get_dissatisfaction_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("dissatisfaction_system")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_ape_pool() -> Node:
	var nodes := get_tree().get_nodes_in_group("ape_pool")
	if nodes.is_empty():
		return null
	return nodes[0]
