extends Node2D
## Test scene for ConfigurableTileMapLayer
##
## Loads all block configs from blocks/configs/ and places one of each block
## in a grid on screen. Much simpler than the old tileset test thanks to
## ConfigurableTileMapLayer's set_cell_by_id() method.


@onready var tile_map_layer: ConfigurableTileMapLayer = $TileMapLayer


func _ready() -> void:
	# Load all block configs
	var configs: Array = _load_all_configs()
	print("Loaded %d block configs" % configs.size())

	configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)

	# Setup ConfigurableTileMapLayer with all configs
	tile_map_layer.setup_from_configs(configs)
	print("Created tileset with %d blocks" % configs.size())

	# Place one of each block in a grid - now much simpler!
	_place_blocks(configs)


## Load all JSON config files from blocks/configs directory
func _load_all_configs() -> Array:
	var configs: Array = []
	var dir := DirAccess.open("res://blocks/configs")

	if not dir:
		push_error("Failed to open blocks/configs directory")
		return configs

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var file_path := "res://blocks/configs/" + file_name
			var config := BlockTestUtils.load_config(file_path)
			if not config.is_empty():
				configs.append(config)
				print("Loaded config: %s (id: %s)" % [file_name, config.get("id", "unknown")])
		file_name = dir.get_next()

	dir.list_dir_end()
	return configs


## Place one of each block in a grid pattern on the tilemap
func _place_blocks(configs: Array) -> void:
	var grid_x := 0
	var grid_y := 0
	var max_columns := 10

	for config in configs:
		var block_id: String = config.get("id", "")
		if block_id.is_empty():
			continue
		
		var block_name: String = config.get("title", block_id)

		# Place the tile using the simple set_cell_by_id API
		var tile_coords := Vector2i(grid_x, grid_y)
		tile_map_layer.set_cell_by_id(tile_coords, block_id)

		print("Placed %s at grid (%d, %d)" % [block_name, grid_x, grid_y])

		# Move to next grid position
		grid_x += 1
		if grid_x >= max_columns:
			grid_x = 0
			grid_y += 1
