extends GdUnitTestSuite
## Weather stub tests (Story 3.6).

const WeatherDefRes := preload("res://scripts/data/weather_def.gd")
const DissatisfactionCauseLogicRes := preload(
	"res://scripts/systems/dissatisfaction_cause_logic.gd"
)
const GameConstantsRes := preload("res://scripts/utils/constants.gd")


func before_test() -> void:
	RunManager.enter_main_menu()
	ContentRegistry.load_all()


func after_test() -> void:
	RunManager.enter_main_menu()


func test_run_start_assigns_weather_from_seed() -> void:
	RunManager.start_run(100)
	var weather := RunManager.run_state.current_weather
	assert_bool(weather == "tropical_sun" or weather == "tropical_rain").is_true()


func test_weather_display_name_for_known_types() -> void:
	assert_str(WeatherDefRes.get_display_name("tropical_sun")).is_equal("Tropical Sun")
	assert_str(WeatherDefRes.get_display_name("tropical_rain")).is_equal("Tropical Rain")


func test_pause_readout_includes_current_and_forecast() -> void:
	var text := WeatherDefRes.format_pause_readout("tropical_sun")
	assert_str(text).contains("Tropical Sun")
	assert_str(text).contains("Forecast")


func test_cashew_mismatches_tropical_sun_weather() -> void:
	var cashew := ContentRegistry.get_species("cashew")
	assert_bool(
		DissatisfactionCauseLogicRes.has_weather_mismatch(cashew, "tropical_sun")
	).is_true()
	assert_bool(
		DissatisfactionCauseLogicRes.has_weather_mismatch(cashew, "tropical_rain")
	).is_false()
