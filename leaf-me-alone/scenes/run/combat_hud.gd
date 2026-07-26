extends Control
## Greybox combat HUD shell — wave timer top-center.


func update_wave_timer(wave_index: int, remaining_sec: float, max_waves: int) -> void:
	var minutes := int(maxf(remaining_sec, 0.0)) / 60
	var seconds := int(maxf(remaining_sec, 0.0)) % 60
	%WaveTimerLabel.text = tr("Wave %d/%d — %d:%02d") % [
		wave_index,
		max_waves,
		minutes,
		seconds,
	]
