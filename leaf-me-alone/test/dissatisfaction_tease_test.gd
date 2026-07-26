extends GdUnitTestSuite
## Dissatisfaction tease indicators (Story 2.9).

const DissatisfactionIndicatorSystemRes := preload(
	"res://scripts/systems/dissatisfaction_indicator_system.gd"
)
const GameConstantsRes := preload("res://scripts/utils/constants.gd")


func test_no_tease_below_threshold() -> void:
	var state := DissatisfactionIndicatorSystemRes.get_tease_state(49)
	assert_bool(state["show_emoji"]).is_false()
	assert_bool(state["show_meter"]).is_false()


func test_emoji_at_tease_threshold() -> void:
	var state := DissatisfactionIndicatorSystemRes.get_tease_state(50)
	assert_bool(state["show_emoji"]).is_true()
	assert_bool(state["show_meter"]).is_false()


func test_emoji_and_meter_above_fifty() -> void:
	var state := DissatisfactionIndicatorSystemRes.get_tease_state(75)
	assert_bool(state["show_emoji"]).is_true()
	assert_bool(state["show_meter"]).is_true()
	assert_float(state["meter_fill"]).is_equal(0.75)


func test_should_show_tease_matches_threshold() -> void:
	assert_bool(
		DissatisfactionIndicatorSystemRes.should_show_tease(
			GameConstantsRes.DISSATISFACTION_TEASE_THRESHOLD
		)
	).is_true()
	assert_bool(DissatisfactionIndicatorSystemRes.should_show_tease(49)).is_false()
