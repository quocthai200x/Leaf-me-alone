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
			pass
		_:
			push_warning("[CardEffectApplier] Unsupported card type: %s" % card.type)
			return false
	RunManager.run_state.card_picks_count += 1
	EventBus.emit_run_event(
		RunEventRes.Type.CARD_PICKED,
		{
			"card_id": card_id,
			"card_type": card.type,
			"wave_index": wave_index,
			"applied": card.type == "stat",
		}
	)
	return true


static func _apply_stat_card(card) -> void:
	if card.clan != "red":
		push_warning("[CardEffectApplier] Non-red clan stat cards not in MVP slice")
		return
	RunManager.run_state.add_stat_buff(card.stat_key, card.value_pct)
