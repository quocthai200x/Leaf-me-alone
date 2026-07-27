extends GdUnitTestSuite
## Soil terraform card — single tile (Story 6.3).

const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const CardEffectApplierRes := preload("res://scripts/systems/card_effect_applier.gd")
const DissatisfactionSystemScript := preload("res://scripts/systems/dissatisfaction_system.gd")


func before_test() -> void:
	ContentRegistry.load_all()


func test_terraform_cell_changes_soil_type() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(42)
	var cell := Vector2i(8, 8)
	var before := grid.get_soil_type(cell)
	assert_bool(grid.terraform_cell(cell, SoilTypeRes.Type.RED)).is_true()
	assert_int(grid.get_soil_type(cell)).is_equal(SoilTypeRes.Type.RED)
	assert_int(grid.get_soil_type(cell)).is_not_equal(before)


func test_cannot_terraform_structure_cell() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(99)
	grid.place_structures_from_seed(99)
	var core := grid.get_forest_core_cell()
	if core.x >= 0:
		assert_bool(grid.can_terraform_cell(core)).is_false()
		assert_bool(grid.terraform_cell(core, SoilTypeRes.Type.SAND)).is_false()


func test_apply_soil_at_cell_emits_pick_and_increments_count() -> void:
	RunManager.run_state = RunState.new()
	RunManager.run_state.init_from_seed(1)
	RunManager.grid_data = GridDataRes.new()
	RunManager.grid_data.generate_from_seed(1)
	var cell := Vector2i(5, 5)
	var picked := {"done": false}
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEvent.Type.CARD_PICKED:
			var data: Dictionary = payload
			if str(data.get("card_type", "")) == "soil":
				picked.done = true
				assert_vector(data.get("cell", Vector2i.ZERO)).is_equal(cell)
	EventBus.run_event.connect(handler)
	CardEffectApplierRes.begin_soil_pick("soil_terraform_red")
	assert_bool(
		CardEffectApplierRes.apply_soil_at_cell("soil_terraform_red", cell, 2)
	).is_true()
	assert_bool(picked.done).is_true()
	assert_int(RunManager.run_state.card_picks_count).is_equal(1)
	assert_int(RunManager.grid_data.get_soil_type(cell)).is_equal(SoilTypeRes.Type.RED)
	EventBus.run_event.disconnect(handler)


func test_recalculate_for_terraform_reduces_mismatch_dissatisfaction() -> void:
	var grid := GridDataRes.new()
	grid.generate_from_seed(7)
	var cell := Vector2i(10, 10)
	assert_bool(grid.place_plant(cell, "peanut", 80)).is_true()
	grid.set_cell_soil(cell, SoilTypeRes.Type.SAND)
	grid.adjust_plant_dissatisfaction(cell, 25)
	RunManager.run_state = RunState.new()
	RunManager.run_state.init_from_seed(7)
	RunManager.grid_data = grid
	var diss := DissatisfactionSystemScript.new()
	add_child(diss)
	await get_tree().process_frame
	var before := grid.get_plant_dissatisfaction(cell)
	assert_int(before).is_greater(0)
	grid.terraform_cell(cell, SoilTypeRes.Type.RED)
	diss.recalculate_for_terraform(cell)
	assert_int(grid.get_plant_dissatisfaction(cell)).is_less(before)
	diss.queue_free()
