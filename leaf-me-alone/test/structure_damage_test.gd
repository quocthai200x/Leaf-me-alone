extends GdUnitTestSuite
## Structure damage and loss conditions (Story 5.2).

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const StructureDamageLogicRes := preload("res://scripts/systems/structure_damage_logic.gd")
const StructureHpSystemScript := preload("res://scripts/systems/structure_hp_system.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_structure_damage_reduces_core_hp() -> void:
	RunManager.start_run(42)
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame
	var core_cell := RunManager.grid_data.get_forest_core_cell()
	var before := int(structure.get_core_state().get("current_hp", 0))
	structure.apply_damage_at_cell(core_cell, 50)
	var after := int(structure.get_core_state().get("current_hp", 0))
	assert_int(after).is_equal(before - 50)
	structure.queue_free()


func test_core_zero_triggers_run_loss() -> void:
	RunManager.start_run(99)
	RunManager.begin_combat_wave()
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame
	var core_cell := RunManager.grid_data.get_forest_core_cell()
	structure.apply_damage_at_cell(core_cell, GameConstantsRes.FOREST_CORE_MAX_HP)
	await get_tree().process_frame
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.RunEnd)
	assert_str(RunManager.run_state.run_outcome).is_equal("loss")
	structure.queue_free()


func test_all_nests_destroyed_triggers_loss() -> void:
	RunManager.start_run(77)
	RunManager.begin_combat_wave()
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame
	for nest_cell in RunManager.grid_data.get_root_nest_cells():
		structure.apply_damage_at_cell(nest_cell, GameConstantsRes.ROOT_NEST_MAX_HP)
	await get_tree().process_frame
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.RunEnd)
	assert_str(RunManager.run_state.loss_reason).is_equal("all_nests_destroyed")
	structure.queue_free()


func test_evaluate_loss_logic() -> void:
	assert_str(StructureDamageLogicRes.evaluate_loss(0, [])).is_equal("forest_core_destroyed")
	var nests := [{"current_hp": 0}, {"current_hp": 0}, {"current_hp": 0}]
	assert_str(StructureDamageLogicRes.evaluate_loss(100, nests)).is_equal("all_nests_destroyed")
	assert_str(StructureDamageLogicRes.evaluate_loss(100, [{"current_hp": 10}])).is_empty()
