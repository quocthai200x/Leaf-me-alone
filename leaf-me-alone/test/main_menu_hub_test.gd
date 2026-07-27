extends GdUnitTestSuite
## Main Menu hub helpers (Story 7.4).

const MenuHubLogicRes := preload("res://scripts/utils/menu_hub_logic.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	SaveManager.reset_meta_for_tests()


func after_test() -> void:
	RunManager.enter_main_menu()
	SaveManager.reset_meta_for_tests()


func test_format_cc_header() -> void:
	assert_str(MenuHubLogicRes.format_cc_header(0)).is_equal("CC 0")
	assert_str(MenuHubLogicRes.format_cc_header(250)).is_equal("CC 250")


func test_cc_header_reflects_save_manager_balance() -> void:
	SaveManager.set_carbon_credit(180)
	assert_str(MenuHubLogicRes.format_cc_header(SaveManager.get_carbon_credit())).is_equal("CC 180")
