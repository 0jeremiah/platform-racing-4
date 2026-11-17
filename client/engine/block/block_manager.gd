extends Node
class_name BlockManager

@onready var block_layers: BlockLayers = $BlockLayers
@onready var block_decoder: BlockDecoder = $BlockDecoder
@onready var block_encoder: BlockEncoder = $BlockEncoder

static var _blocks_categories: Dictionary = {}  # contains block categories with their block ids
static var _block_lookup: Dictionary = {}  # block_id → {source_id: int, atlas_coords: Vector2i}
static var _blocks: Dictionary = {}  # block_id → ConfigurableBlock instance
static var _tile_set: ConfigurableTileSet = ConfigurableTileSet.new()
static var _block_textures: Dictionary = {}
static var not_found_block_texture = null
static var loading_block_texture = null
static var solid_layer_id: int = 0
static var non_solid_layer_id: int = 1
static var placeholder_block: Dictionary = {}


## Initialize BlockManager with a ConfigurableTileSet
static func init() -> void:
	# Create and assign tileset
	_tile_set.init()
	_tile_set.uv_clipping = true
	_tile_set.set_physics_layer_collision_layer(solid_layer_id, Helpers.to_bitmask_32((10 * 2) - 1))
	_tile_set.set_physics_layer_collision_mask(solid_layer_id, Helpers.to_bitmask_32((10 * 2) - 1))
	_tile_set.set_physics_layer_collision_layer(non_solid_layer_id, Helpers.to_bitmask_32(10 * 2))
	_tile_set.set_physics_layer_collision_mask(non_solid_layer_id, Helpers.to_bitmask_32(10 * 2))
	not_found_block_texture = load_block_texture("res://blocks/notfoundblock.png")
	loading_block_texture = load_block_texture("res://blocks/loadingblock.png")
	placeholder_block = BlockTestUtils.load_config("res://blocks/placeholder_block.json")
	load_default_block_configs()


## Load block from path without Godot throwing a warning
static func load_block_texture(path: String) -> ImageTexture:
	var image = Image.new()
	image.load(ProjectSettings.globalize_path(path))
	return ImageTexture.create_from_image(image)


## Adds block configs to BlockManager
static func add_block_configs(configs: Array) -> void:
	# Build lookup table: block_id → tile info
	_build_block_lookup(configs)

	# Create block instances
	_create_blocks(configs)


