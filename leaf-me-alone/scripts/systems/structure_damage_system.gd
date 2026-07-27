extends Node
## Applies structure damage from apes in ACT state at structure goals (Story 5.2).

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const StructureDamageLogicRes := preload("res://scripts/systems/structure_damage_logic.gd")
const ApeBaseScript := preload("res://scripts/entities/ape_base.gd")

var _attack_timers: Dictionary = {}


func _ready() -> void:
	add_to_group("structure_damage_system")


func _process(delta: float) -> void:
	if RunManager.get_state() != RunStateEnumRes.State.CombatPhase:
		return
	var pool := _get_ape_pool()
	if pool == null:
		return
	for ape in pool.get_active_items():
		if ape.state != ApeBaseScript.State.ACT:
			_clear_timer(ape)
			continue
		var target: Vector2i = ape.goal_cell if ape.goal_cell != Vector2i.ZERO else ape.grid_cell
		if not StructureDamageLogicRes.is_attackable_structure_cell(RunManager.grid_data, target):
			_clear_timer(ape)
			continue
		_tick_attack(ape, target, delta)


func _tick_attack(ape: Node, target_cell: Vector2i, delta: float) -> void:
	var key := ape.get_instance_id()
	var timer := float(_attack_timers.get(key, 0.0))
	timer -= delta
	if timer > 0.0:
		_attack_timers[key] = timer
		return
	_attack_timers[key] = GameConstantsRes.get_structure_attack_interval_sec()
	var damage := StructureDamageLogicRes.get_damage_for_role(str(ape.role_id))
	var structure_hp := _get_structure_hp_system()
	if structure_hp != null and structure_hp.has_method("apply_damage_at_cell"):
		structure_hp.apply_damage_at_cell(target_cell, damage)


func _clear_timer(ape: Node) -> void:
	_attack_timers.erase(ape.get_instance_id())


func _get_ape_pool() -> Node:
	var nodes := get_tree().get_nodes_in_group("ape_pool")
	if nodes.is_empty():
		return null
	return nodes[0]


func _get_structure_hp_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("structure_hp_system")
	if nodes.is_empty():
		return null
	return nodes[0]
