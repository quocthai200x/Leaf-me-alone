extends GdUnitTestSuite
## Unit tests for EconomySystem wallet (Story 2.2).

const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")

var _economy: EconomySystemScript


func before_test() -> void:
	RunManager.enter_main_menu()
	_economy = EconomySystemScript.new()
	add_child(_economy)
	await get_tree().process_frame


func after_test() -> void:
	if is_instance_valid(_economy):
		_economy.queue_free()
	RunManager.enter_main_menu()


func test_new_run_wallet_starts_at_zero() -> void:
	RunManager.start_run(12345)
	assert_int(_economy.get_balance()).is_equal(0)


func test_try_spend_deducts_atomically() -> void:
	RunManager.start_run(99)
	assert_bool(_economy.try_earn(20)).is_true()
	assert_bool(_economy.try_spend(8)).is_true()
	assert_int(_economy.get_balance()).is_equal(12)


func test_try_spend_blocks_insufficient_and_negative_balance() -> void:
	RunManager.start_run(99)
	assert_bool(_economy.try_earn(5)).is_true()
	assert_bool(_economy.try_spend(8)).is_false()
	assert_int(_economy.get_balance()).is_equal(5)
	assert_bool(_economy.try_spend(0)).is_false()
	assert_bool(_economy.try_spend(-1)).is_false()
	assert_int(_economy.get_balance()).is_equal(5)


func test_dogecoin_changed_event_on_spend() -> void:
	RunManager.start_run(42)
	_economy.try_earn(10)
	var capture := {"seen": false}
	var handler := func(event: int, payload: Variant) -> void:
		if event == RunEventRes.Type.DOGECOIN_CHANGED:
			var data: Dictionary = payload
			if int(data.get("balance", -1)) == 7 and int(data.get("delta", 0)) == -3:
				capture["seen"] = true
	EventBus.run_event.connect(handler)
	assert_bool(_economy.try_spend(3)).is_true()
	await get_tree().process_frame
	EventBus.run_event.disconnect(handler)
	assert_bool(capture["seen"]).is_true()
