extends Node
class_name BlockManager

@onready var block_layers: BlockLayers = $BlockLayers
@onready var block_decoder: BlockDecoder = $BlockDecoder
@onready var block_encoder: BlockEncoder = $BlockEncoder

static var _blocks_categories: Dictionary = {}  # contains block categories with their block ids
static var _block_lookup: Dictionary = {}  # block_id → {source_id: int, atlas_coords: Vector2i}
static var _blocks: Dictionary = {}  # block_id → ConfigurableBlock instance
static var _tile_set: ConfigurableTileSet = ConfigurableTileSet.new()


## Initialize BlockManager with a ConfigurableTileSet
static func init() -> void:
	# Create and assign tileset
	_tile_set.init()
	_tile_set.uv_clipping = true
	# 0: any side
	# 1: top
	# 2: bottom
	# 3: left
	# 4: right
	# 5: area
	_tile_set.set_physics_layer_collision_layer(0, Helpers.to_bitmask_32((10 * 2) - 1))
	_tile_set.set_physics_layer_collision_mask(0, Helpers.to_bitmask_32((10 * 2) - 1))
	_tile_set.set_physics_layer_collision_layer(1, Helpers.to_bitmask_32(10 * 2))
	_tile_set.set_physics_layer_collision_mask(1, Helpers.to_bitmask_32(10 * 2))


## Adds block configs to BlockManager
static func add_block_configs(configs: Array) -> void:
	# Build lookup table: block_id → tile info
	_build_block_lookup(configs)

	_tile_set.add_configs(configs)

	# Create block instances
	_create_blocks(configs)


## Build the block_id → tile location mapping
static func _build_block_lookup(configs: Array) -> void:
	#_block_lookup.clear()

	# Group configs by texture to match ConfigurableTileSet's source creation logic
	var source_id := _tile_set.get_source_count()
	print(_tile_set.sources_map.keys())
	var textures_seen: Array = _tile_set.sources_map.keys()

	for config in configs:
		if not config.has("id") or not (config.has("image") or config.has("custom_image")):
			continue

		var block_id: String = config.id
		print(block_id)
		if config.has("custom_image"):
			# Loads compressed image using these variables and shows the notfound block graphic if it can't.
			var custom_block_image = _load_custom_block_image(config.custom_image)
			var custom_block_texture = null
			custom_block_texture = ImageTexture.create_from_image(custom_block_image)
			_block_lookup[block_id] = {
				"custom_texture": custom_block_texture
			}
			if config.has("custom_teleport_image"):
				var custom_teleport_block_image = _load_custom_block_image(config.custom_teleport_image)
				var custom_teleport_block_texture = null
				custom_teleport_block_texture = ImageTexture.create_from_image(custom_teleport_block_image)
				_block_lookup[block_id]["custom_teleport_texture"] = custom_teleport_block_texture
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

			#var texture2d = AtlasTexture.new()
			#var image_texture = ImageTexture.create_from_image(Image.load_from_file(texture_path))
			#texture2d.atlas = image_texture
			#texture2d.region = Rect2i((Settings.tile_size * Vector2i(config.image.atlas_coords.get("x", 0), config.image.atlas_coords.get("y", 0))), Settings.tile_size)
			#texture2d.filter_clip = true
			#var exported_image_texture = texture2d.get_image()

			# Store the mapping
			_block_lookup[block_id] = {
				"source_id": texture_source_id,
				"atlas_coords": Vector2i(
					config.image.atlas_coords.get("x", 0),
					config.image.atlas_coords.get("y", 0)
				),
				#"image_texture": exported_image_texture
			}
			
			if config.image.has("teleport_atlas_coords"):
				#texture2d.region = Rect2i((Settings.tile_size * Vector2i(config.image.teleport_atlas_coords.get("x", 0), config.image.teleport_atlas_coords.get("y", 0))), Settings.tile_size)
				#var exported_teleport_image_texture = texture2d.get_image()
				_block_lookup[block_id]["teleport_atlas_coords"] = Vector2i(
					config.image.teleport_atlas_coords.get("x", 0),
					config.image.teleport_atlas_coords.get("y", 0)
				)
				#_block_lookup[block_id]["teleport_image_texture"] = exported_teleport_image_texture

		var title = "Block"
		var comment = ""
		if config.has("settings"):
			if config.has("settings") and config.settings.has("title"):
				title = config.settings.title
			if config.has("settings") and config.settings.has("comment"):
				comment = config.settings.comment

		# Assumes the block is a custom block since category is
		# only initalized through load_default_block_configs
		var category = "custom"
		if config.has("category"):
			category = config.category

		# Store additional block info
		_block_lookup[block_id]["title"] = title
		_block_lookup[block_id]["comment"] = comment
		_block_lookup[block_id]["settings"] = config.settings
		_block_lookup[block_id]["category"] = category


