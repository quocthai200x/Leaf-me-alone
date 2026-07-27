class_name RunState
extends Resource

const GameConstantsRes := preload("res://scripts/utils/constants.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")

@export var master_seed: int = 0
@export var dogecoin: int = 0
@export var wave_index: int = 0
@export var current_weather: String = "tropical_sun"
@export var run_outcome: String = ""
@export var loss_reason: String = ""
@export var director_defeated: bool = false
@export var card_picks_count: int = 0
@export var cc_earned_this_run: int = 0

var map_rng: RandomNumberGenerator
var stat_buffs: Dictionary = {}
var pending_soil_card_id: String = ""


func init_from_seed(seed_value: int) -> void:
	master_seed = seed_value
	dogecoin = 0
	wave_index = 0
	current_weather = "tropical_sun"
	run_outcome = ""
	loss_reason = ""
	director_defeated = false
	card_picks_count = 0
	cc_earned_this_run = 0
	pending_soil_card_id = ""
	_reset_stat_buffs()
	map_rng = RandomNumberGenerator.new()
	map_rng.seed = master_seed


func add_stat_buff(stat_key: String, delta_pct: float) -> void:
	if stat_key not in GameConstantsRes.STAT_BUFF_KEYS:
		push_warning("[RunState] Unknown stat buff key: %s" % stat_key)
		return
	var current := get_stat_buff(stat_key)
	stat_buffs[stat_key] = minf(current + delta_pct, GameConstantsRes.MAX_CARD_STACK)


func get_stat_buff(stat_key: String) -> float:
	return float(stat_buffs.get(stat_key, 0.0))


func is_red_clan_species(species: SpeciesDef) -> bool:
	if species == null:
		return false
	return species.preferred_soil == SoilTypeRes.Type.RED


func _reset_stat_buffs() -> void:
	stat_buffs.clear()
	for key in GameConstantsRes.STAT_BUFF_KEYS:
		stat_buffs[key] = 0.0
