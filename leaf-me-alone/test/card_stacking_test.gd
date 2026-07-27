extends GdUnitTestSuite
## Card stat buff stacking and cap (Story 6.2).

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const CardEffectApplierRes := preload("res://scripts/systems/card_effect_applier.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")


func before_test() -> void:
	ContentRegistry.load_all()


func test_stat_buff_stacks_and_clamps_at_cap() -> void:
	var run_state := RunState.new()
	run_state.init_from_seed(42)
	RunManager.run_state = run_state
	run_state.add_stat_buff("attack_pct", 0.15)
	run_state.add_stat_buff("attack_pct", 0.15)
	assert_float(run_state.get_stat_buff("attack_pct")).is_equal(0.30)
	run_state.add_stat_buff("attack_pct", 0.15)
	assert_float(run_state.get_stat_buff("attack_pct")).is_equal(GameConstantsRes.MAX_CARD_STACK)


func test_card_effect_applier_applies_stat_from_registry() -> void:
	RunManager.run_state = RunState.new()
	RunManager.run_state.init_from_seed(99)
	assert_bool(CardEffectApplierRes.apply("stat_def_red", 2)).is_true()
	assert_float(RunManager.run_state.get_stat_buff("defense_pct")).is_equal(0.15)
	assert_int(RunManager.run_state.card_picks_count).is_equal(1)


func test_red_clan_filter_excludes_non_red_preferred_soil() -> void:
	var species := SpeciesDef.new()
	species.preferred_soil = SoilTypeRes.Type.SAND
	assert_bool(RunState.new().is_red_clan_species(species)).is_false()
	species.preferred_soil = SoilTypeRes.Type.RED
	assert_bool(RunState.new().is_red_clan_species(species)).is_true()


func test_stat_buffs_reset_on_new_run() -> void:
	var run_state := RunState.new()
	run_state.init_from_seed(1)
	run_state.add_stat_buff("attack_pct", 0.20)
	run_state.init_from_seed(2)
	assert_float(run_state.get_stat_buff("attack_pct")).is_equal(0.0)
	assert_int(run_state.card_picks_count).is_equal(0)


func test_sin_risk_cards_not_loaded() -> void:
	assert_object(ContentRegistry.get_card("sin_card")).is_null()
