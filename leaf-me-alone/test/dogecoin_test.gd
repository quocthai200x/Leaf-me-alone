extends GdUnitTestSuite
## Dogecoin earn on ape defeat and wallet invariants (Story 4.6).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const DogecoinFloatLogicRes := preload("res://scripts/systems/dogecoin_float_logic.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const ApeBaseScene := preload("res://scenes/entities/ape_base.tscn")
const ApePoolScript := preload("res://scripts/systems/ape_pool.gd")
const CombatHudScene := preload("res://scenes/run/combat_hud.tscn")
const MapViewScene := preload("res://scenes/run/map_view.tscn")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_role_weighted_drops_for_all_slice_apes() -> void:
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("saw_ape")).is_equal(5)
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("hr_ape")).is_equal(15)
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("pr_ape")).is_equal(12)


func test_wallet_never_negative_across_earn_spend_loop() -> void:
	var economy := EconomySystemScript.new()
	add_child(economy)
	RunManager.start_run(6601)
	assert_bool(economy.try_earn(30)).is_true()
	assert_bool(economy.try_spend(12)).is_true()
	assert_bool(economy.try_spend(25)).is_false()
	assert_int(economy.get_balance()).is_equal(18)
	assert_bool(economy.try_earn(7)).is_true()
	assert_int(economy.get_balance()).is_equal(25)
	economy.queue_free()


func test_ape_kill_only_awards_dogecoin_in_combat_phase() -> void:
	var economy := EconomySystemScript.new()
	add_child(economy)
	RunManager.start_run(6602)
	assert_int(economy.get_balance()).is_equal(0)

	EventBus.emit_run_event(
		RunEventRes.Type.APE_KILLED,
		{"ape_id": "saw_ape", "drop_amount": 5, "cell": Vector2i(1, 1), "wave": 1}
	)
	await get_tree().process_frame
	assert_int(economy.get_balance()).is_equal(0)

	RunManager.begin_combat_wave()
	EventBus.emit_run_event(
		RunEventRes.Type.APE_KILLED,
		{"ape_id": "saw_ape", "drop_amount": 5, "cell": Vector2i(1, 1), "wave": 1}
	)
	await get_tree().process_frame
	assert_int(economy.get_balance()).is_equal(5)
	economy.queue_free()


func test_combat_hud_refreshes_on_dogecoin_changed() -> void:
	var hud: Control = CombatHudScene.instantiate()
	add_child(hud)
	await get_tree().process_frame

	var economy := EconomySystemScript.new()
	add_child(economy)
	RunManager.start_run(6603)
	RunManager.begin_combat_wave()

	economy.try_earn(9)
	await get_tree().process_frame
	var value_label: Label = hud.get_node("%DogecoinValue")
	assert_str(value_label.text).is_equal("9")

	hud.queue_free()
	economy.queue_free()


func test_dogecoin_float_popup_format() -> void:
	assert_str(DogecoinFloatLogicRes.format_earn_popup(5)).is_equal("+5Ð")


func test_kill_via_ape_pool_updates_wallet_in_combat() -> void:
	var map_view: Node2D = MapViewScene.instantiate()
	add_child(map_view)
	await get_tree().process_frame

	var economy := EconomySystemScript.new()
	add_child(economy)
	var ape_pool: Node = ApePoolScript.new()
	add_child(ape_pool)
	await get_tree().process_frame

	RunManager.start_run(6604)
	RunManager.begin_combat_wave()

	var ape: Node2D = ApeBaseScene.instantiate()
	map_view.get_node("Entities").add_child(ape)
	ape.configure(ContentRegistry.get_ape("hr_ape"), Vector2i(2, 2), 1.0, 1.0)
	ape.visible = true
	ape.state = ape.State.ACT

	ape_pool.kill_ape(ape)
	await get_tree().process_frame
	assert_int(economy.get_balance()).is_equal(15)

	ape_pool.queue_free()
	economy.queue_free()
	map_view.queue_free()
