extends GdUnitTestSuite
## Card Pick overlay and CardPickPhase integration (Story 6.1).

const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const CardSystemRes := preload("res://scripts/systems/card_system.gd")
const CardPickOverlayScene := preload("res://scenes/run/card_pick_overlay.tscn")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func test_wave_two_expires_into_card_pick_phase() -> void:
	RunManager.start_run(4242)
	assert_bool(RunManager.begin_combat_wave()).is_true()
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)
	assert_bool(RunManager.begin_combat_wave()).is_true()
	assert_int(RunManager.run_state.wave_index).is_equal(2)
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CardPickPhase)


func test_wave_one_expires_into_pause_not_card_pick() -> void:
	RunManager.start_run(1001)
	RunManager.begin_combat_wave()
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)


func test_card_system_returns_three_options() -> void:
	var options := CardSystemRes.build_options_for_wave(2, 999)
	assert_int(options.size()).is_equal(3)
	for option in options:
		var data: Dictionary = option
		assert_bool(data.has("id")).is_true()
		assert_bool(data.has("type")).is_true()
		assert_bool(data.has("accent_color")).is_true()


func test_card_pick_overlay_commit_transitions_to_pause() -> void:
	var overlay: Control = CardPickOverlayScene.instantiate()
	add_child(overlay)
	await get_tree().process_frame
	RunManager.start_run(777)
	assert_bool(RunManager.begin_combat_wave()).is_true()
	RunManager.on_combat_timer_expired()
	assert_bool(RunManager.begin_combat_wave()).is_true()
	RunManager.on_combat_timer_expired()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.CardPickPhase)

	var options := CardSystemRes.build_options_for_wave(2, 777)
	overlay.show_pick(2, options)
	await get_tree().process_frame

	var picked_state := {"picked": false}
	var handler := func(event: int, _payload: Variant) -> void:
		if event == RunEventRes.Type.CARD_PICKED:
			picked_state.picked = true
	EventBus.run_event.connect(handler)

	var cards_row: HBoxContainer = overlay.get_node("%CardsRow")
	assert_int(cards_row.get_child_count()).is_equal(3)
	var first_wrapper := cards_row.get_child(0) as MarginContainer
	var first_card := first_wrapper.get_child(0) as PanelContainer
	overlay._commit_pick(options[0], first_card)
	await get_tree().create_timer(0.2).timeout

	assert_bool(picked_state.picked).is_true()
	assert_int(RunManager.get_state()).is_equal(RunStateEnumRes.State.PausePhase)
	EventBus.run_event.disconnect(handler)
	overlay.queue_free()
