class_name GameConstants
extends RefCounted

# Wave durations in seconds (5/6/7/8/10 minutes per FR3)
const WAVE_DURATIONS_SEC: Array[float] = [300.0, 360.0, 420.0, 480.0, 600.0]
const DEBUG_WAVE_DURATIONS_SEC: Array[float] = [3.0, 3.6, 4.2, 4.8, 6.0]

const MAX_COMBAT_WAVES := 5


static func get_wave_duration_sec(wave_number: int) -> float:
	var idx := clampi(wave_number - 1, 0, WAVE_DURATIONS_SEC.size() - 1)
	if OS.is_debug_build():
		return DEBUG_WAVE_DURATIONS_SEC[idx]
	return WAVE_DURATIONS_SEC[idx]
