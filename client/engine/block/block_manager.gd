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


func set_settings(new_settings: Dictionary):
	pass