## Build the block_id → tile location mapping
static func _build_block_lookup(configs: Array) -> void:
	for config in configs:
		if not config.has("id") or not (config.has("image") or config.has("custom_image")):
			continue

		var block_id: String = config.id
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
			if config.has("custom_mimic_color1_image"):
				var custom_mimic_color1_image = _load_custom_block_image(config.custom_mimic_color1_image)
				var custom_mimic_color1_texture = null
				custom_mimic_color1_texture = ImageTexture.create_from_image(custom_mimic_color1_image)
				_block_lookup[block_id]["custom_mimic_color1_texture"] = custom_mimic_color1_texture
			if config.has("custom_mimic_color2_image"):
				var custom_mimic_color2_image = _load_custom_block_image(config.custom_mimic_color2_image)
				var custom_mimic_color2_texture = null
				custom_mimic_color2_texture = ImageTexture.create_from_image(custom_mimic_color2_image)
				_block_lookup[block_id]["custom_mimic_color2_texture"] = custom_mimic_color2_texture
		else:
			# Load from the game's default blockset. (this is for default blocks)
			var texture_path: String = config.image.get("src", "")
			var teleport_texture_path: String = config.image.get("teleport_src", "")
			var mimic_color1_texture_path: String = config.image.get("mimic_color1_src", "")
			var mimic_color2_texture_path: String = config.image.get("mimic_color2_src", "")
			if texture_path and FileAccess.file_exists(texture_path):
				if texture_path not in _block_textures:
					_block_textures[texture_path] = load_block_texture(texture_path)
			else:
				continue

			# Track which source_id this texture gets
			#var texture_source_id := source_id
			#if texture_path not in textures_seen:
				#textures_seen.append(texture_path)
				#source_id += 1
			#else:
				#texture_source_id = textures_seen.find(texture_path)

			var texture2d = null
			var image_texture = load_block_texture(texture_path)
			if config.image.has("atlas_coords"):
				texture2d = AtlasTexture.new()
				texture2d.atlas = image_texture
				texture2d.region = Rect2i((Settings.tile_size * Vector2i(config.image.atlas_coords.get("x", 0), config.image.atlas_coords.get("y", 0))), Settings.tile_size)
				texture2d.filter_clip = true
			else:
				texture2d = image_texture
			var exported_image_texture = texture2d.get_image()

			# Store the mapping
			_block_lookup[block_id] = {
				"texture_path": texture_path,
				"source_id": 0,
				"alternative_tile": 0, # right now there's only one scene in our TileSetScenesCollectionSource
				# but if we ever make more we must account for that
				"image_texture": exported_image_texture
			}
			if config.image.has("atlas_coords"):
				_block_lookup[block_id]["atlas_coords"] = Vector2i(
					config.image.atlas_coords.get("x", 0),
					config.image.atlas_coords.get("y", 0)
				)
				if config.image.has("teleport_atlas_coords"):
					texture2d.region = Rect2i((Settings.tile_size * Vector2i(config.image.teleport_atlas_coords.get("x", 0), config.image.teleport_atlas_coords.get("y", 0))), Settings.tile_size)
					var exported_teleport_image_texture = texture2d.get_image()
					_block_lookup[block_id]["teleport_atlas_coords"] = Vector2i(
						config.image.teleport_atlas_coords.get("x", 0),
						config.image.teleport_atlas_coords.get("y", 0)
					)
					_block_lookup[block_id]["teleport_image_texture"] = exported_teleport_image_texture
				if config.image.has("mimic_color1_atlas_coords"):
					texture2d.region = Rect2i((Settings.tile_size * Vector2i(config.image.mimic_color1_atlas_coords.get("x", 0), config.image.mimic_color1_atlas_coords.get("y", 0))), Settings.tile_size)
					var exported_mimic_color1_image_texture = texture2d.get_image()
					_block_lookup[block_id]["mimic_color1_atlas_coords"] = Vector2i(
						config.image.mimic_color1_atlas_coords.get("x", 0),
						config.image.mimic_color1_atlas_coords.get("y", 0)
					)
					_block_lookup[block_id]["mimic_color1_image_texture"] = exported_mimic_color1_image_texture
				if config.image.has("mimic_color2_atlas_coords"):
					texture2d.region = Rect2i((Settings.tile_size * Vector2i(config.image.mimic_color2_atlas_coords.get("x", 0), config.image.mimic_color2_atlas_coords.get("y", 0))), Settings.tile_size)
					var exported_mimic_color2_image_texture = texture2d.get_image()
					_block_lookup[block_id]["mimic_color2_atlas_coords"] = Vector2i(
						config.image.mimic_color2_atlas_coords.get("x", 0),
						config.image.mimic_color2_atlas_coords.get("y", 0)
					)
					_block_lookup[block_id]["mimic_color2_image_texture"] = exported_mimic_color2_image_texture
			else:
				if teleport_texture_path and FileAccess.file_exists(teleport_texture_path):
					if teleport_texture_path not in _block_textures:
						_block_textures[teleport_texture_path] = load_block_texture(teleport_texture_path)
					var teleport_texture2d = null
					var teleport_image_texture = load_block_texture(teleport_texture_path)
					teleport_texture2d = teleport_image_texture
					_block_lookup[block_id]["teleport_image_texture"] = teleport_texture2d
				if mimic_color1_texture_path and FileAccess.file_exists(mimic_color1_texture_path):
					if mimic_color1_texture_path not in _block_textures:
						_block_textures[mimic_color1_texture_path] = load_block_texture(mimic_color1_texture_path)
					var mimic_color1_texture2d = null
					var mimic_color1_image_texture = load_block_texture(mimic_color1_texture_path)
					mimic_color1_texture2d = mimic_color1_image_texture
					_block_lookup[block_id]["mimic_color1_image_texture"] = mimic_color1_texture2d
				if mimic_color2_texture_path and FileAccess.file_exists(mimic_color2_texture_path):
					if mimic_color2_texture_path not in _block_textures:
						_block_textures[mimic_color2_texture_path] = load_block_texture(mimic_color2_texture_path)
					var mimic_color2_texture2d = null
					var mimic_color2_image_texture = load_block_texture(mimic_color2_texture_path)
					mimic_color2_texture2d = mimic_color2_image_texture
					_block_lookup[block_id]["mimic_color2_image_texture"] = mimic_color2_texture2d

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


