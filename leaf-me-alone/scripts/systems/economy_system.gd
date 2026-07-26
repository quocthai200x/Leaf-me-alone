extends Node
## Run-scoped Dogecoin wallet — sole mutator of RunManager.run_state.dogecoin.
## Events emitted: DOGECOIN_CHANGED (via EventBus)
## Events listened: STATE_CHANGED (reset guard on new run)

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")


func _ready() -> void:
	add_to_group("economy_system")
	EventBus.run_event.connect(_on_run_event)
	_ensure_run_wallet_initialized()


func get_balance() -> int:
	return RunManager.run_state.dogecoin


func can_afford(amount: int) -> bool:
	return amount > 0 and get_balance() >= amount


func try_spend(amount: int) -> bool:
	if amount <= 0:
		push_warning("[EconomySystem] try_spend rejected non-positive amount: %d" % amount)
		return false
	var balance := get_balance()
	if balance < amount:
		return false
	return _apply_delta(-amount)


func try_earn(amount: int) -> bool:
	if amount <= 0:
		push_warning("[EconomySystem] try_earn rejected non-positive amount: %d" % amount)
		return false
	return _apply_delta(amount)


func _apply_delta(delta: int) -> bool:
	var before := get_balance()
	var after := before + delta
	if after < 0:
		return false
	RunManager.run_state.dogecoin = after
	EventBus.emit_run_event(
		RunEventRes.Type.DOGECOIN_CHANGED,
		{"balance": after, "delta": delta, "previous": before}
	)
	return true


func _ensure_run_wallet_initialized() -> void:
	if RunManager.get_state() in [
		RunStateEnumRes.State.PausePhase,
		RunStateEnumRes.State.CombatPhase,
		RunStateEnumRes.State.CardPickPhase,
	]:
		# Run already started before RunRoot loaded; wallet reset happens in start_run.
		return
	if get_balance() != 0:
		push_warning("[EconomySystem] Expected wallet 0 at run entry, got %d" % get_balance())


func _on_run_event(event: int, payload: Variant) -> void:
	if event != RunEventRes.Type.STATE_CHANGED:
		return
	var data: Dictionary = payload
	if int(data.get("to", -1)) != RunStateEnumRes.State.RunStart:
		return
	# New run transition — wallet must be zero (set by RunManager.start_run).
	if get_balance() != 0:
		push_error("[EconomySystem] Wallet not zero at RunStart: %d" % get_balance())
