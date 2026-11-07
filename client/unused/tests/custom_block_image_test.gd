extends Node2D

@onready var encoded_block_data_text = $EncodedBlockDataText
@onready var sub_viewport = $SubViewportContainer/SubViewport
@onready var decoded_block_texture = $DecodedBlockTexture
@onready var encode_and_decode_button = $EncodeAndDecodeButton

var encoded_block_data: PackedByteArray = []


func _ready() -> void:
	encode_and_decode_button.pressed.connect(_encode_and_decode_block_image)


func _encode_and_decode_block_image() -> void:
	await RenderingServer.frame_post_draw
	var buffer_size = sub_viewport.get_texture().get_image().get_data().size()
	var width = sub_viewport.get_texture().get_image().get_width()
	var height = sub_viewport.get_texture().get_image().get_height()
	var format = sub_viewport.get_texture().get_image().get_format()
	var has_mipmaps = sub_viewport.get_texture().get_image().has_mipmaps()
	encoded_block_data = sub_viewport.get_texture().get_image().get_data().compress(3)
	var block_image = Image.create_from_data(width, height, has_mipmaps, format, encoded_block_data.decompress(buffer_size, 3))
	var block_texture = ImageTexture.create_from_image(block_image)
	decoded_block_texture.texture = block_texture
