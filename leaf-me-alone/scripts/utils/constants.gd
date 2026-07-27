class_name GameConstants
extends RefCounted

# Wave durations in seconds (5/6/7/8/10 minutes per FR3)
const WAVE_DURATIONS_SEC: Array[float] = [300.0, 360.0, 420.0, 480.0, 600.0]
const DEBUG_WAVE_DURATIONS_SEC: Array[float] = [3.0, 3.6, 4.2, 4.8, 6.0]

const MAX_COMBAT_WAVES := 5

# Wave spawn pacing (Story 4.2)
const WAVE_HP_MULTIPLIERS: Array[float] = [1.0, 1.2, 1.4, 1.6, 2.0]
const APE_SPAWN_INTERVAL_SEC := 15.0
const APE_BURST_INTERVAL_SEC := 60.0
const DEBUG_APE_SPAWN_INTERVAL_SEC := 1.5
const DEBUG_APE_BURST_INTERVAL_SEC := 6.0

# Ape pooling & display (Story 4.1)
const APE_POOL_SIZE := 35
const APE_TILE_SIZE := 16
const APE_DISPLAY_SCALE := 3.0

# Saw extraction (Story 4.3)
const SAW_EXTRACT_DAMAGE := 15
const SAW_EXTRACT_INTERVAL_SEC := 2.0
const DEBUG_SAW_EXTRACT_INTERVAL_SEC := 0.25
const APE_DOGECOIN_DROPS: Dictionary = {
	"saw_ape": 5,
	"hr_ape": 15,
	"pr_ape": 12,
}

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
const HR_STING_COOLDOWN_SEC := 5.0

# PR billboards (Story 4.5)
const PR_BILLBOARD_RADIUS_TILES := 3
const PR_BILLBOARD_DISSATISFACTION_DELTA := 10

# Structure HP stubs (Story 4.7) — damage deferred to Epic 5
const FOREST_CORE_MAX_HP := 500
const ROOT_NEST_MAX_HP := 200
const STRUCTURE_DANGER_HP_RATIO := 0.25
const WAVE_BANNER_DURATION_SEC := 3.0
const SLICE_WAVES_PATH := "res://data/waves/slice_waves.json"

# Flee sequence timing (Story 3.4)
const FLEE_ANGRY_PHASE_SEC := 0.35
const FLEE_RUN_PHASE_SEC := 0.45
const DEBUG_FLEE_ANGRY_PHASE_SEC := 0.05
const DEBUG_FLEE_RUN_PHASE_SEC := 0.05
const FLEE_WHOOSH_BUS := &"SFX"
const COMBAT_AUDIO_BUS := &"Combat"
const STINGS_AUDIO_BUS := &"Stings"

# Mass flee feedback (Story 3.7)
const MASS_FLEE_MIN_COUNT := 2
const FLEE_VIGNETTE_DURATION_SEC := 0.2
const RESIGNATION_TOAST_DURATION_SEC := 2.5
const FLEE_COLOR := Color(1.0, 0.278431, 0.341176, 1.0)

# DESIGN.md dissatisfaction token #FF8C42 (UX-DR18)
const DISSATISFACTION_COLOR := Color(1.0, 0.54902, 0.258824, 0.95)

const DEFAULT_RUN_WEATHER := "tropical_sun"
const WEATHER_OPTIONS: Array[String] = ["tropical_sun", "tropical_rain"]


static func grid_cell_to_local(cell: Vector2i) -> Vector2:
	var tile_px := float(APE_TILE_SIZE) * APE_DISPLAY_SCALE
	return Vector2((cell.x + 0.5) * tile_px, (cell.y + 0.5) * tile_px)


static func get_wave_duration_sec(wave_number: int) -> float:
	var idx := clampi(wave_number - 1, 0, WAVE_DURATIONS_SEC.size() - 1)
	if OS.is_debug_build():
		return DEBUG_WAVE_DURATIONS_SEC[idx]
	return WAVE_DURATIONS_SEC[idx]


static func get_dissatisfaction_combat_tick_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_DISSATISFACTION_COMBAT_TICK_SEC
	return DISSATISFACTION_COMBAT_TICK_SEC


static func get_flee_angry_phase_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_FLEE_ANGRY_PHASE_SEC
	return FLEE_ANGRY_PHASE_SEC


static func get_flee_run_phase_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_FLEE_RUN_PHASE_SEC
	return FLEE_RUN_PHASE_SEC


static func get_ape_spawn_interval_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_APE_SPAWN_INTERVAL_SEC
	return APE_SPAWN_INTERVAL_SEC


static func get_ape_burst_interval_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_APE_BURST_INTERVAL_SEC
	return APE_BURST_INTERVAL_SEC


static func get_wave_hp_multiplier(wave_number: int) -> float:
	var idx := clampi(wave_number - 1, 0, WAVE_HP_MULTIPLIERS.size() - 1)
	return WAVE_HP_MULTIPLIERS[idx]


static func get_saw_extract_interval_sec() -> float:
	if OS.is_debug_build():
		return DEBUG_SAW_EXTRACT_INTERVAL_SEC
	return SAW_EXTRACT_INTERVAL_SEC


static func get_ape_dogecoin_drop(ape_id: String) -> int:
	return int(APE_DOGECOIN_DROPS.get(ape_id, 0))
