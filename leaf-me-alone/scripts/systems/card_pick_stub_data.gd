class_name CardPickStubData
extends RefCounted
## Greybox card options for Story 6.1 UI — replaced by ContentRegistry + CardSystem in 6.2+.

const STAT_ACCENT := Color("#74B9FF")
const SOIL_ACCENT := Color("#A29BFE")

const _STAT_POOL: Array[Dictionary] = [
	{
		"id": "stat_atk_red",
		"type": "stat",
		"title": "Red Fury",
		"summary": "+15% ATK for Red clan plants this run.",
		"hover_detail": "Stacks with other stat cards up to +40% (Story 6.2).",
	},
	{
		"id": "stat_def_red",
		"type": "stat",
		"title": "Red Bark",
		"summary": "+15% DEF for Red clan plants this run.",
		"hover_detail": "Same-clan buff only — peanut, cashew, teak on Red soil.",
	},
	{
		"id": "stat_grow_red",
		"type": "stat",
		"title": "Red Growth",
		"summary": "+12% grow speed for Red clan plants this run.",
		"hover_detail": "Care actions still apply; this buffs growth tick rate.",
	},
	{
		"id": "stat_resist_red",
		"type": "stat",
		"title": "Red Calm",
		"summary": "+10% dissatisfaction resist for Red clan plants.",
		"hover_detail": "Helps hold the line when HR Apes pressure morale.",
	},
]

const _SOIL_POOL: Array[Dictionary] = [
	{
		"id": "soil_terraform_red",
		"type": "soil",
		"title": "Red Soil Patch",
		"summary": "Terraform one tile to Red soil for this run.",
		"hover_detail": "Single tile targeting in Story 6.3.",
	},
	{
		"id": "soil_terraform_fertile",
		"type": "soil",
		"title": "Fertile Patch",
		"summary": "Terraform one tile to fertile soil for this run.",
		"hover_detail": "Placeholder soil type for greybox pick UI.",
	},
]


static func build_options_for_wave(wave_index: int, master_seed: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%d:%d:card_pick" % [master_seed, wave_index])
	var options: Array = []
	var stat_indices := _pick_distinct_indices(rng, _STAT_POOL.size(), 2)
	for idx in stat_indices:
		options.append(_STAT_POOL[idx].duplicate(true))
	var soil_idx := rng.randi_range(0, _SOIL_POOL.size() - 1)
	options.append(_SOIL_POOL[soil_idx].duplicate(true))
	options.shuffle()
	rng.seed = hash("%d:%d:order" % [master_seed, wave_index])
	for i in range(options.size()):
		var j := rng.randi_range(i, options.size() - 1)
		var tmp = options[i]
		options[i] = options[j]
		options[j] = tmp
	for option in options:
		option["accent_color"] = STAT_ACCENT if option.get("type") == "stat" else SOIL_ACCENT
	return options


static func _pick_distinct_indices(rng: RandomNumberGenerator, pool_size: int, count: int) -> Array:
	var indices: Array = []
	while indices.size() < mini(count, pool_size):
		var idx := rng.randi_range(0, pool_size - 1)
		if idx not in indices:
			indices.append(idx)
	return indices
