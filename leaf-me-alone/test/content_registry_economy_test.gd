extends GdUnitTestSuite
## Unit tests for economy data and theme resource (Story 2.1).

const THEME_PATH := "res://themes/leaf_me_alone_theme.tres"


func test_content_registry_exposes_economy_costs() -> void:
	assert_bool(ContentRegistry.is_loaded()).is_true()
	var economy: EconomyDef = ContentRegistry.get_economy()
	assert_object(economy).is_not_null()
	assert_int(economy.water_cost).is_equal(5)
	assert_int(economy.fertilize_cost).is_equal(10)
	assert_int(economy.get_species_cost("peanut")).is_equal(20)
	assert_int(economy.get_species_cost("cashew")).is_equal(35)
	assert_int(economy.get_species_cost("teak")).is_equal(50)


func test_economy_species_costs_match_species_defs() -> void:
	var economy: EconomyDef = ContentRegistry.get_economy()
	for species_id in ContentRegistry.get_all_species_ids():
		var species: SpeciesDef = ContentRegistry.get_species(species_id)
		assert_object(species).is_not_null()
		assert_int(species.plant_cost).is_equal(economy.get_species_cost(species_id))


func test_leaf_me_alone_theme_loads_with_primary_colors() -> void:
	var theme: Theme = load(THEME_PATH)
	assert_object(theme).override_failure_message("Theme resource failed to load").is_not_null()
	var normal_style: StyleBox = theme.get_stylebox("normal", "Button")
	assert_object(normal_style).is_not_null()
	assert_object(normal_style).is_instanceof(StyleBoxFlat)
	var flat := normal_style as StyleBoxFlat
	# primary #7BC950
	assert_float(flat.bg_color.r).is_equal_approx(0.482353, 0.001)
	assert_float(flat.bg_color.g).is_equal_approx(0.788235, 0.001)
	assert_float(flat.bg_color.b).is_equal_approx(0.313726, 0.001)
	var display_size: int = theme.get_font_size("font_size", "Label")
	assert_int(display_size).is_equal(16)
