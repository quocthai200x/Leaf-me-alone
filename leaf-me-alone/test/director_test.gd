extends GdUnitTestSuite
## Director spawn and dogecoin drop (Story 5.4).

const RunEventRes := preload("res://scripts/data/run_event.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_director_registered_in_content() -> void:
	assert_bool(ContentRegistry.has_ape("director")).is_true()


func test_director_dogecoin_drop_fifty() -> void:
	assert_int(GameConstantsRes.get_ape_dogecoin_drop("director")).is_equal(50)


func test_director_banner_text() -> void:
	assert_str(GameConstantsRes.DIRECTOR_BANNER_TEXT).contains("Director inbound")
