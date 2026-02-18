class_name BlockTestUtils
## Utility functions for block tests


## Load a block config from a JSON file
static func load_config(config_path: String) -> Dictionary:
	var config_file := FileAccess.open(config_path, FileAccess.READ)
	if not config_file:
		push_error("Failed to open config file: " + config_path)
		return {}

	var config_json := config_file.get_as_text()
	config_file.close()

	var config: Dictionary = JSON.parse_string(config_json)
	if config == null:
		push_error("Failed to parse JSON from: " + config_path)
		return {}

	return config


## Create a test ball instance for physics testing
static func create_test_ball() -> RigidBody2D:
	var test_ball_scene: PackedScene = load("res://blocks/tests/test_ball.tscn")
	return test_ball_scene.instantiate()
