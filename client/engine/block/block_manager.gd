extends Node
class_name BlockManager

@onready var block_layers: BlockLayers = $BlockLayers
@onready var block_decoder: BlockDecoder = $BlockDecoder
@onready var block_encoder: BlockEncoder = $BlockEncoder

static var _default_blocks: Dictionary = {}  # contains default block categories with their block ids
static var _block_lookup: Dictionary = {}  # block_id → {source_id: int, atlas_coords: Vector2i}
static var _blocks: Dictionary = {}  # block_id → ConfigurableBlock instance
static var _tile_set: ConfigurableTileSet = ConfigurableTileSet.new()


func _ready() -> void:
	pass


## Initialize the layer with a ConfigurableTileSet
static func add_block_configs(configs: Array) -> void:
	# Create and assign tileset
	_tile_set.init(configs)
	_tile_set.uv_clipping = true

	# Build lookup table: block_id → tile info
	_build_block_lookup(configs, _tile_set)

	# Create block instances
	_create_blocks(configs)


## Build the block_id → tile location mapping
static func _build_block_lookup(configs: Array, tileset: ConfigurableTileSet) -> void:
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


## Create ConfigurableBlock instances from configs
static func _create_blocks(configs: Array) -> void:
	_blocks.clear()

	for config in configs:
		if not config.has("id"):
			continue

		var block_id: String = config.id
		var block := ConfigurableBlock.new()
		block.init(config)
		_blocks[block_id] = block


func encode_block() -> Dictionary:
	return block_encoder.encode(block_layers, self)


func decode_block(block_data: Dictionary) -> void:
	block_decoder.decode(block_data, block_layers)


func clear() -> void:
	block_layers.clear()


static func get_default_blocks() -> Dictionary:
	if !_default_blocks.is_empty():
		return _default_blocks
	return {}


static func load_default_block_configs():
	var categories: Array = ["pr2", "desert", "industrial", "jungle", "space", "underwater", "pr4"]
	var configs: Array = []
	var id_gap: int = 0
	for category in categories:
		_default_blocks[category] = {}
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
					if config.id.is_valid_int():
						config.id = str(int(config.id) + id_gap)
					else:
						config.id = category + config.id
					var src = "res://blocks/tileatlas" + category + ".png"
					if config.has("image") and config.image.has("src") and src.is_absolute_path():
						config.image.src = src
					_default_blocks[category][config.id] = {"id": config.id}
					configs.append(config)
					#print("Loaded config: %s (id: %s)" % [file_name, config.get("id", "unknown")])
			file_name = dir.get_next()

		dir.list_dir_end()
		id_gap += 100
	
	if configs:
		configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		add_block_configs(configs)


func set_settings(new_settings: Dictionary):
	pass
