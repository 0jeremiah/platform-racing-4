extends GutTest
## Test for brick block behavior
## Expects: Ball bumps brick, brick gets destroyed


const BRICK_COORDS := Vector2i(4, 2)
const TEST_DURATION := 2.0


func _ready() -> void:
	super._ready()
	# When run directly (not through GUT), set up the scene
	# Check if we have the scene nodes (standalone mode)
	if has_node("TileMapLayer"):
		_setup_visual_test()


func _setup_visual_test() -> void:
	# Setup the scene for visual inspection
	var brick_config := BlockTestUtils.load_config("res://blocks/configs/brick.json")
	var tile_map_layer: ConfigurableTileMapLayer = $TileMapLayer
	tile_map_layer.setup_from_configs([brick_config])
	tile_map_layer.add_block(BRICK_COORDS, brick_config.id)

	# Setup ball
	var ball: RigidBody2D = $Ball
	var mine_world_pos: Vector2 = Vector2(BRICK_COORDS * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = mine_world_pos - Vector2(0, -1000)
	ball.linear_velocity = Vector2(0, -2250)

	# Add result label
	var test_result_label := Label.new()
	test_result_label.position = Vector2(50, 50)
	test_result_label.add_theme_font_size_override("font_size", 24)
	add_child(test_result_label)

	# Start timer to check results
	await get_tree().create_timer(TEST_DURATION).timeout

	# Check results
	var brick_exists := tile_map_layer.get_cell_source_id(BRICK_COORDS) != -1
	var passed := not brick_exists

	if passed:
		test_result_label.text = "PASS: brick destroyed"
		test_result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		test_result_label.text = "FAIL: brick exists"
		test_result_label.add_theme_color_override("font_color", Color.RED)


func test_mine_explodes_and_knocks_ball_away() -> void:
	# Load the test scene
	var scene: Node2D = _create_test_scene()
	add_child_autofree(scene)

	# Get references
	var ball: RigidBody2D = scene.get_node("Ball")
	var tile_map_layer: ConfigurableTileMapLayer = scene.get_node("TileMapLayer")

	# Store initial position
	var initial_position := ball.global_position

	# Wait for physics simulation
	await wait_seconds(TEST_DURATION)

	# Check mine was destroyed
	var brick_exists := tile_map_layer.get_cell_source_id(BRICK_COORDS) != -1
	assert_false(
		brick_exists,
		"Brick should be destroyed after bumped from below"
	)


## Create and configure the test scene
func _create_test_scene() -> Node2D:
	# Load the scene template
	var scene_template: PackedScene = load("res://blocks/tests/mine_test.tscn")
	var scene: Node2D = scene_template.instantiate()

	# Setup tilemap with brick config
	var brick_config := BlockTestUtils.load_config("res://blocks/configs/brick.json")
	var tile_map_layer: ConfigurableTileMapLayer = scene.get_node("TileMapLayer")
	tile_map_layer.setup_from_configs([brick_config])
	tile_map_layer.add_block(BRICK_COORDS, brick_config.id)

	# Setup ball
	var ball: RigidBody2D = scene.get_node("Ball")
	var brick_world_pos: Vector2 = Vector2(BRICK_COORDS * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = brick_world_pos - Vector2(0, -1000)  # 1000 pixels below brick
	ball.linear_velocity = Vector2(0, -2250)  # Initial upward velocity

	return scene
