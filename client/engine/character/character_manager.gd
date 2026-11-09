extends Node
class_name CharacterManager

@onready var character_layers: CharacterLayers = $CharacterLayers
@onready var character_decoder: CharacterDecoder = $CharacterDecoder
@onready var character_encoder: CharacterEncoder = $CharacterEncoder

static var parts_check = {"head": ["head"], "body": ["body"], "feet": ["foot_front", "foot_back"]}
static var part_texture_list = ["color", "lines", "epic_color", "misc1", "misc2"]
static var _parts_categories: Dictionary = {}  # contains stamp categories with their stamp ids
static var _parts_lookup: Dictionary = {}  # stamp_id → {id: String, comment: String, category: String}
static var _parts_textures: Dictionary = {}
static var not_found_part_texture = null
static var loading_part_texture = null


## Initialize CharacterManager. Right now all it does is initalize getting the "not_found" and "loading" character.
static func init() -> void:
	not_found_part_texture = load_part_texture("res://character_display/parts/notfoundcharacter.png")
	loading_part_texture = load_part_texture("res://character_display/parts/loadingcharacter.png")
	load_default_part_configs()


## Load character from path without godot throwing a warning
static func load_part_texture(path: String) -> ImageTexture:
	var image = Image.new()
	image.load(ProjectSettings.globalize_path(path))
	return ImageTexture.create_from_image(image)


## Adds character configs to CharacterManager
static func add_part_configs(configs: Array) -> void:
	# Build lookup table: character_id → character info
	_build_part_lookup(configs)


static func _load_custom_part_image(custom_image_dictionary: Dictionary) -> Image:
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
		push_warning("Couldn't load character image. :(")
		image = Image.load_from_file("res://character_display/parts/notfoundcharacter.png")
	return image


## Build the part_id → part location mapping
static func _build_part_lookup(configs: Array) -> void:
	for config in configs:
		if not config.has("id") or not (config.has("head") or config.has("body") or config.has("feet")):
			continue
		get_part_for_part_lookup(config, "head", "head")
		get_part_for_part_lookup(config, "body", "body")
		get_part_for_part_lookup(config, "feet", "foot_front")
		get_part_for_part_lookup(config, "feet", "foot_back")


static func get_part_for_part_lookup(config: Dictionary, part: String, image_location: String):
	if !config.has(part) or !config[part].has("id"):
		return
	var character_id: String = config[part].id
	var part_path = image_location + "_image"
	var custom_part_path = "custom_" + image_location + "_image"
	if config[part].has(custom_part_path) or config[part].has(part_path):
		if config[part].has(custom_part_path):
			for texture_name in part_texture_list:
				if config[part][custom_part_path].has(texture_name):
					# Loads compressed image using these variables and shows the notfound character graphic if it can't.
					var custom_part_image = _load_custom_part_image(config[part][custom_part_path][texture_name])
					var custom_part_texture = null
					custom_part_texture = ImageTexture.create_from_image(custom_part_image)
					if !_parts_lookup.has(character_id):
						_parts_lookup[character_id] = {}
					if !_parts_lookup[character_id].has(part):
						_parts_lookup[character_id][part] = {}
					_parts_lookup[character_id][part] = {
						"custom_" + texture_name + "_texture": custom_part_texture
					}
		else:
			# Load character image from a file location.
			for texture_name in part_texture_list:
				var texture_path: String = config[part][part_path].get(texture_name + "_src", "")
				if texture_path and FileAccess.file_exists(texture_path):
					if texture_path not in _parts_textures:
						_parts_textures[texture_path] = load_part_texture(texture_path)
				else:
					continue

				# Store the mapping
				if !_parts_lookup.has(character_id):
					_parts_lookup[character_id] = {}
				if !_parts_lookup[character_id].has(part):
					_parts_lookup[character_id][part] = {}
				_parts_lookup[character_id][part] = {
					texture_name + "_texture_path": texture_path
				}

		var title = "Character"
		var comment = ""
		if config[part].has("settings") and config[part].settings.has("title"):
			title = config[part].settings.title
		if config[part].has("settings") and config[part].settings.has("comment"):
			comment = config[part].settings.comment

		# Assumes the character is a custom character since category is
		# only initalized through load_default_block_configs
		var category = "custom"
		if config[part].has("category"):
			category = config[part].category

		# Store additional character info
		_parts_lookup[character_id][part]["title"] = title
		_parts_lookup[character_id][part]["comment"] = comment
		_parts_lookup[character_id][part]["settings"] = config.settings
		_parts_lookup[character_id][part]["category"] = category


static func load_default_part_configs():
	var configs: Array = []
	var dir_location = "res://character_display/parts"
	var dir := DirAccess.open(dir_location)

	if not dir:
		push_error("Failed to open character_display/parts directory")
		return configs
	
	var files = DirAccess.get_directories_at(dir_location)
	for file in files:
		var maybe_json_file = dir_location + "/" + file + "/" + file + ".json"
		if FileAccess.file_exists(maybe_json_file):
			var config := {}
			var config_file := FileAccess.open(maybe_json_file, FileAccess.READ)
			if not config_file:
				push_error("Failed to open config file: " + maybe_json_file)
				return
			var config_json := config_file.get_as_text()
			config_file.close()
			config = JSON.parse_string(config_json)
			if config == null:
				push_error("Failed to parse JSON from: " + maybe_json_file)
				return
			if not config.is_empty():
				for part_check in parts_check:
					for part in parts_check[part_check]:
						if config.has(part_check) and (config[part_check].has("custom_" + part + "_image") or config.image.has(part + "_image")):
							if config[part_check].has("settings") and !config[part_check].settings.has("category"):
								config.settings["category"] = "default"
							if !_parts_categories[part_check].has(config[part_check].settings.category):
								_parts_categories[part_check][config[part_check].settings.category] = []
							_parts_categories[part_check][config[part_check].settings.category].append({"id": config[part_check].id})
							#_stamp_categories[config.settings.category].sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
							configs.append(config)

	if configs:
		#configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
		add_part_configs(configs)


func encode_character(_sub_viewport: SubViewport) -> Dictionary:
	return character_encoder.encode(character_layers, _sub_viewport)


func decode_character(character_data: Dictionary) -> void:
	character_decoder.decode(character_data)


func clear() -> void:
	character_layers.clear()


static func get_part_textures(character_id: String) -> Dictionary:
	var character_part_textures = {}
	for part_check in parts_check:
		for part in part_check:
			character_part_textures[part] = {}
			for part_texture in part_texture_list:
				character_part_textures[part][part_texture] = not_found_part_texture
	if !_parts_lookup.has(character_id):
		return character_part_textures
	for part_check in parts_check:
		for part in parts_check[part_check]:
			for part_texture in part_texture_list:
				var custom_part_texture_path = "custom_" + part_texture + "_texture"
				var part_texture_path = part_texture + "_texture_path"
				if !_parts_lookup[character_id][part].has(custom_part_texture_path) and !_parts_lookup[character_id][part].has(part_texture_path):
					continue
				if _parts_lookup[character_id][part].has(custom_part_texture_path):
					character_part_textures[part_texture] = _load_custom_part_image(_parts_lookup[character_id][part][custom_part_texture_path])
				else:
					character_part_textures[part_texture] = _parts_lookup[character_id][part][part_texture_path]
	return character_part_textures
