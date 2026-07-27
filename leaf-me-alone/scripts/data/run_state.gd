class_name RunState
extends Resource

@export var master_seed: int = 0
@export var dogecoin: int = 0
@export var wave_index: int = 0
@export var current_weather: String = "tropical_sun"
@export var run_outcome: String = ""
@export var loss_reason: String = ""
@export var director_defeated: bool = false

var map_rng: RandomNumberGenerator


func init_from_seed(seed_value: int) -> void:
	master_seed = seed_value
	dogecoin = 0
	wave_index = 0
	current_weather = "tropical_sun"
	run_outcome = ""
	loss_reason = ""
	director_defeated = false
	map_rng = RandomNumberGenerator.new()
	map_rng.seed = master_seed
