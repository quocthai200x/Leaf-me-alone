extends Node
## Events emitted: STATE_CHANGED (via EventBus)
## Events listened: none

const GridDataRes := preload("res://scripts/data/grid_data.gd")

var _state: int = RunStateEnum.State.MainMenu
var run_state: RunState = RunState.new()
var grid_data: GridDataRes


func get_state() -> int:
	return _state


func start_run(seed_value: int) -> GridDataRes:
	run_state.init_from_seed(seed_value)
	grid_data = GridDataRes.new()
	grid_data.generate_from_seed(run_state.master_seed)
	return grid_data


func can_transition_to(_to_state: int) -> bool:
	return true


func transition_to(new_state: int) -> void:
	if not can_transition_to(new_state):
		push_warning("Blocked transition: %s -> %s" % [_state, new_state])
		return
	var old_state := _state
	_state = new_state
	EventBus.emit_run_event(
		RunEvent.Type.STATE_CHANGED,
		{"from": old_state, "to": new_state}
	)


func reset() -> void:
	if _state != RunStateEnum.State.MainMenu and _state != RunStateEnum.State.RunEnd:
		push_warning("RunManager.reset() is only callable from MainMenu or RunEnd")
		return
	var old_state := _state
	run_state = RunState.new()
	_state = RunStateEnum.State.MainMenu
	EventBus.emit_run_event(
		RunEvent.Type.STATE_CHANGED,
		{"from": old_state, "to": _state}
	)
