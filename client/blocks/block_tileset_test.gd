extends Node2D
## Minimal unit test for ConfigurableTileSet
##
## Verifies the core tileset construction logic:
## - Source deduplication (same texture → 1 source)
## - Multiple sources (different textures → N sources)
## - Alternative tiles creation


#func _ready() -> void:
	#print("\n=== ConfigurableTileSet Unit Test ===\n")

	#_test_source_deduplication()
	#_test_multiple_sources()
	#_test_alternative_tiles()

	#print("\n=== All tests complete ===\n")
	# Auto-quit after tests (useful for CI)
	# get_tree().quit()


## Test that multiple blocks sharing the same texture create only one atlas source
#func _test_source_deduplication() -> void:
	#print("Test: Source deduplication (same texture → 1 source)")

	# Load configs that share the same texture
	#var bounce_config := BlockTestUtils.load_config("res://blocks/configs/bounce.json")
	#var mine_config := BlockTestUtils.load_config("res://blocks/configs/mine.json")
	#var ice_config := BlockTestUtils.load_config("res://blocks/configs/ice.json")
	#var arrow_config := BlockTestUtils.load_config("res://blocks/configs/arrow_down.json")

	# All these blocks should use the same texture (tileatlas.png)
	#var tileset := ConfigurableTileSet.create_from_configs([
		#bounce_config,
		#mine_config,
		#ice_config,
		#arrow_config
	#])

	#var source_count := tileset.get_source_count()
#
	#if source_count == 1:
		#print("  ✓ PASS: Created 1 source for 4 blocks sharing same texture")
	#else:
		#print("  ✗ FAIL: Expected 1 source, got %d" % source_count)


## Test that blocks with different textures create separate sources
#func _test_multiple_sources() -> void:
	#print("\nTest: Multiple sources (different textures → N sources)")
#
	## Create fake configs with different textures
	#var config1 := {
		#"id": "test1",
		#"matter_type": "solid",
		#"image": {
			#"src": "res://tiles/tileatlas.png",
			#"atlas_coords": {"x": 0, "y": 0}
		#}
	#}
#
	#var config2 := {
		#"id": "test2",
		#"matter_type": "solid",
		#"image": {
			#"src": "res://tiles/tileatlas.png",  # Same texture
			#"atlas_coords": {"x": 1, "y": 0}
		#}
	#}
#
	#var config3 := {
		#"id": "test3",
		#"matter_type": "solid",
		#"image": {
			#"src": "res://icon.svg",  # Different texture
			#"atlas_coords": {"x": 0, "y": 0}
		#}
	#}
#
	#var tileset := ConfigurableTileSet.create_from_configs([config1, config2, config3])
	#var source_count := tileset.get_source_count()

	#if source_count == 2:
		#print("  ✓ PASS: Created 2 sources for 3 blocks (2 same texture, 1 different)")
	#else:
		#print("  ✗ FAIL: Expected 2 sources, got %d" % source_count)


## Test that all alternative tiles are created for each block
#func _test_alternative_tiles() -> void:
	#print("\nTest: Alternative tiles creation")
#
	#var mine_config := BlockTestUtils.load_config("res://blocks/configs/mine.json")
	#var tileset := ConfigurableTileSet.create_from_configs([mine_config])
#
	## Get the atlas source
	#var source_id := tileset.get_source_id(0)
	#var source: TileSetAtlasSource = tileset.get_source(source_id)
#
	## Get atlas coords from config
	#var atlas_coords := Vector2i(
		#mine_config.image.atlas_coords.x,
		#mine_config.image.atlas_coords.y
	#)
#
	## Check that all 4 alternative tiles exist
	#var has_visible := source.has_alternative_tile(atlas_coords, ConfigurableBlock.VISIBLE_ALT_ID)
	#var has_invisible := source.has_alternative_tile(atlas_coords, ConfigurableBlock.INVISIBLE_ALT_ID)
	#var has_deactivated := source.has_alternative_tile(atlas_coords, ConfigurableBlock.DEACTIVATED_ALT_ID)
	#var has_invisible_deactivated := source.has_alternative_tile(atlas_coords, ConfigurableBlock.INVISIBLE_DEACTIVATED_ALT_ID)
#
	#if has_visible and has_invisible and has_deactivated and has_invisible_deactivated:
		#print("  ✓ PASS: All 4 alternative tiles created")
	#else:
		#print("  ✗ FAIL: Missing alternative tiles")
		#print("    Visible: %s" % has_visible)
		#print("    Invisible: %s" % has_invisible)
		#print("    Deactivated: %s" % has_deactivated)
		#print("    Invisible+Deactivated: %s" % has_invisible_deactivated)
#
	## Verify modulation on alternatives
	#var deactivated_tile := source.get_tile_data(atlas_coords, ConfigurableBlock.DEACTIVATED_ALT_ID)
	#var invisible_tile := source.get_tile_data(atlas_coords, ConfigurableBlock.INVISIBLE_ALT_ID)
#
	#var deactivated_correct := deactivated_tile.modulate == Color(0.5, 0.5, 0.5, 1.0)
	#var invisible_correct := invisible_tile.modulate == Color(1.0, 1.0, 1.0, 0.0)
#
	#if deactivated_correct and invisible_correct:
		#print("  ✓ PASS: Alternative tile modulation correct")
	#else:
		#print("  ✗ FAIL: Alternative tile modulation incorrect")
		#print("    Deactivated modulate: %s (expected gray)" % deactivated_tile.modulate)
		#print("    Invisible modulate: %s (expected transparent)" % invisible_tile.modulate)
