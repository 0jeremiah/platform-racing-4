extends Node
class_name StampManager

@onready var stamp_layers: StampLayers = $StampLayers
@onready var stamp_decoder: StampDecoder = $StampDecoder
@onready var stamp_encoder: StampEncoder = $StampEncoder

static var _stamp_categories: Dictionary = {}  # contains stamp categories with their stamp ids
static var _stamp_lookup: Dictionary = {}  # stamp_id → {id: String, comment: String, category: String}
static var _stamp_textures: Dictionary = {}
static var not_found_stamp_texture = preload("res://stamps/notfoundstamp.png")
static var loading_stamp_texture = preload("res://stamps/loadingstamp.png")


## Adds stamp configs to StampManager
static func add_stamp_configs(configs: Array) -> void:
	# Build lookup table: stamp_id → stamp info
	_build_stamp_lookup(configs)


static func _load_custom_stamp_image(custom_image_dictionary: Dictionary) -> Image:
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
		push_warning("Couldn't load stamp image. :(")
		image = Image.load_from_file("res://stamps/notfoundstamp.png")
	return image


## Build the stamp_id → tile location mapping
static func _build_stamp_lookup(configs: Array) -> void:
	for config in configs:
		if not config.has("id") or not (config.has("image") or config.has("custom_image")):
			continue

		var stamp_id: String = config.id
		if config.has("custom_image"):
			# Loads compressed image using these variables and shows the notfound block graphic if it can't.
			var custom_stamp_image = _load_custom_stamp_image(config.custom_image)
			var custom_stamp_texture = null
			custom_stamp_texture = ImageTexture.create_from_image(custom_stamp_image)
			_stamp_lookup[stamp_id] = {
				"custom_texture": custom_stamp_texture
			}
		else:
			# Load from the game's default stamps. (this is for default stamps)
			var texture_path: String = config.image.get("src", "")
			if texture_path and FileAccess.file_exists(texture_path):
				if texture_path not in _stamp_textures:
					_stamp_textures[texture_path] = ImageTexture.create_from_image(Image.load_from_file(texture_path))
			else:
				continue

			# Store the mapping
			_stamp_lookup[stamp_id] = {
				"texture_path": texture_path
			}
			if config.image.has("atlas_coords"):
				_stamp_lookup[stamp_id]["atlas_coords"] = config.image.atlas_coords

		var title = "Stamp"
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
		_stamp_lookup[stamp_id]["title"] = title
		_stamp_lookup[stamp_id]["comment"] = comment
		_stamp_lookup[stamp_id]["settings"] = config.settings
		_stamp_lookup[stamp_id]["category"] = category


static func load_default_stamps_configs():
	var configs: Array = []
	var dir := DirAccess.open("res://stamps/configs")

	if not dir:
		push_error("Failed to open stamps/configs directory")
		return configs

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var file_path := "res://stamps/configs/" + file_name
			var config := {}
			var config_file := FileAccess.open(file_path, FileAccess.READ)
			if not config_file:
				push_error("Failed to open config file: " + file_path)
				return
			var config_json := config_file.get_as_text()
			config_file.close()
			config = JSON.parse_string(config_json)
			if config == null:
				push_error("Failed to parse JSON from: " + file_path)
				return
			if not config.is_empty():
				if config.has("id"):
					if config.has("image") and config.image.has("src") and config.image.src.is_absolute_path():
						var src = config.image.src
						if config.image.src.is_absolute_path():
							if config.has("settings") and !config.settings.has("category"):
								config.settings["category"] = "unsorted"
							if !_stamp_categories.has(config.settings.category):
								_stamp_categories[config.settings.category] = []
							_stamp_categories[config.settings.category].append({"id": config.id})
							#_stamp_categories[config.settings.category].sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
							configs.append(config)
		file_name = dir.get_next()

	dir.list_dir_end()
	
	if configs:
		configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		add_stamp_configs(configs)


func encode_stamp(_sub_viewport: SubViewport) -> Dictionary:
	return stamp_encoder.encode(stamp_layers, _sub_viewport)


func decode_stamp(stamp_data: Dictionary) -> void:
	stamp_decoder.decode(stamp_data)


func clear() -> void:
	stamp_layers.clear()


static func get_stamp_texture(stamp_id: String) -> Texture2D:
	var not_found_stamp_texture = ImageTexture.create_from_image(Image.load_from_file("res://blocks/notfoundstamp.png"))
	if stamp_id not in _stamp_lookup:
		return not_found_stamp_texture
	var texture = null
	if _stamp_lookup[stamp_id].has("custom_texture"):
		texture = _load_custom_stamp_image(_stamp_lookup[stamp_id]["custom_texture"])
	elif _stamp_lookup[stamp_id].has("atlas_coords"):
		texture = AtlasTexture.new()
		texture.atlas = _stamp_textures[_stamp_lookup[stamp_id]["texture_path"]]
		texture.region = Rect2i((Settings.tile_size * _stamp_lookup[stamp_id].atlas_coords), Settings.tile_size)
		texture.filter_clip = true
	else:
		texture = _stamp_textures[_stamp_lookup[stamp_id]["texture_path"]]
	return texture


