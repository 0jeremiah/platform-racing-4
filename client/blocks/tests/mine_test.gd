extends Node2D
## Test for mine block behavior
## Expects: Ball gets knocked away with force, mine gets destroyed


var initial_ball_position: Vector2
var test_complete := false
var test_passed := false
var test_message := ""
var mine_coords := Vector2i(4, 4)


func _ready() -> void:
	_setup_tilemap()
	_setup_ball()

	# Store initial ball position
	initial_ball_position = $Ball.global_position

	# Start 2-second timer
	var timer := Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_on_test_timeout)
	add_child(timer)
	timer.start()


func _setup_tilemap() -> void:
	# Load mine config
	var mine_config := BlockTestUtils.load_config("res://blocks/configs/mine.json")

	# Set up ConfigurableTileMapLayer
	var tile_map_layer: ConfigurableTileMapLayer = $TileMapLayer
	tile_map_layer.setup_from_configs([mine_config])

	# Place mine tile by ID
	tile_map_layer.set_cell_by_id(mine_coords, "mine")


func _setup_ball() -> void:
	var ball: RigidBody2D = $Ball

	# Position ball above the mine to drop onto it
	var mine_world_pos: Vector2 = Vector2(mine_coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	ball.position = mine_world_pos - Vector2(0, 300)  # 300 pixels above mine

	# Give ball some initial downward velocity to ensure collision
	ball.linear_velocity = Vector2(0, 300)

	# Create a simple circle sprite for visual feedback
	var sprite: Sprite2D = ball.get_node("Sprite2D")
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.ORANGE)
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture


func _on_test_timeout() -> void:
	test_complete = true

	# Check if ball was knocked away (moved significantly)
	var distance_moved := initial_ball_position.distance_to($Ball.global_position)
	var was_knocked_away := distance_moved > 200.0  # Expect at least 200 pixels of movement

	# Check if mine tile was destroyed
	var tile_map_layer: TileMapLayer = $TileMapLayer
	var mine_exists := tile_map_layer.get_cell_source_id(mine_coords) != -1

	# Test passes if ball moved far and mine is gone
	if was_knocked_away and not mine_exists:
		test_passed = true
		test_message = "PASS: Ball knocked away (%.1f px), mine destroyed" % distance_moved
	elif not was_knocked_away and not mine_exists:
		test_passed = false
		test_message = "FAIL: Mine destroyed but ball only moved %.1f px (expected >200)" % distance_moved
	elif was_knocked_away and mine_exists:
		test_passed = false
		test_message = "FAIL: Ball knocked away but mine still exists"
	else:
		test_passed = false
		test_message = "FAIL: Ball not knocked away (%.1f px) and mine still exists" % distance_moved

	print(test_message)
	print("Ball movement: ", distance_moved, " pixels")
	print("Mine exists: ", mine_exists)


func _process(_delta: float) -> void:
	if test_complete:
		# Draw test result on screen
		queue_redraw()


func _draw() -> void:
	if test_complete:
		var color := Color.GREEN if test_passed else Color.RED
		var font := ThemeDB.fallback_font
		var font_size := 24
		draw_string(font, Vector2(50, 50), test_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