func get_block_info(block_id: String) -> Dictionary:
	if _block_lookup.has(block_id):
		return _block_lookup[block_id]
	else:
		return {}


func get_error_block() -> Dictionary:
	var error_block = placeholder_block.duplicate(true)
	error_block["id"] = "error"
	if error_block.has("settings"):
		error_block.settings["title"] = "Not Found"
		error_block.settings["comment"] = "If you're seeing this, we couldn't find the block you were looking for. :("
	error_block["image"] = {"scr": "res://blocks/notfoundblock.png"}
	return error_block


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
				var src = "res://blocks/tileatlas" + category + ".png"
				if not config.is_empty() and config.has("id") and config.has("image"):
					if config.id.is_valid_int():
						config.id = str(int(config.id) + id_gap)
					else:
						config.id = config.id + "_" + category
					config["category"] = category
					if config.image.has("src") and src.is_absolute_path():
						config.image.src = src
					_blocks_categories[category].append({"id": config.id})
					configs.append(config)
					#print("Loaded config: %s (id: %s)" % [file_name, config.get("id", "unknown")])
			file_name = dir.get_next()
		dir.list_dir_end()
		_blocks_categories[category].sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		id_gap += 100
	# special cases (portable block/mine)
	var special_case_configs = [BlockTestUtils.load_config("res://blocks/portable_block.json"),
	BlockTestUtils.load_config("res://blocks/portable_mine.json")]
	for special_case_config in special_case_configs:
		if not special_case_config.is_empty() and special_case_config.has("id") and special_case_config.has("image"):
			if !_blocks_categories.has("hidden"):
				_blocks_categories["hidden"] = []
			special_case_config["category"] = "hidden"
			_blocks_categories["hidden"].append({"id": special_case_config.id})
			configs.append(special_case_config)
	if configs:
		configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		add_block_configs(configs)


static func get_block_texture(block_id: String) -> Texture2D:
	if block_id not in _block_lookup:
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_texture"])
	elif _block_lookup[block_id].has("atlas_coords"):
		texture = AtlasTexture.new()
		texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	else:
		texture = _block_textures[_block_lookup[block_id]["texture_path"]]
	return texture


static func get_block_teleport_texture(block_id: String) -> Texture2D:
	if block_id not in _block_lookup or block_id not in _blocks or !_blocks[block_id].settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_teleport_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_teleport_texture"])
	elif _block_lookup[block_id].has("teleport_atlas_coords"):
		texture = AtlasTexture.new()
		texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].teleport_atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	else:
		texture = _block_textures[_block_lookup[block_id]["teleport_texture_path"]]
	return texture


static func get_block_mimic_color1_texture(block_id: String) -> Texture2D:
	if block_id not in _block_lookup or block_id not in _blocks or !_blocks[block_id].settings.block_type == ConfigurableBlockSettings.MIMIC:
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_mimic_color1_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_mimic_color1_texture"])
	elif _block_lookup[block_id].has("mimic_color1_atlas_coords"):
		texture = AtlasTexture.new()
		texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].mimic_color1_atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	else:
		texture = _block_textures[_block_lookup[block_id]["mimic_color1_texture_path"]]
	return texture


