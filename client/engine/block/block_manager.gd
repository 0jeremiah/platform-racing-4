extends Node
class_name BlockManager

@onready var block_layers: BlockLayers = $BlockLayers
@onready var block_decoder: BlockDecoder = $BlockDecoder
@onready var block_encoder: BlockEncoder = $BlockEncoder


func _ready() -> void:
	pass


func encode_block() -> Dictionary:
	return block_encoder.encode(block_layers, self)


func decode_block(block_data: Dictionary, is_editor: bool) -> void:
	block_decoder.decode(block_data, block_layers)


func clear() -> void:
	block_layers.clear()


static func _load_default_block_configs() -> Array:
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
				#print("Loaded config: %s (id: %s)" % [file_name, config.get("id", "unknown")])
		file_name = dir.get_next()

	dir.list_dir_end()
	
	configs.sort_custom(func(a, b): return str(a.id).naturalnocasecmp_to(str(b.id)) < 0)
	
	return configs


func set_settings(new_settings: Dictionary):
	pass
