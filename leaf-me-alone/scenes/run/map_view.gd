extends Node2D
## Map container — grid display scale, pan bounds, placement preview for InputRouter.

const GridRendererScene := preload("res://scenes/run/grid_renderer.tscn")
const PlacementPreviewScript := preload("res://scripts/systems/placement_preview.gd")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const PlantPlacementSystemScript := preload("res://scripts/systems/plant_placement_system.gd")
const CareSystemScript := preload("res://scripts/systems/care_system.gd")
const StructureTypeRes := preload("res://scripts/data/structure_type.gd")
const CardEffectApplierRes := preload("res://scripts/systems/card_effect_applier.gd")
const ForestCoreScene := preload("res://scenes/entities/structures/forest_core.tscn")
const RootNestScene := preload("res://scenes/entities/structures/root_nest.tscn")

const TILE_SIZE := 16
const DISPLAY_SCALE := 3.0
const PAN_MARGIN := 80.0

var _grid_renderer: Node2D
var _placement_preview: Node2D
var _entities: Node2D
var _visible_size: Vector2 = Vector2(1920.0, 1080.0)
var _pan_enabled: bool = false


func _ready() -> void:
	add_to_group("map_view")
	_grid_renderer = GridRendererScene.instantiate()
	_grid_renderer.scale = Vector2(DISPLAY_SCALE, DISPLAY_SCALE)
	add_child(_grid_renderer)

	_entities = get_node_or_null("Entities") as Node2D
	if _entities == null:
		_entities = Node2D.new()
		_entities.name = "Entities"
		add_child(_entities)

	_placement_preview = PlacementPreviewScript.new()
	_placement_preview.scale = Vector2(DISPLAY_SCALE, DISPLAY_SCALE)
	add_child(_placement_preview)


func spawn_structures(grid: GridDataRes) -> void:
	if _entities == null:
		return
	for child in _entities.get_children():
		child.queue_free()
	for entry in grid.get_structures():
		var type_id := str(entry.get("type", ""))
		var scene: PackedScene = null
		if type_id == StructureTypeRes.FOREST_CORE:
			scene = ForestCoreScene
		elif type_id == StructureTypeRes.ROOT_NEST:
			scene = RootNestScene
		if scene == null:
			continue
		var node := scene.instantiate()
		if node.has_method("configure"):
			node.configure(
				str(entry.get("id", "")),
				type_id,
				entry.get("cell", Vector2i.ZERO)
			)
		_entities.add_child(node)


func sync_from_grid_data(grid: GridDataRes) -> void:
	_grid_renderer.sync_from_grid_data(grid)
	_update_pan_state()
	_clamp_position()


func sync_dissatisfaction_indicators(grid: GridDataRes) -> void:
	if _grid_renderer.has_method("sync_dissatisfaction_indicators"):
		_grid_renderer.sync_dissatisfaction_indicators(grid)


func set_combat_phase(active: bool) -> void:
	if _grid_renderer.has_method("set_combat_phase"):
		_grid_renderer.set_combat_phase(active)


func play_flee_animation(cell: Vector2i) -> void:
	if _grid_renderer.has_method("play_flee_animation"):
		await _grid_renderer.play_flee_animation(cell)


func set_visible_map_size(size: Vector2) -> void:
	_visible_size = size
	_update_pan_state()
	_clamp_position()


func get_map_pixel_size() -> Vector2:
	var grid: GridDataRes = RunManager.grid_data
	if grid == null:
		return Vector2.ZERO
	return Vector2(grid.width * TILE_SIZE, grid.height * TILE_SIZE) * DISPLAY_SCALE


func can_pan() -> bool:
	return _pan_enabled


func apply_pan_delta(screen_delta: Vector2) -> void:
	if not _pan_enabled:
		return
	position += screen_delta
	_clamp_position()


func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var local := get_global_transform_with_canvas().affine_inverse() * screen_pos
	local /= DISPLAY_SCALE
	return Vector2i(floori(local.x / TILE_SIZE), floori(local.y / TILE_SIZE))


func update_placement_preview(screen_pos: Vector2, species_id: String) -> void:
	if species_id.is_empty() or _placement_preview == null:
		clear_placement_preview()
		return
	var cell := screen_to_grid(screen_pos)
	var grid := RunManager.grid_data
	if grid == null or not grid.is_in_bounds(cell):
		clear_placement_preview()
		return
	var valid := false
	var placement := _get_plant_placement_system()
	if placement != null:
		valid = placement.can_preview_place(cell, species_id)
	_placement_preview.set_preview(cell, species_id, valid, true)


func clear_placement_preview() -> void:
	if _placement_preview != null:
		_placement_preview.clear_preview()


func try_place_at_screen(screen_pos: Vector2, species_id: String) -> bool:
	var placement := _get_plant_placement_system()
	if placement == null or species_id.is_empty():
		return false
	var cell := screen_to_grid(screen_pos)
	return placement.try_place_plant(cell, species_id)


func try_care_at_screen(screen_pos: Vector2, care_type: String) -> bool:
	var care := _get_care_system()
	if care == null or care_type.is_empty():
		return false
	var cell := screen_to_grid(screen_pos)
	if care_type == "fertilize":
		return care.try_fertilize(cell)
	return care.try_water(cell)


func try_terraform_at_screen(screen_pos: Vector2) -> bool:
	var card_id := RunManager.run_state.pending_soil_card_id
	if card_id.is_empty():
		return false
	var cell := screen_to_grid(screen_pos)
	var wave_index := RunManager.run_state.wave_index
	return CardEffectApplierRes.apply_soil_at_cell(card_id, cell, wave_index)


func play_care_juice(cell: Vector2i) -> void:
	var spark := PlacementPreviewScript.new()
	spark.scale = Vector2(DISPLAY_SCALE, DISPLAY_SCALE)
	add_child(spark)
	spark.set_preview(cell, "", true, true)
	var tween := create_tween()
	tween.tween_property(spark, "modulate:a", 0.0, 0.25)
	tween.tween_callback(spark.queue_free)


func play_place_juice(_cell: Vector2i) -> void:
	var base := Vector2(DISPLAY_SCALE, DISPLAY_SCALE)
	var tween := create_tween()
	tween.tween_property(_grid_renderer, "scale", base * 1.06, 0.08).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_grid_renderer, "scale", base, 0.12)


func _get_care_system() -> CareSystemScript:
	var nodes := get_tree().get_nodes_in_group("care_system")
	if nodes.is_empty():
		return null
	return nodes[0] as CareSystemScript


func _get_plant_placement_system() -> PlantPlacementSystemScript:
	var nodes := get_tree().get_nodes_in_group("plant_placement_system")
	if nodes.is_empty():
		return null
	return nodes[0] as PlantPlacementSystemScript


func _update_pan_state() -> void:
	var map_size := get_map_pixel_size()
	_pan_enabled = map_size.x > _visible_size.x or map_size.y > _visible_size.y


func _clamp_position() -> void:
	var map_size := get_map_pixel_size()
	if map_size == Vector2.ZERO:
		return
	var min_x := _visible_size.x - map_size.x - PAN_MARGIN
	var max_x := PAN_MARGIN
	var min_y := _visible_size.y - map_size.y - PAN_MARGIN
	var max_y := PAN_MARGIN
	position.x = clampf(position.x, min_x, max_x)
	position.y = clampf(position.y, min_y, max_y)
