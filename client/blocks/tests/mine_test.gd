extends GutTest
## Test for mine block behavior
## Expects: Ball gets knocked away with force, mine gets destroyed


const MINE_COORDS := Vector2i(4, 4)
const MIN_KNOCKBACK_DISTANCE := 300.0
const TEST_DURATION := 2.0


func _ready() -> void:
	super._ready()
	# When run directly (not through GUT), set up the scene
	# Check if we have the scene nodes (standalone mode)
	if has_node("TileMapLayer"):
		_setup_visual_test()


func _setup_visual_test() -> void:
	# Setup the scene for visual inspection
	var mine_config := BlockTestUtils.load_config("res://blocks/configs/mine.json")
	var tile_map_layer: ConfigurableTileMapLayer = $TileMapLayer
	tile_map_layer.setup_from_configs([mine_config])
	tile_map_layer.set_cell_by_id(MINE_COORDS, "mine")

	# Setup ball
	var ball: RigidBody2D = $Ball
	var mine_world_pos: Vector2 = Vector2(MINE_COORDS * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = mine_world_pos - Vector2(0, 300)
	ball.linear_velocity = Vector2(0, 300)

	# Store initial position for checking later
	var initial_ball_position := ball.global_position

	# Add result label
	var test_result_label := Label.new()
	test_result_label.position = Vector2(50, 50)
	test_result_label.add_theme_font_size_override("font_size", 24)
	add_child(test_result_label)

	# Start timer to check results
	await get_tree().create_timer(TEST_DURATION).timeout

	# Check results
	var distance_moved := initial_ball_position.distance_to(ball.global_position)
	var mine_exists := tile_map_layer.get_cell_source_id(MINE_COORDS) != -1
	var passed := distance_moved > MIN_KNOCKBACK_DISTANCE and not mine_exists

	if passed:
		test_result_label.text = "PASS: Ball knocked %.0f px, mine destroyed" % distance_moved
		test_result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		test_result_label.text = "FAIL: Ball moved %.0f px, mine exists: %s" % [distance_moved, mine_exists]
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

	# Check ball was knocked away
	var distance_moved := initial_position.distance_to(ball.global_position)
	assert_gt(
		distance_moved,
		MIN_KNOCKBACK_DISTANCE,
		"Ball should be knocked away at least %.0f pixels, but only moved %.1f pixels" % [MIN_KNOCKBACK_DISTANCE, distance_moved]
	)

	# Check mine was destroyed
	var mine_exists := tile_map_layer.get_cell_source_id(MINE_COORDS) != -1
	assert_false(
		mine_exists,
		"Mine should be destroyed after collision"
	)


## Create and configure the test scene
func _create_test_scene() -> Node2D:
	# Load the scene template
	var scene_template: PackedScene = load("res://blocks/tests/mine_test.tscn")
	var scene: Node2D = scene_template.instantiate()

	# Setup tilemap with mine config
	var mine_config := BlockTestUtils.load_config("res://blocks/configs/mine.json")
	var tile_map_layer: ConfigurableTileMapLayer = scene.get_node("TileMapLayer")
	tile_map_layer.setup_from_configs([mine_config])
	tile_map_layer.set_cell_by_id(MINE_COORDS, "mine")

	# Setup ball
	var ball: RigidBody2D = scene.get_node("Ball")
	var mine_world_pos: Vector2 = Vector2(MINE_COORDS * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = mine_world_pos - Vector2(0, 300)  # 300 pixels above mine
	ball.linear_velocity = Vector2(0, 300)  # Initial downward velocity

	return scene
