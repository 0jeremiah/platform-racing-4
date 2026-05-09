extends GutTest
## Test for crumble block behavior
## Expects: Ball bounces on crumble block until it is destroyed


const CRUMBLE_COORDS := Vector2i(4, 4)
const MIN_KNOCKBACK_DISTANCE := 300.0
const TEST_DURATION := 3.0


func _ready() -> void:
	super._ready()
	# When run directly (not through GUT), set up the scene
	# Check if we have the scene nodes (standalone mode)
	if has_node("TileMapLayer"):
		_setup_visual_test()


func _setup_visual_test() -> void:
	# Setup the scene for visual inspection
	var crumble_config := BlockTestUtils.load_config("res://blocks/configs/crumble.json")
	var tile_map_layer: ConfigurableTileMapLayer = $TileMapLayer
	tile_map_layer.setup_from_configs([crumble_config])
	tile_map_layer.set_cell_by_id(CRUMBLE_COORDS, crumble_config.id)

	# Setup ball
	var ball: RigidBody2D = $Ball
	var mine_world_pos: Vector2 = Vector2(CRUMBLE_COORDS * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = mine_world_pos - Vector2(0, 300)
	ball.linear_velocity = Vector2(0, 300)
	ball.physics_material_override.bounce = 1.0

	# Add result label
	var test_result_label := Label.new()
	test_result_label.position = Vector2(50, 50)
	test_result_label.add_theme_font_size_override("font_size", 24)
	add_child(test_result_label)

	# Start timer to check results
	await get_tree().create_timer(TEST_DURATION).timeout

	# Check results
	var crumble_exists := tile_map_layer.get_cell_source_id(CRUMBLE_COORDS) != -1
	var passed := not crumble_exists

	if passed:
		test_result_label.text = "PASS: crumble destroyed"
		test_result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		test_result_label.text = "FAIL: crumble exists: %s" % crumble_exists
		test_result_label.add_theme_color_override("font_color", Color.RED)


func test_mine_explodes_and_knocks_ball_away() -> void:
	# Load the test scene
	var scene: Node2D = _create_test_scene()
	add_child_autofree(scene)

	# Get references
	var tile_map_layer: ConfigurableTileMapLayer = scene.get_node("TileMapLayer")

	# Wait for physics simulation
	await wait_seconds(TEST_DURATION)

	# Check crumble was destroyed
	var crumble_exists := tile_map_layer.get_cell_source_id(CRUMBLE_COORDS) != -1
	assert_false(
		crumble_exists,
		"Crumble should be destroyed after a couple of collision"
	)


## Create and configure the test scene
func _create_test_scene() -> Node2D:
	# Load the scene template
	var scene_template: PackedScene = load("res://blocks/tests/mine_test.tscn")
	var scene: Node2D = scene_template.instantiate()

	# Setup tilemap with crumble config
	var crumble_config := BlockTestUtils.load_config("res://blocks/configs/crumble.json")
	var tile_map_layer: ConfigurableTileMapLayer = scene.get_node("TileMapLayer")
	tile_map_layer.setup_from_configs([crumble_config])
	tile_map_layer.set_cell_by_id(CRUMBLE_COORDS, crumble_config.id)

	# Setup ball
	var ball: RigidBody2D = scene.get_node("Ball")
	var mine_world_pos: Vector2 = Vector2(CRUMBLE_COORDS * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = mine_world_pos - Vector2(0, 300)  # 300 pixels above mine
	ball.linear_velocity = Vector2(0, 300)  # Initial downward velocity
	ball.physics_material_override.bounce = 1.0

	return scene