static func get_block_mimic_color2_texture(block_id: String) -> Texture2D:
	if block_id not in _block_lookup or block_id not in _blocks or !_blocks[block_id].settings.block_type == ConfigurableBlockSettings.MIMIC:
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_mimic_color2_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_mimic_color2_texture"])
	elif _block_lookup[block_id].has("mimic_color2_atlas_coords"):
		texture = AtlasTexture.new()
		texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].mimic_color2_atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	else:
		texture = _block_textures[_block_lookup[block_id]["mimic_color2_texture_path"]]
	return texture


static func new_get_block_texture(block_id: String, color_1: String = "", color_2: String = "") -> Texture2D:
	var block_texture = DrawableTexture2D.new()
	block_texture.setup(128, 128, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(1.0, 1.0, 1.0, 0.0), false)
	# get block texture
	if block_id not in _block_lookup:
		return not_found_block_texture
	var texture = null
	if _block_lookup[block_id].has("custom_texture"):
		texture = _load_custom_block_image(_block_lookup[block_id]["custom_texture"])
	elif _block_lookup[block_id].has("atlas_coords"):
		texture = AtlasTexture.new()
		texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
		texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	else:
		texture = _block_textures[_block_lookup[block_id]["texture_path"]]
	# if block is an mimic block, get mimic color1 and mimic color2
	if _blocks[block_id].settings.block_type == ConfigurableBlockSettings.MIMIC:
		if color_1 == "" or !color_1.is_valid_html_color():
			color_1 = _blocks[block_id].settings.mimic_color1
		if color_2 == "" or !color_2.is_valid_html_color():
			color_2 = _blocks[block_id].settings.mimic_color2
		#var mimic_color1_texture = null
		#if _block_lookup[block_id].has("custom_mimic_color1_texture"):
			#mimic_color1_texture = _load_custom_block_image(_block_lookup[block_id]["custom_mimic_color1_texture"])
		#elif _block_lookup[block_id].has("mimic_color1_atlas_coords"):
			#mimic_color1_texture = AtlasTexture.new()
			#mimic_color1_texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
			#mimic_color1_texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].mimic_color1_atlas_coords), Settings.tile_size)
			#mimic_color1_texture.filter_clip = true
		#else:
			#texture = _block_textures[_block_lookup[block_id]["mimic_color1_texture_path"]]
		block_texture.blit_rect(Rect2i(0, 0, 128, 128), ImageTexture.create_from_image(_block_lookup[block_id].mimic_color1_image_texture), Color(color_1))
		#var mimic_color2_texture = null
		#if _block_lookup[block_id].has("custom_mimic_color2_texture"):
			#mimic_color2_texture = _load_custom_block_image(_block_lookup[block_id]["custom_mimic_color2_texture"])
		#elif _block_lookup[block_id].has("mimic_color2_atlas_coords"):
			#mimic_color2_texture = AtlasTexture.new()
			#mimic_color2_texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
			#mimic_color2_texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].mimic_color2_atlas_coords), Settings.tile_size)
			#mimic_color2_texture.filter_clip = true
		#else:
			#texture = _block_textures[_block_lookup[block_id]["mimic_color2_texture_path"]]
		block_texture.blit_rect(Rect2i(0, 0, 128, 128), ImageTexture.create_from_image(_block_lookup[block_id].mimic_color2_image_texture), Color(color_2))
	# if block is a teleport block, get teleport colorin
	elif _blocks[block_id].settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		if color_1 == "" or !color_1.is_valid_html_color():
			color_1 = _blocks[block_id].settings.teleport_color
		#var teleport_color_texture = null
		#if _block_lookup[block_id].has("custom_teleport_texture"):
			#teleport_color_texture = _load_custom_block_image(_block_lookup[block_id]["custom_teleport_texture"])
		#elif _block_lookup[block_id].has("teleport_atlas_coords"):
			#teleport_color_texture = AtlasTexture.new()
			#teleport_color_texture.atlas = _block_textures[_block_lookup[block_id]["texture_path"]]
			#teleport_color_texture.region = Rect2i((Settings.tile_size * _block_lookup[block_id].teleport_atlas_coords), Settings.tile_size)
			#teleport_color_texture.filter_clip = true
		#else:
			#texture = _block_textures[_block_lookup[block_id]["teleport_texture_path"]]
		block_texture.blit_rect(Rect2i(0, 0, 128, 128), ImageTexture.create_from_image(_block_lookup[block_id].teleport_image_texture), Color(color_1))
	block_texture.blit_rect(Rect2i(0, 0, 128, 128), ImageTexture.create_from_image(_block_lookup[block_id].image_texture), Color(1.0, 1.0, 1.0, 1.0))
	return block_texture


