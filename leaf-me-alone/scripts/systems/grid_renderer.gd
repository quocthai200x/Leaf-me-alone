extends Node2D
## Renders GridData only — never mutates grid authority.

const TILE_SIZE := 16
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const DissatisfactionIndicatorSystemRes := preload(
	"res://scripts/systems/dissatisfaction_indicator_system.gd"
)
const GameConstantsRes := preload("res://scripts/utils/constants.gd")

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _plant_map: TileMapLayer = $PlantMapLayer
@onready var _indicators: Node2D = $Indicators

var _grid: GridDataRes
var _in_combat: bool = false


func _ready() -> void:
	_build_greybox_tileset()
	if _indicators != null:
		_indicators.z_index = 10


func set_combat_phase(active: bool) -> void:
	_in_combat = active


func sync_from_grid_data(grid: GridDataRes) -> void:
	_grid = grid
	_tile_map.clear()
	_plant_map.clear()
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			var soil: int = grid.get_soil_type(pos)
			_tile_map.set_cell(pos, 0, _atlas_for_soil(soil))
			if not grid.get_plant_species_id(pos).is_empty():
				_plant_map.set_cell(pos, 0, Vector2i(4, 0))
	_sync_dissatisfaction_indicators(grid)


func sync_dissatisfaction_indicators(grid: GridDataRes) -> void:
	_sync_dissatisfaction_indicators(grid)


func _sync_dissatisfaction_indicators(grid: GridDataRes) -> void:
	if _indicators == null:
		return
	for child in _indicators.get_children():
		child.queue_free()
	for y in grid.height:
		for x in grid.width:
			var pos := Vector2i(x, y)
			if not grid.has_plant(pos):
				continue
			var dissat := grid.get_plant_dissatisfaction(pos)
			var state := DissatisfactionIndicatorSystemRes.get_indicator_state(dissat, _in_combat)
			if not bool(state.get("show_emoji", false)):
				continue
			_create_indicator(pos, state)


func _create_indicator(cell: Vector2i, state: Dictionary) -> void:
	var root := Control.new()
	root.position = Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE - 6)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicators.add_child(root)

	var emoji := Label.new()
	emoji.text = "😤"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 10)
	emoji.position = Vector2(-2, -10)
	emoji.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(emoji)

	if bool(state.get("show_meter", false)):
		var meter_bg := ColorRect.new()
		meter_bg.color = Color(0.2, 0.2, 0.2, 0.8)
		meter_bg.size = Vector2(TILE_SIZE - 2, 3)
		meter_bg.position = Vector2(1, -2)
		meter_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(meter_bg)

		var meter_fill := ColorRect.new()
		meter_fill.color = state.get("meter_color", GameConstantsRes.DISSATISFACTION_COLOR)
		var fill_w := (TILE_SIZE - 2) * float(state.get("meter_fill", 0.0))
		meter_fill.size = Vector2(fill_w, 3)
		meter_fill.position = meter_bg.position
		meter_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(meter_fill)


func _build_greybox_tileset() -> void:
	var image := Image.create(TILE_SIZE * 5, TILE_SIZE, false, Image.FORMAT_RGBA8)
	_fill_tile_color(image, 0, Color(0.55, 0.22, 0.18)) # RED soil
	_fill_tile_color(image, 1, Color(0.86, 0.78, 0.55)) # SAND
	_fill_tile_color(image, 2, Color(0.45, 0.45, 0.48)) # ROCK
	_fill_tile_color(image, 3, Color(0.35, 0.55, 0.30)) # MOLD
	_fill_tile_color(image, 4, Color(0.35, 0.75, 0.35)) # PLANT marker

	var texture := ImageTexture.create_from_image(image)
	var tile_set := TileSet.new()
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for atlas_x in 5:
		source.create_tile(Vector2i(atlas_x, 0))
	tile_set.add_source(source, 0)
	_tile_map.tile_set = tile_set
	_plant_map.tile_set = tile_set
	_tile_map.rendering_quadrant_size = TILE_SIZE
	_plant_map.rendering_quadrant_size = TILE_SIZE


func _fill_tile_color(image: Image, tile_index: int, color: Color) -> void:
	for y in TILE_SIZE:
		for x in TILE_SIZE:
			image.set_pixel(tile_index * TILE_SIZE + x, y, color)


func _atlas_for_soil(soil: int) -> Vector2i:
	match soil:
		SoilTypeRes.Type.RED:
			return Vector2i(0, 0)
		SoilTypeRes.Type.SAND:
			return Vector2i(1, 0)
		SoilTypeRes.Type.MOLD:
			return Vector2i(3, 0)
		_:
			return Vector2i(2, 0)
