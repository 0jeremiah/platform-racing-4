extends TileMapLayer
class_name ConfigurableTileMapLayer
## TileMapLayer extension that works with ConfigurableBlock system
##
## Provides convenience methods to place tiles by block ID instead of requiring
## knowledge of source IDs and atlas coordinates.


var _block_lookup: Dictionary = {}  # block_id → {source_id: int, atlas_coords: Vector2i}
var _blocks: Dictionary = {}  # block_id → ConfigurableBlock instance
var map_layer: MapLayer = null


## Initialize the layer with a ConfigurableTileSet
func setup_from_configs(configs: Array) -> void:
	# Create and assign tileset
	var tileset := ConfigurableTileSet.create_from_configs(configs)
	tile_set = tileset

	# Build lookup table: block_id → tile info
	_build_block_lookup(configs, tileset)

	# Create block instances
	_create_blocks(configs)


## Build the block_id → tile location mapping
func _build_block_lookup(configs: Array, tileset: ConfigurableTileSet) -> void:
	_block_lookup.clear()

	# Group configs by texture to match ConfigurableTileSet's source creation logic
	var source_id := 0
	var textures_seen: Array[String] = []

	for config in configs:
		if not config.has("id") or not (config.has("image") or config.has("custom_image")):
			continue

		var block_id: String = config.id
		if config.has("custom_image"):
			# Loads compressed image using these variables and shows the notfound block graphic if it can't.
			var custom_block_image = null
			var custom_block_texture = null
			var needed_variables = ["buffer_size", "size", "format", "has_mipmaps", "compressed_image"]
			var missing_variables = []
			for needed_variable in needed_variables:
				if !config.custom_image.has(needed_variable):
					missing_variables.append(needed_variable)
			if missing_variables.is_empty():
				custom_block_image = Image.create_from_data(config.custom_image.size.x, config.custom_image.size.y, config.custom_image.has_mipmaps, config.custom_image.format, config.custom_image.compressed_image.decompress(config.custom_image.buffer_size, 3))
			else:
				push_warning("Couldn't load block image. :(")
				custom_block_image = Image.load_from_file("res://blocks/notfoundblock.png")
			custom_block_texture = ImageTexture.create_from_image(custom_block_image)
		else:
			# Load from the game's default blockset. (this is for default blocks)
			var texture_path: String = config.image.get("src", "")

			# Track which source_id this texture gets
			var texture_source_id := source_id
			if texture_path not in textures_seen:
				textures_seen.append(texture_path)
				source_id += 1
			else:
				texture_source_id = textures_seen.find(texture_path)
		
			var title = "Block"
			if config.has("settings") and config.settings.has("title"):
				title = config.settings.title
			var comment = ""
			if config.has("settings") and config.settings.has("comment"):
				comment = config.settings.comment

			# Store the mapping
			_block_lookup[block_id] = {
				"source_id": texture_source_id,
				"atlas_coords": Vector2i(
					config.image.atlas_coords.get("x", 0),
					config.image.atlas_coords.get("y", 0)
				),
				"title": title,
				"comment": comment
			}


## Set a cell by block ID instead of atlas coordinates
func set_cell_by_id(coords: Vector2i, block_id: String, alt_id: int = ConfigurableBlock.VISIBLE_ALT_ID) -> void:
	var tile_info: Dictionary = _block_lookup.get(block_id, {})
	if tile_info.is_empty():
		push_warning("Block ID not found: " + block_id)
		return

	set_cell(coords, tile_info.source_id, tile_info.atlas_coords, alt_id)


## Get cell block ID from coordinates (reverse lookup)
func get_cell_block_id(coords: Vector2i) -> String:
	var source_id := get_cell_source_id(coords)
	var atlas_coords := get_cell_atlas_coords(coords)

	for block_id in _block_lookup:
		var info: Dictionary = _block_lookup[block_id]
		if info.source_id == source_id and info.atlas_coords == atlas_coords:
			return block_id

	return ""


func is_solid(coords: Vector2i) -> bool:
	var block_id = get_cell_block_id(coords)
	if block_id:
		return _blocks[block_id].settings.matter_type == ConfigurableBlockSettings.SOLID
	return false


func is_liquid(coords: Vector2i) -> bool:
	var block_id = get_cell_block_id(coords)
	if block_id:
		return _blocks[block_id].settings.matter_type == ConfigurableBlockSettings.LIQUID
	return false


func is_safe(coords: Vector2i) -> bool:
	var unsafe_matter_types = [ConfigurableBlockSettings.GAS]
	var unsafe_block_types = [ConfigurableBlockSettings.MOVE]
	var unsafe_block_sides = [ConfigurableBlockSideSettings.MINE, ConfigurableBlockSideSettings.VANISH,
	ConfigurableBlockSideSettings.PUSH, ConfigurableBlockSideSettings.CRUMBLE,
	ConfigurableBlockSideSettings.SAFETY, ConfigurableBlockSideSettings.SHATTER]
	var block_id = get_cell_block_id(coords)
	if block_id:
		var matter_type_is_safe: bool = _blocks[block_id].settings.matter_type not in unsafe_matter_types
		var block_type_is_safe: bool = _blocks[block_id].settings.matter_type not in unsafe_block_types
		var block_side_types = _blocks[block_id].settings.get_side_types()
		for block_side_type in block_side_types:
			if block_side_type in unsafe_block_sides:
				return false
		return matter_type_is_safe and block_type_is_safe
	return false


func get_start_positions(layer_name: String) -> Array:
	var start_blocks = []
	for block in _blocks:
		var block_instance = _blocks[block]
		if block_instance.settings.block_type == ConfigurableBlockSettings.START_POSITION:
			start_blocks.append(block)
	var start_options = []
	for start_block in start_blocks:
		var coord_list = get_used_cells_by_id(_block_lookup[start_block].source_id, _block_lookup[start_block].atlas_coords)
		for coords in coord_list:
			var start_option = {
				"layer_name": layer_name,
				"coords": coords,
				"tile_map_layer": self,
			}
			start_options.push_back(start_option)
	return start_options


## Create ConfigurableBlock instances from configs
func _create_blocks(configs: Array) -> void:
	_blocks.clear()

	for config in configs:
		if not config.has("id"):
			continue

		var block_id: String = config.id
		var block := ConfigurableBlock.new()
		block.init(config)
		_blocks[block_id] = block


## Trigger block behaviors for a tile collision
func trigger_tile_behaviors(body: PhysicsBody2D, coords: Vector2i, events: Array[String], normal: Vector2 = Vector2.ZERO) -> void:
	var block_id := get_cell_block_id(coords)
	if block_id == "":
		return

	var block: ConfigurableBlock = _blocks.get(block_id)
	if not block:
		return

	for event in events:
		block.on(event, body, self, coords, normal)
