extends GdUnitTestSuite
## Combat HUD structure HP and wave banner (Story 4.7).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const StructureHpLogicRes := preload("res://scripts/systems/structure_hp_logic.gd")
const WaveBannerLogicRes := preload("res://scripts/systems/wave_banner_logic.gd")
const StructureHpSystemScript := preload("res://scripts/systems/structure_hp_system.gd")
const PathfindingServiceScript := preload("res://scripts/systems/pathfinding_service.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const CombatHudScene := preload("res://scenes/run/combat_hud.tscn")
const PausePanelScene := preload("res://scenes/run/pause_panel.tscn")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_structure_danger_below_twenty_five_percent() -> void:
	assert_bool(StructureHpLogicRes.is_danger(24, 100)).is_true()
	assert_bool(StructureHpLogicRes.is_danger(26, 100)).is_false()


func test_nests_display_uses_minimum_ratio() -> void:
	var nests := [
		{"current_hp": 200, "max_hp": 200},
		{"current_hp": 40, "max_hp": 200},
		{"current_hp": 180, "max_hp": 200},
	]
	assert_float(StructureHpLogicRes.nests_display_ratio(nests)).is_equal(0.2)


func test_wave_two_banner_announces_hr_debut() -> void:
	var text := WaveBannerLogicRes.get_banner_text_for_wave(2)
	assert_str(text).contains("HR")
	assert_str(text).contains("Wave 2")


func test_wave_one_banner_has_no_debut_roles() -> void:
	var debut := WaveBannerLogicRes.get_debut_role_ids(1, WaveBannerLogicRes.load_slice_waves())
	assert_int(debut.size()).is_equal(0)
	var text := WaveBannerLogicRes.format_banner_text(1, debut)
	assert_str(text).contains("Fight!")


func test_structure_hp_system_initializes_from_pathfinding() -> void:
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	var grid := GridDataRes.new()
	grid.generate_from_seed(12345)
	grid.place_structures_from_seed(12345)
	pathfinding.initialize_from_grid(grid)
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame

	var core: Dictionary = structure.get_core_state()
	assert_int(core.get("current_hp", 0)).is_equal(GameConstantsRes.FOREST_CORE_MAX_HP)
	assert_int(structure.get_nest_states().size()).is_equal(3)
	structure.queue_free()
	pathfinding.queue_free()


func test_combat_hud_structure_bars_start_full() -> void:
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	var grid := GridDataRes.new()
	grid.generate_from_seed(99)
	grid.place_structures_from_seed(99)
	pathfinding.initialize_from_grid(grid)
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame

	var hud: Control = CombatHudScene.instantiate()
	add_child(hud)
	await get_tree().process_frame
	hud.refresh_structure_hp()

	var core_bar: ProgressBar = hud.get_node("%CoreHpBar")
	var nests_bar: ProgressBar = hud.get_node("%NestsHpBar")
	assert_float(core_bar.value).is_equal(100.0)
	assert_float(nests_bar.value).is_equal(100.0)

	hud.queue_free()
	structure.queue_free()
	pathfinding.queue_free()


func test_pause_panel_structure_summary() -> void:
	var pathfinding := PathfindingServiceScript.new()
	add_child(pathfinding)
	var grid := GridDataRes.new()
	grid.generate_from_seed(77)
	grid.place_structures_from_seed(77)
	pathfinding.initialize_from_grid(grid)
	var structure := StructureHpSystemScript.new()
	add_child(structure)
	await get_tree().process_frame

	var panel: Control = PausePanelScene.instantiate()
	add_child(panel)
	await get_tree().process_frame
	panel.refresh_structure_summary()
	var summary: Label = panel.get_node("%StructureSummary")
	assert_str(summary.text).contains("Core 100%")

	panel.queue_free()
	structure.queue_free()
	pathfinding.queue_free()