static func block_has_textures(block_id: String) -> Dictionary:
	return {
		"has_texture": BlockManager._block_lookup.has(block_id) and (BlockManager._block_lookup[block_id].has("custom_texture") or BlockManager._block_lookup[block_id].has("atlas_coords") or BlockManager._block_lookup[block_id].has("texture_path")),
		"has_teleport_texture": BlockManager._block_lookup.has(block_id) and (BlockManager._block_lookup[block_id].has("custom_teleport_texture") or BlockManager._block_lookup[block_id].has("teleport_atlas_coords") or BlockManager._block_lookup[block_id].has("teleport_texture_path")),
		"has_mimic_color1_texture": BlockManager._block_lookup.has(block_id) and (BlockManager._block_lookup[block_id].has("custom_mimic_color1_texture") or BlockManager._block_lookup[block_id].has("mimic_color1_atlas_coords") or BlockManager._block_lookup[block_id].has("mimic_color1_texture_path")),
		"has_mimic_color2_texture": BlockManager._block_lookup.has(block_id) and (BlockManager._block_lookup[block_id].has("custom_mimic_color2_texture") or BlockManager._block_lookup[block_id].has("mimic_color2_atlas_coords") or BlockManager._block_lookup[block_id].has("mimic_color2_texture_path"))
	}

# brough from Tiles, which is deprecated
# PR3 non-custom block data goes like this: block: b(X + (100 * Y)),
# where X is the block ID and Y is the block category

# For X, the block id list goes like this:
# (0 = start, 1-4 = basics (2-4 (white, x, and waffle) are unused in pr3.), 5 = brick, 6 = crumble, 7 = finish,
# 8 = happy, 9 = ice, 10 = infinite, 11 = item, 12 = mine, 13 = move, 14 = push, 15 = rotateleft,
# 16 = rotateright, 17 = sad, 18 = safetynet, 19 = vanish, 20 = water, 21 = redteleport, 22 = blueteleport,
# 23 = yellowteleport, 24 = bounce, 25 = change, 26 = up, 27 = down, 28 = left, 29 = right)

# For Y, the block category goes like this:
# (0 = classic, 1 = desert, 2 = industrial, 3 = jungle, 4 = space, 5 = underwater).

# Therefore, the formula should give numbers like this:
# (b1-99 = classic, b100-199 = desert, b200-299 = industrial, b300-399 = jungle,
# b400-499 = space, b500-599 = underwater.)

# pr4's (0, 0) vector is somewhere in the middle of the screen
# pr2's player1start block (in level version m4 at least, idk if previous versions keep its player1start block there)
# is defaulted at (444, 335), to shift to default camera position, shift blocks (-447, -337) coordinates
# pr3's (0, 0) is in it's top-left screen; to shift to default camera position, shift blocks (-8, -6)
