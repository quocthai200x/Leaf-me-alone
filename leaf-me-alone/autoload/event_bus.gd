extends Node

signal run_event(event: int, payload: Variant)


func emit_run_event(event: int, payload: Variant = null) -> void:
	run_event.emit(event, payload)
