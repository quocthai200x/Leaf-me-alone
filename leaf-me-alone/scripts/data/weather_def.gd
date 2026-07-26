class_name WeatherDef
extends RefCounted

const DISPLAY_NAMES := {
	"tropical_sun": "Tropical Sun",
	"tropical_rain": "Tropical Rain",
}


static func get_display_name(weather_id: String) -> String:
	return DISPLAY_NAMES.get(weather_id, weather_id.capitalize())


static func format_pause_readout(current_weather: String) -> String:
	return "Now: %s\nForecast: holds for this run" % get_display_name(current_weather)
