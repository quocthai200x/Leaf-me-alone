extends Control

const GRID_RENDERER_SCENE := preload("res://scenes/run/grid_renderer.tscn")
const GridDataRes := preload("res://scripts/data/grid_data.gd")
const SoilTypeRes := preload("res://scripts/data/soil_type.gd")
const TEST_SEED := 12345


func _ready() -> void:
	if not ContentRegistry.is_loaded():
		$Label.text = tr("Leaf Me Alone — Content load FAILED")
		push_error("Bootstrap: ContentRegistry failed to load critical content")
		return

	var grid_a: GridDataRes = GridDataRes.new()
	grid_a.generate_from_seed(TEST_SEED)
	var grid_b: GridDataRes = GridDataRes.new()
	grid_b.generate_from_seed(TEST_SEED)
	if grid_a.compute_layout_hash() != grid_b.compute_layout_hash():
		push_error("Bootstrap: seed reproducibility check failed for seed %d" % TEST_SEED)

	var grid: GridDataRes = RunManager.start_run(TEST_SEED)
	var renderer: Node2D = GRID_RENDERER_SCENE.instantiate()
	renderer.position = Vector2(320, 120)
	add_child(renderer)
	renderer.sync_from_grid_data(grid)

	$Label.text = tr(
		"Leaf Me Alone — Seed %d | Red: %d | Hash: %d"
		% [TEST_SEED, grid.count_soil(SoilTypeRes.Type.RED), grid.compute_layout_hash()]
	)
