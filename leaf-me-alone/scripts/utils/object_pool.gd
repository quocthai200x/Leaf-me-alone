class_name ObjectPool
extends RefCounted
## Generic pre-warmed object pool — acquire/release with active count tracking.

var _factory: Callable
var _reset_fn: Callable
var _capacity: int = 0
var _available: Array = []
var _active: Array = []


func _init(factory: Callable, capacity: int, reset_fn: Callable = Callable()) -> void:
	_factory = factory
	_capacity = maxi(capacity, 0)
	_reset_fn = reset_fn
	prewarm()


func prewarm() -> void:
	while _total_count() < _capacity:
		_available.append(_factory.call())


func acquire() -> Variant:
	if _available.is_empty():
		return null
	var item: Variant = _available.pop_back()
	_active.append(item)
	return item


func release(item: Variant) -> void:
	if not _active.has(item):
		return
	_active.erase(item)
	if _reset_fn.is_valid():
		_reset_fn.call(item)
	_available.append(item)


func get_active_count() -> int:
	return _active.size()


func get_active_items() -> Array:
	return _active.duplicate()


func get_available_count() -> int:
	return _available.size()


func get_capacity() -> int:
	return _capacity


func _total_count() -> int:
	return _available.size() + _active.size()
