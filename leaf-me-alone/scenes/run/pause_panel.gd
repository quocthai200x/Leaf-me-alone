extends Control
## Greybox pause prep panel shell — visibility controlled by RunRoot.

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")

const SPECIES_ORDER := ["peanut", "cashew", "teak"]
const ROLE_LABELS := {"peanut": "Buff", "cashew": "ATK", "teak": "DEF"}

@onready var _tutorial_actions: VBoxContainer = %TutorialActions
@onready var _dogecoin_icon: Label = %DogecoinIcon
@onready var _dogecoin_value: Label = %DogecoinValue
@onready var _catalog_section: VBoxContainer = $Content/CatalogSection


func _ready() -> void:
	_apply_chip_theme()
	_build_catalog()
	refresh_dogecoin()
	%PlacePeanutButton.pressed.connect(_on_place_peanut_pressed)
	%WaterPlantButton.pressed.connect(_on_water_plant_pressed)
	EventBus.run_event.connect(_on_run_event)
	_update_tutorial_actions_visibility()


func refresh_dogecoin() -> void:
	var economy := _get_economy_system()
	var balance := economy.get_balance() if economy != null else RunManager.run_state.dogecoin
	_dogecoin_value.text = str(balance)


func _apply_chip_theme() -> void:
	_dogecoin_icon.theme_type_variation = &"numeric"
	_dogecoin_value.theme_type_variation = &"numeric"


func _build_catalog() -> void:
	var placeholder := _catalog_section.get_node_or_null("CatalogPlaceholder")
	if placeholder != null:
		placeholder.queue_free()

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog_section.add_child(row)

	for species_id in SPECIES_ORDER:
		var species := ContentRegistry.get_species(species_id)
		if species == null:
			continue
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(88, 88)
		btn.text = "%s\nÐ%d\n%s" % [
			species.display_name,
			species.plant_cost,
			ROLE_LABELS.get(species_id, "")
		]
		btn.pressed.connect(_on_catalog_species_pressed.bind(species_id))
		row.add_child(btn)


func _on_catalog_species_pressed(species_id: String) -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_species", "species_id": species_id}
	)
	if species_id == "peanut":
		EventBus.emit_run_event(
			RunEventRes.Type.TUTORIAL_ACTION,
			{"action": "place_peanut"}
		)


func _get_economy_system() -> EconomySystemScript:
	var nodes := get_tree().get_nodes_in_group("economy_system")
	if nodes.is_empty():
		return null
	return nodes[0] as EconomySystemScript


func _on_place_peanut_pressed() -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_species", "species_id": "peanut"}
	)
	EventBus.emit_run_event(
		RunEventRes.Type.TUTORIAL_ACTION,
		{"action": "place_peanut"}
	)


func _on_water_plant_pressed() -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_care"}
	)
	EventBus.emit_run_event(
		RunEventRes.Type.TUTORIAL_ACTION,
		{"action": "water_plant"}
	)


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.DOGECOIN_CHANGED:
		refresh_dogecoin()
	elif event == RunEventRes.Type.TUTORIAL_ACTION:
		var data: Dictionary = payload
		if str(data.get("action", "")) == "prep_complete":
			_update_tutorial_actions_visibility()
	elif event == RunEventRes.Type.STATE_CHANGED:
		_update_tutorial_actions_visibility()


func _update_tutorial_actions_visibility() -> void:
	var show_tutorial := (
		RunManager.run_state.wave_index == 0
		and RunManager.get_state() == RunStateEnumRes.State.PausePhase
	)
	_tutorial_actions.visible = show_tutorial