static func _load_custom_block_image(custom_image_dictionary: Dictionary) -> Image:
	# Loads compressed image using these variables and shows the notfound block graphic if it can't.
	var image = null
	var needed_variables = ["buffer_size", "size", "format", "has_mipmaps", "compressed_image"]
	var missing_variables = []
	for needed_variable in needed_variables:
		if !custom_image_dictionary.has(needed_variable):
			missing_variables.append(needed_variable)
	if missing_variables.is_empty():
		image = Image.create_from_data(custom_image_dictionary.size.x, custom_image_dictionary.size.y, custom_image_dictionary.has_mipmaps, custom_image_dictionary.format, custom_image_dictionary.compressed_image.decompress(custom_image_dictionary.buffer_size, 3))
	else:
		push_warning("Couldn't load block image. :(")
		image = Image.load_from_file("res://blocks/notfoundblock.png")
	return image


## Create ConfigurableBlock instances from configs
static func _create_blocks(configs: Array) -> void:
	#_blocks.clear()

	for config in configs:
		if not config.has("id"):
			continue

		var block_id: String = config.id
		var block := ConfigurableBlock.new()
		block.init(config)
		_blocks[block_id] = block


func encode_block(_block_settings: ConfigurableBlockSettings, _sub_viewport: SubViewport) -> Dictionary:
	return block_encoder.encode(_block_settings, block_layers, _sub_viewport)


func decode_block(block_data: Dictionary) -> void:
	block_decoder.decode(block_data)


func clear() -> void:
	block_layers.clear()


static func load_default_block_configs():
	var categories: Array = ["pr2", "desert", "industrial", "jungle", "space", "underwater", "pr4"]
	var configs: Array = []
	var id_gap: int = 0
	for category in categories:
		_blocks_categories[category] = []
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
					if config.has("id"):
						if !config.id.contains("portable_block") and !config.id.contains("portable_mine"):
							if config.id.is_valid_int():
								config.id = str(int(config.id) + id_gap)
							else:
								config.id = config.id + category
							config["category"] = category
							var src = "res://blocks/tileatlas" + category + ".png"
							if config.has("image") and config.image.has("src") and src.is_absolute_path():
								config.image.src = src
							if !config.id.contains("portable_block") and !config.id.contains("portable_mine"):
								_blocks_categories[category].append({"id": config.id})
							configs.append(config)
							#print("Loaded config: %s (id: %s)" % [file_name, config.get("id", "unknown")])
						else: # special cases for portable block / portable mine
							config["category"] = "hidden"
							configs.append(config)
			file_name = dir.get_next()

		dir.list_dir_end()
		_blocks_categories[category].sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		id_gap += 100
	
	if configs:
		configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		add_block_configs(configs)


static func get_block_texture(block_id: String) -> Texture2D:
	var not_found_block_texture = ImageTexture.create_from_image(Image.load_from_file("res://blocks/notfoundblock.png"))
	if block_id not in _block_lookup:
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_texture"])
	else:
		texture = AtlasTexture.new()
		print(_block_lookup[block_id])
		print(_tile_set.get_source_count())
		texture.atlas = _tile_set.get_source(_block_lookup[block_id].source_id).texture
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	return texture


static func get_block_teleport_texture(block_id: String) -> Texture2D:
	var not_found_block_texture = ImageTexture.create_from_image(Image.load_from_file("res://blocks/notfoundblock.png"))
	if block_id not in _block_lookup or block_id not in _blocks or !_blocks[block_id].settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_teleport_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_teleport_texture"])
	else:
		texture = AtlasTexture.new()
		texture.atlas = _tile_set.get_source(_block_lookup[block_id].source_id).texture
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].teleport_atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	return texture


#static func new_get_block_texture(block_id: String, teleport_color: String = "") -> Texture2D:
	#var block_texture = DrawableTexture2D.new()
	#block_texture.setup(128, 128, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(1.0, 1.0, 1.0, 0.0), false)
	## get block texture
	#var not_found_block_texture = ImageTexture.create_from_image(Image.load_from_file("res://blocks/notfoundblock.png"))
	#if block_id not in _block_lookup:
		#return not_found_block_texture
	#var texture = null
	#if _block_lookup[block_id].has("custom_texture"):
		#texture = _load_custom_block_image(_block_lookup[block_id]["custom_texture"])
	#else:
		#texture = AtlasTexture.new()
		#texture.atlas = _tile_set.get_source(_block_lookup[block_id].source_id).texture
		#texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].atlas_coords), Settings.tile_size)
		#texture.filter_clip = true
	## if block is a teleport block, get teleport colorin
	#if _blocks[block_id].settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		#if teleport_color == "" or !teleport_color.is_valid_html_color():
			#teleport_color = _blocks[block_id].settings.teleport_color
		#var teleport_color_texture = null
		#if _block_lookup[block_id].has("custom_teleport_texture"):
			#teleport_color_texture = _load_custom_block_image(_block_lookup[block_id]["custom_teleport_texture"])
		#else:
			#teleport_color_texture = AtlasTexture.new()
			#teleport_color_texture.atlas = _tile_set.get_source(_block_lookup[block_id].source_id).texture
			#teleport_color_texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].teleport_atlas_coords), Settings.tile_size)
			#teleport_color_texture.filter_clip = true
		#block_texture.blit_rect(Rect2i(0, 0, 128, 128), ImageTexture.create_from_image(_block_lookup[block_id].teleport_image_texture), Color(teleport_color))
	#block_texture.blit_rect(Rect2i(0, 0, 128, 128), ImageTexture.create_from_image(_block_lookup[block_id].image_texture), Color(1.0, 1.0, 1.0, 1.0))
	#return block_texture
