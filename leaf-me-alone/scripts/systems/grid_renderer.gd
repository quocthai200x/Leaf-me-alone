extends Node2D
## Renders GridData only — never mutates grid authority.

const TILE_SIZE := 16
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")

@onready var _tile_map: TileMapLayer = $TileMapLayer
@onready var _plant_map: TileMapLayer = $PlantMapLayer

var _grid: GridDataRes


func _ready() -> void:
	_build_greybox_tileset()


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
