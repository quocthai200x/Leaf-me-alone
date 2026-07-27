extends Control
## Greybox pause prep panel shell — visibility controlled by RunRoot.

const RunEventRes := preload("res://scripts/data/run_event.gd")
const RunStateEnumRes := preload("res://scripts/data/run_state_enum.gd")
const EconomySystemScript := preload("res://scripts/systems/economy_system.gd")
const DissatisfactionCauseLogicRes := preload(
	"res://scripts/systems/dissatisfaction_cause_logic.gd"
)
const WeatherDefRes := preload("res://scripts/data/weather_def.gd")

const SPECIES_ORDER := ["peanut", "cashew", "teak"]
const ROLE_LABELS := {"peanut": "Buff", "cashew": "ATK", "teak": "DEF"}
const WEATHER_MISMATCH_ICON := "⚠"

@onready var _tutorial_actions: VBoxContainer = %TutorialActions
@onready var _structure_summary: Label = %StructureSummary
@onready var _dogecoin_icon: Label = %DogecoinIcon
@onready var _dogecoin_value: Label = %DogecoinValue
@onready var _weather_value: Label = %WeatherValue
@onready var _catalog_section: VBoxContainer = $Content/CatalogSection
@onready var _care_section: VBoxContainer = $Content/CareSection

var _water_button: Button
var _fertilize_button: Button
var _catalog_buttons: Dictionary = {}


func _ready() -> void:
	_apply_chip_theme()
	_build_catalog()
	_build_care_actions()
	refresh_dogecoin()
	refresh_weather()
	refresh_structure_summary()
	refresh_care_affordability()
	%PlacePeanutButton.pressed.connect(_on_place_peanut_pressed)
	%WaterPlantButton.pressed.connect(_on_water_plant_pressed)
	EventBus.run_event.connect(_on_run_event)
	_update_tutorial_actions_visibility()


func refresh_dogecoin() -> void:
	var economy := _get_economy_system()
	var balance := economy.get_balance() if economy != null else RunManager.run_state.dogecoin
	_dogecoin_value.text = str(balance)


func refresh_weather() -> void:
	if _weather_value == null:
		return
	var weather_id := RunManager.run_state.current_weather
	_weather_value.text = WeatherDefRes.format_pause_readout(weather_id)
	_refresh_catalog_weather_icons()


func refresh_structure_summary() -> void:
	if _structure_summary == null:
		return
	var structure := _get_structure_hp_system()
	if structure != null and structure.has_method("get_pause_summary"):
		_structure_summary.text = structure.get_pause_summary()
	else:
		_structure_summary.text = "Structures — Core 100% · Nests 100%"


func _refresh_catalog_weather_icons() -> void:
	var weather_id := RunManager.run_state.current_weather
	for species_id in _catalog_buttons.keys():
		var btn: Button = _catalog_buttons[species_id]
		var species := ContentRegistry.get_species(species_id)
		if species == null:
			continue
		var mismatch := DissatisfactionCauseLogicRes.has_weather_mismatch(species, weather_id)
		var icon_suffix := " %s" % WEATHER_MISMATCH_ICON if mismatch else ""
		btn.text = "%s\nÐ%d\n%s%s" % [
			species.display_name,
			species.plant_cost,
			ROLE_LABELS.get(species_id, ""),
			icon_suffix,
		]
		btn.tooltip_text = (
			"Weather mismatch — dissatisfaction rises faster"
			if mismatch
			else ""
		)


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
		if not SaveManager.is_clan_unlocked(species.clan_id):
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
		_catalog_buttons[species_id] = btn


func refresh_care_affordability() -> void:
	if _water_button == null or _fertilize_button == null:
		return
	var economy := _get_economy_system()
	var balance := economy.get_balance() if economy != null else 0
	var economy_def := ContentRegistry.get_economy()
	if economy_def == null:
		return
	var water_cost := economy_def.water_cost
	var fertilize_cost := economy_def.fertilize_cost
	var can_water := balance >= water_cost
	var can_fertilize := balance >= fertilize_cost
	_water_button.disabled = not can_water
	_fertilize_button.disabled = not can_fertilize
	_water_button.tooltip_text = "Need Ð%d to water" % water_cost if not can_water else ""
	_fertilize_button.tooltip_text = "Need Ð%d to fertilize" % fertilize_cost if not can_fertilize else ""


func _build_care_actions() -> void:
	var placeholder := _care_section.get_node_or_null("CarePlaceholder")
	if placeholder != null:
		placeholder.queue_free()

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_care_section.add_child(row)

	var economy_def := ContentRegistry.get_economy()
	var water_cost := economy_def.water_cost if economy_def != null else 5
	var fertilize_cost := economy_def.fertilize_cost if economy_def != null else 10

	_water_button = Button.new()
	_water_button.custom_minimum_size = Vector2(0, 44)
	_water_button.text = "Water (Ð%d)" % water_cost
	_water_button.pressed.connect(_on_water_pressed)
	row.add_child(_water_button)

	_fertilize_button = Button.new()
	_fertilize_button.custom_minimum_size = Vector2(0, 44)
	_fertilize_button.text = "Fertilize (Ð%d)" % fertilize_cost
	_fertilize_button.pressed.connect(_on_fertilize_pressed)
	row.add_child(_fertilize_button)


func _on_water_pressed() -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_care", "care_type": "water"}
	)


func _on_fertilize_pressed() -> void:
	EventBus.emit_run_event(
		RunEventRes.Type.UI_INTENT,
		{"intent": "select_care", "care_type": "fertilize"}
	)


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


func _get_structure_hp_system() -> Node:
	var nodes := get_tree().get_nodes_in_group("structure_hp_system")
	if nodes.is_empty():
		return null
	return nodes[0]


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
	_on_water_pressed()
	EventBus.emit_run_event(
		RunEventRes.Type.TUTORIAL_ACTION,
		{"action": "water_plant"}
	)


func _on_run_event(event: int, payload: Variant) -> void:
	if event == RunEventRes.Type.DOGECOIN_CHANGED:
		refresh_dogecoin()
		refresh_care_affordability()
	elif event == RunEventRes.Type.PLANT_CARED:
		refresh_care_affordability()
	elif event == RunEventRes.Type.TUTORIAL_ACTION:
		var data: Dictionary = payload
		if str(data.get("action", "")) == "prep_complete":
			_update_tutorial_actions_visibility()
	elif event == RunEventRes.Type.STATE_CHANGED:
		_update_tutorial_actions_visibility()
		refresh_care_affordability()
		refresh_weather()
		if int(payload.get("to", -1)) == RunStateEnumRes.State.PausePhase:
			refresh_structure_summary()


func _update_tutorial_actions_visibility() -> void:
	var show_tutorial := (
		RunManager.run_state.wave_index == 0
		and RunManager.get_state() == RunStateEnumRes.State.PausePhase
	)
	_tutorial_actions.visible = show_tutorial
