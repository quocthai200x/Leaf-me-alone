class_name CardSystem
extends RefCounted
## Card pick pool builder — ContentRegistry-backed (Story 6.2).

const STAT_ACCENT := Color("#74B9FF")
const SOIL_ACCENT := Color("#A29BFE")


static func build_options_for_wave(wave_index: int, master_seed: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%d:card_pick" % [master_seed, wave_index])
	var options: Array = []
	var stat_cards := ContentRegistry.get_stat_cards()
	var soil_cards := ContentRegistry.get_soil_cards()
	if stat_cards.is_empty():
		push_error("[CardSystem] No stat cards loaded")
		return options
	var stat_indices := _pick_distinct_indices(rng, stat_cards.size(), mini(2, stat_cards.size()))
	for idx in stat_indices:
		options.append(_card_to_option(stat_cards[idx]))
	if not soil_cards.is_empty():
		var soil_idx := rng.randi_range(0, soil_cards.size() - 1)
		options.append(_card_to_option(soil_cards[soil_idx]))
	rng.seed = hash("%d:%d:order" % [master_seed, wave_index])
	for i in range(options.size()):
		var j := rng.randi_range(i, options.size() - 1)
		var tmp = options[i]
		options[i] = options[j]
		options[j] = tmp
	return options


static func _card_to_option(card) -> Dictionary:
	return {
		"id": card.id,
		"type": card.type,
		"title": card.display_name,
		"summary": card.summary,
		"hover_detail": card.hover_detail,
		"stat_key": card.stat_key,
		"value_pct": card.value_pct,
		"accent_color": STAT_ACCENT if card.type == "stat" else SOIL_ACCENT,
	}


static func _pick_distinct_indices(rng: RandomNumberGenerator, pool_size: int, count: int) -> Array:
	var indices: Array = []
	while indices.size() < mini(count, pool_size):
		var idx := rng.randi_range(0, pool_size - 1)
		if idx not in indices:
			indices.append(idx)
	return indices
