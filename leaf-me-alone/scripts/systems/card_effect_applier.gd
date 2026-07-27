class_name CardEffectApplier
extends RefCounted
## Single entry point for card effect application (Story 6.2+).

const RunEventRes := preload("res://scripts/data/run_event.gd")


static func apply(card_id: String, wave_index: int = 0) -> bool:
	if RunManager.run_state.card_picks_count >= 2:
		push_warning("[CardEffectApplier] Max card picks (2) already reached for this run")
		return false
	var card = ContentRegistry.get_card(card_id)
	if card == null:
		push_warning("[CardEffectApplier] Unknown card id: %s" % card_id)
		return false
	if card.type in ["sin", "risk"]:
		push_warning("[CardEffectApplier] Blocked sin/risk card: %s" % card_id)
		return false
	match card.type:
		"stat":
			_apply_stat_card(card)
		"soil":
			push_warning("[CardEffectApplier] Soil cards require tile targeting — use begin_soil_pick")
			return false
		_:
			push_warning("[CardEffectApplier] Unsupported card type: %s" % card.type)
			return false
	RunManager.run_state.card_picks_count += 1
	_emit_card_picked(card_id, card.type, wave_index, true, Vector2i(-1, -1))
	return true


static func begin_soil_pick(card_id: String) -> bool:
	var card = ContentRegistry.get_card(card_id)
	if card == null or card.type != "soil":
		return false
	if card.type in ["sin", "risk"]:
		return false
	RunManager.run_state.pending_soil_card_id = card_id
	return true


static func apply_soil_at_cell(card_id: String, cell: Vector2i, wave_index: int = 0) -> bool:
	if RunManager.run_state.card_picks_count >= 2:
		return false
	var pending := RunManager.run_state.pending_soil_card_id
	if not pending.is_empty() and pending != card_id:
		push_warning("[CardEffectApplier] Soil pick mismatch: pending=%s got=%s" % [pending, card_id])
		return false
	var card = ContentRegistry.get_card(card_id)
	if card == null or card.type != "soil":
		return false
	var grid := RunManager.grid_data
	if grid == null or not grid.terraform_cell(cell, card.target_soil):
		return false
	RunManager.run_state.pending_soil_card_id = ""
	RunManager.run_state.card_picks_count += 1
	_emit_card_picked(card_id, "soil", wave_index, true, cell)
	return true


static func cancel_pending_soil_pick() -> void:
	RunManager.run_state.pending_soil_card_id = ""


static func _apply_stat_card(card) -> void:
	if card.clan != "red":
		push_warning("[CardEffectApplier] Non-red clan stat cards not in MVP slice")
		return
	RunManager.run_state.add_stat_buff(card.stat_key, card.value_pct)


static func _emit_card_picked(
	card_id: String,
	card_type: String,
	wave_index: int,
	applied: bool,
	cell: Vector2i
) -> void:
	var payload := {
		"card_id": card_id,
		"card_type": card_type,
		"wave_index": wave_index,
		"applied": applied,
	}
	if cell.x >= 0:
		payload["cell"] = cell
	EventBus.emit_run_event(RunEventRes.Type.CARD_PICKED, payload)
