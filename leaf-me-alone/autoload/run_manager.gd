extends Node
## Events emitted: STATE_CHANGED (via EventBus)
## Events listened: none

const GridDataRes := preload("res://scripts/data/grid_data.gd")
const GameConstantsRes := preload("res://scripts/utils/constants.gd")

var _state: int = RunStateEnum.State.MainMenu
var run_state: RunState = RunState.new()
var grid_data: GridDataRes


func get_state() -> int:
	return _state


func get_current_wave_duration() -> float:
	if run_state.wave_index <= 0:
		return 0.0
	return GameConstantsRes.get_wave_duration_sec(run_state.wave_index)


func start_run(seed_value: int) -> GridDataRes:
	if not can_transition_to(RunStateEnum.State.RunStart):
		push_warning("RunManager.start_run blocked from state %s" % _state)
		return null
	transition_to(RunStateEnum.State.RunStart)
	run_state.init_from_seed(seed_value)
	_assign_run_weather(seed_value)
	grid_data = GridDataRes.new()
	grid_data.generate_from_seed(run_state.master_seed)
	grid_data.place_structures_from_seed(run_state.master_seed)
	EventBus.emit_run_event(
		RunEvent.Type.STRUCTURES_PLACED,
		{
			"core_cell": grid_data.get_forest_core_cell(),
			"nest_cells": grid_data.get_root_nest_cells(),
			"structure_count": grid_data.get_structures().size(),
		}
	)
	run_state.wave_index = 0
	transition_to(RunStateEnum.State.PausePhase)
	return grid_data


func begin_combat_wave() -> bool:
	if not can_transition_to(RunStateEnum.State.CombatPhase):
		push_warning("RunManager.begin_combat_wave blocked from state %s" % _state)
		return false
	if run_state.wave_index >= GameConstantsRes.MAX_COMBAT_WAVES:
		push_warning("RunManager.begin_combat_wave: all %d combat waves complete" % GameConstantsRes.MAX_COMBAT_WAVES)
		return false
	run_state.wave_index += 1
	transition_to(RunStateEnum.State.CombatPhase)
	print("[RunManager] Combat wave %d started" % run_state.wave_index)
	return true


func on_combat_timer_expired() -> void:
	if _state != RunStateEnum.State.CombatPhase:
		push_warning("RunManager.on_combat_timer_expired ignored — not in CombatPhase")
		return
	print("[RunManager] Combat wave %d timer expired" % run_state.wave_index)
	if run_state.wave_index >= GameConstantsRes.MAX_COMBAT_WAVES:
		if run_state.director_defeated:
			declare_run_win()
		else:
			declare_run_loss("director_survived")
	elif run_state.wave_index == 2 or run_state.wave_index == 4:
		transition_to(RunStateEnum.State.CardPickPhase)
	else:
		transition_to(RunStateEnum.State.PausePhase)


func declare_run_loss(reason: String) -> void:
	if _state != RunStateEnum.State.CombatPhase:
		return
	if not can_transition_to(RunStateEnum.State.RunEnd):
		return
	run_state.run_outcome = "loss"
	run_state.loss_reason = reason
	EventBus.emit_run_event(
		RunEvent.Type.RUN_LOST,
		{
			"reason": reason,
			"wave_index": run_state.wave_index,
			"waves_cleared": maxi(run_state.wave_index - 1, 0),
			"seed": run_state.master_seed,
		}
	)
	transition_to(RunStateEnum.State.RunEnd)


func declare_run_win() -> void:
	if _state != RunStateEnum.State.CombatPhase:
		return
	if not can_transition_to(RunStateEnum.State.RunEnd):
		return
	run_state.run_outcome = "win"
	run_state.loss_reason = ""
	EventBus.emit_run_event(
		RunEvent.Type.RUN_WON,
		{
			"wave_index": run_state.wave_index,
			"waves_cleared": run_state.wave_index,
			"seed": run_state.master_seed,
		}
	)
	transition_to(RunStateEnum.State.RunEnd)


func try_declare_run_win() -> void:
	if run_state.wave_index != GameConstantsRes.MAX_COMBAT_WAVES:
		return
	if not run_state.director_defeated:
		return
	declare_run_win()


func complete_card_pick() -> bool:
	if not can_transition_to(RunStateEnum.State.PausePhase):
		return false
	transition_to(RunStateEnum.State.PausePhase)
	return true


func can_transition_to(to_state: int) -> bool:
	match [_state, to_state]:
		[RunStateEnum.State.MainMenu, RunStateEnum.State.RunStart]:
			return true
		[RunStateEnum.State.RunStart, RunStateEnum.State.PausePhase]:
			return true
		[RunStateEnum.State.PausePhase, RunStateEnum.State.CombatPhase]:
			return run_state.wave_index < GameConstantsRes.MAX_COMBAT_WAVES
		[RunStateEnum.State.CombatPhase, RunStateEnum.State.PausePhase]:
			return true
		[RunStateEnum.State.CombatPhase, RunStateEnum.State.CardPickPhase]:
			return run_state.wave_index == 2 or run_state.wave_index == 4
		[RunStateEnum.State.CombatPhase, RunStateEnum.State.RunEnd]:
			return true
		[RunStateEnum.State.CardPickPhase, RunStateEnum.State.PausePhase]:
			return true
		[RunStateEnum.State.RunEnd, RunStateEnum.State.MainMenu]:
			return true
		_:
			return false


func transition_to(new_state: int) -> void:
	if not can_transition_to(new_state):
		push_warning("Blocked transition: %s -> %s" % [_state, new_state])
		return
	var old_state := _state
	_state = new_state
	print("[RunManager] %s -> %s" % [RunStateEnum.State.keys()[old_state], RunStateEnum.State.keys()[new_state]])
	EventBus.emit_run_event(
		RunEvent.Type.STATE_CHANGED,
		{"from": old_state, "to": new_state}
	)


func reset() -> void:
	if _state != RunStateEnum.State.MainMenu and _state != RunStateEnum.State.RunEnd:
		push_warning("RunManager.reset() is only callable from MainMenu or RunEnd")
		return
	var old_state := _state
	_apply_main_menu_state()
	EventBus.emit_run_event(
		RunEvent.Type.STATE_CHANGED,
		{"from": old_state, "to": _state}
	)


func enter_main_menu() -> void:
	## Force clean MainMenu state when main_menu.tscn loads (e.g. after editor run or hub return).
	var old_state := _state
	_apply_main_menu_state()
	if old_state != _state:
		EventBus.emit_run_event(
			RunEvent.Type.STATE_CHANGED,
			{"from": old_state, "to": _state}
		)


func _apply_main_menu_state() -> void:
	run_state = RunState.new()
	grid_data = null
	_state = RunStateEnum.State.MainMenu


func _assign_run_weather(seed_value: int) -> void:
	var options := GameConstantsRes.WEATHER_OPTIONS
	if options.is_empty():
		run_state.current_weather = GameConstantsRes.DEFAULT_RUN_WEATHER
		return
	var idx := absi(seed_value) % options.size()
	run_state.current_weather = options[idx]
