extends Node
class_name BlockManager

@onready var layers: Layers = $Layers
@onready var block_decoder = null #: BlockDecoder = $BlockDecoder
@onready var block_encoder = null #: BlockEncoder = $BlockEncoder


func _ready() -> void:
	pass


func encode_block() -> Dictionary:
	#return block_encoder.encode(layers, self)
	return {}


func decode_level(level_data: Dictionary, is_editor: bool) -> void:
	#block_decoder.decode(block_data, layers)
	pass


func clear() -> void:
	layers.clear()


func calc_used_rect() -> void:
	layers.calc_used_rect()


func set_settings(new_settings: Dictionary):
	pass
