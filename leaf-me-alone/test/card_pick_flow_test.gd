extends GdUnitTestSuite
## CardPickPhase state integration — Combat → CardPick → Pause loop (Story 6.4).

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const CardEffectApplierRes := preload("res://scripts/systems/card_effect_applier.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func test_wave_one_combat_end_skips_card_pick() -> void:
	RunManager.start_run(1001)
	RunManager.begin_combat_wave()
	assert_int(RunManager.run_state.wave_index).is_equal(1)
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)


func test_wave_two_combat_end_requires_card_pick() -> void:
	RunManager.start_run(2002)
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	RunManager.begin_combat_wave()
	assert_int(RunManager.run_state.wave_index).is_equal(2)
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CardPickPhase)


func test_combat_cannot_skip_card_pick_to_pause_on_wave_two() -> void:
	RunManager.start_run(3003)
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	RunManager.begin_combat_wave()
	RunManager.transition_to(RunStateEnumRes.State.PausePhase)
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CombatPhase)


func test_card_pick_completes_to_pause_not_combat() -> void:
	RunManager.start_run(4004)
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CardPickPhase)
	CardEffectApplierRes.apply("stat_atk_red", 2)
	assert_bool(RunManager.complete_card_pick()).is_true()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)
	assert_int(RunManager.get_previous_state()).is_equal(RunStateEnumRes.State.CardPickPhase)


func test_card_pick_cannot_transition_directly_to_combat() -> void:
	RunManager.start_run(5005)
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	RunManager.transition_to(RunStateEnumRes.State.CombatPhase)
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CardPickPhase)


func test_full_loop_waves_one_through_four_with_card_picks() -> void:
	RunManager.start_run(6006)
	var expected_after_combat := [
		RunStateEnumRes.State.PausePhase,
		RunStateEnumRes.State.CardPickPhase,
		RunStateEnumRes.State.PausePhase,
		RunStateEnumRes.State.CardPickPhase,
	]
	for wave in range(1, 5):
		assert_bool(RunManager.begin_combat_wave()).is_true()
		assert_int(RunManager.run_state.wave_index).is_equal(wave)
		assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CombatPhase)
		RunManager.on_combat_timer_expired()
		var expected: int = expected_after_combat[wave - 1]
		assert_int(RunManager.get_state()).is_equal(expected)
		if expected == RunStateEnumRes.State.CardPickPhase:
			CardEffectApplierRes.apply("stat_def_red", wave)
			assert_bool(RunManager.complete_card_pick()).is_true()
			assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)