static func add_block_stamps():
	_stamp_categories["blocks"] = []
	var block_stamps: Dictionary = {
		"classic_basic1": BlockManager._block_lookup.get("1", {}),
		"classic_basic2": BlockManager._block_lookup.get("2", {}),
		"classic_basic3": BlockManager._block_lookup.get("3", {}),
		"classic_basic4": BlockManager._block_lookup.get("4", {}),
		"classic_brick": BlockManager._block_lookup.get("5", {}),
		"classic_arrowdown": BlockManager._block_lookup.get("6", {}),
		"classic_arrowup": BlockManager._block_lookup.get("7", {}),
		"classic_arrowleft": BlockManager._block_lookup.get("8", {}),
		"classic_arrowright": BlockManager._block_lookup.get("9", {}),
		"classic_mine": BlockManager._block_lookup.get("10", {}),
		"classic_item": BlockManager._block_lookup.get("11", {}),
		"classic_start": BlockManager._block_lookup.get("12", {}),
		"classic_bounce": BlockManager._block_lookup.get("13", {}),
		"classic_change": BlockManager._block_lookup.get("14", {}),
		"classic_hurt": BlockManager._block_lookup.get("15", {}),
		"classic_ice": BlockManager._block_lookup.get("16", {}),
		"classic_finish": BlockManager._block_lookup.get("17", {}),
		"classic_crumble": BlockManager._block_lookup.get("18", {}),
		"classic_vanish": BlockManager._block_lookup.get("19", {}),
		"classic_move": BlockManager._block_lookup.get("20", {}),
		"classic_water": BlockManager._block_lookup.get("21", {}),
		"classic_rotateright": BlockManager._block_lookup.get("22", {}),
		"classic_rotateleft": BlockManager._block_lookup.get("23", {}),
		"classic_push": BlockManager._block_lookup.get("24", {}),
		"classic_safety": BlockManager._block_lookup.get("25", {}),
		"classic_iteminfinite": BlockManager._block_lookup.get("26", {}),
		"classic_happy": BlockManager._block_lookup.get("27", {}),
		"classic_sad": BlockManager._block_lookup.get("28", {}),
		"classic_heart": BlockManager._block_lookup.get("29", {}),
		"classic_time": BlockManager._block_lookup.get("30", {}),
		"classic_minionegg": BlockManager._block_lookup.get("31", {}),
		"classic_customstats": BlockManager._block_lookup.get("32", {}),
		"classic_teleport": BlockManager._block_lookup.get("33", {}),
		"classic_gear": BlockManager._block_lookup.get("34", {}),
		"classic_presence": BlockManager._block_lookup.get("35", {}),
		"classic_sun": BlockManager._block_lookup.get("36", {}),
		"classic_moon": BlockManager._block_lookup.get("37", {}),
		"classic_firefly": BlockManager._block_lookup.get("38", {}),
		"classic_appear": BlockManager._block_lookup.get("39", {}),
		"classic_enlarge": BlockManager._block_lookup.get("40", {}),
		"classic_shrink": BlockManager._block_lookup.get("41", {}),
		"classic_sticky": BlockManager._block_lookup.get("42", {}),
		"classic_sniper": BlockManager._block_lookup.get("43", {}),
		"portable_block": BlockManager._block_lookup.get("portable_block", {}),
		"portable_mine": BlockManager._block_lookup.get("portable_mine", {}),
	}
	var converted_configs = []
	var block_stamp_keys = block_stamps.keys()
	for block_stamp in block_stamp_keys.size():
		if block_stamps[block_stamp_keys[block_stamp]].has("texture_path") and block_stamps[block_stamp_keys[block_stamp]].has("atlas_coords"):
			var config = {
				"id": block_stamp_keys[block_stamp],
				"settings": {
					"title": block_stamps[block_stamp_keys[block_stamp]].get("title", "Block Stamp " + str(block_stamp)),
					"comment": "",
					"category": "blocks"
				},
				"image": {
					"src": block_stamps[block_stamp_keys[block_stamp]].texture_path,
					"atlas_coords": block_stamps[block_stamp_keys[block_stamp]].atlas_coords
				}
			}
			_stamp_categories["blocks"].append({"id": block_stamp_keys[block_stamp]})
			converted_configs.append(config)
	add_stamp_configs(converted_configs)
