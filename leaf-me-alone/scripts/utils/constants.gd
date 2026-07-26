class_name GameConstants
extends RefCounted

# Wave durations in seconds (5/6/7/8/10 minutes per FR3)
const WAVE_DURATIONS_SEC: Array[float] = [300.0, 360.0, 420.0, 480.0, 600.0]
const DEBUG_WAVE_DURATIONS_SEC: Array[float] = [3.0, 3.6, 4.2, 4.8, 6.0]

const MAX_COMBAT_WAVES := 5

# Dissatisfaction tease (Story 2.9) — flee logic deferred to Epic 3
const DISSATISFACTION_TEASE_THRESHOLD := 50
const DISSATISFACTION_METER_THRESHOLD := 50

# Dissatisfaction accumulation (Story 3.1)
const DISSATISFACTION_MISSED_CARE_PER_CAUSE := 25
const DISSATISFACTION_SOIL_MISMATCH_DELTA := 10
const DISSATISFACTION_ALLELOPATHY_DELTA := 10
const DISSATISFACTION_WEATHER_MISMATCH_DELTA := 10
const DISSATISFACTION_COMBAT_TICK_SEC := 30.0
const DEBUG_DISSATISFACTION_COMBAT_TICK_SEC := 1.0

# Flee thresholds (Story 3.3)
const STANDARD_FLEE_THRESHOLD := 100
const SENSITIVE_FLEE_THRESHOLD := 75
const HR_FLEE_THRESHOLD := 50
const HR_MODIFIER_DEFAULT_RADIUS_TILES := 3

# DESIGN.md dissatisfaction token #FF8C42 (UX-DR18)
const DISSATISFACTION_COLOR := Color(1.0, 0.54902, 0.258824, 0.95)

const DEFAULT_RUN_WEATHER := "tropical_sun"
const WEATHER_OPTIONS: Array[String] = ["tropical_sun", "tropical_rain"]


static func get_wave_duration_sec(wave_number: int) -> float:
	var idx := clampi(wave_number - 1, 0, WAVE_DURATIONS_SEC.size() - 1)
	if OS.is_debug_build():
		return DEBUG_WAVE_DURATIONS_SEC[idx]
	return WAVE_DURATIONS_SEC[idx]


static func get_dissatisfaction_combat_tick_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_DISSATISFACTION_COMBAT_TICK_SEC
	return DISSATISFACTION_COMBAT_TICK_SEC
