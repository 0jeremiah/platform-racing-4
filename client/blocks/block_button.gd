extends Control

signal block_clicked
signal block_selected

@onready var block_button = $BlockButton
@onready var teleport_block = $BlockButton/TeleportBlock
var id: String = ""
var settings: Dictionary = {}
var block_size: float = 48.0
var send_data: bool = true


func _ready() -> void:
	block_button.button_down.connect(click_block)
	block_button.pressed.connect(select_block)


func init(block_id: String, block_settings: Dictionary):
	if block_id in BlockManager._blocks:
		id = block_id
		settings = block_settings
		teleport_block.visible = false
		block_button.texture_normal = BlockManager.get_block_texture(id)
		var block_instance = BlockManager._blocks[id]
		if block_instance.settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
			teleport_block.visible = true
			teleport_block.texture = BlockManager.get_block_teleport_texture(id)
			teleport_block.self_modulate = block_instance.settings.teleport_color


func click_block():
	if id:
		emit_signal("block_clicked", {"id": id, "settings": settings})


func select_block():
	if id:
		emit_signal("block_selected", {"id": id, "settings": settings})


func _process(_delta: float) -> void:
	custom_minimum_size = Vector2(block_size * 1.25, block_size * 1.25)
	block_button.size = Vector2(block_size, block_size)
	block_button.pivot_offset = Vector2(block_button.size.x / 2, block_button.size.y / 2)
	size = Vector2(block_size * 1.25, block_size * 1.25)
	block_button.position = Vector2((size.x - block_button.size.x) / 2, (size.y - block_button.size.y) / 2)
	if block_button.visible and block_button.is_hovered():
		if block_button.is_pressed():
			block_button.scale = Vector2(1, 1)
			block_button.self_modulate = Color(0.75, 0.75, 0.75)
		else:
			block_button.scale = Vector2(1.25, 1.25)
			block_button.self_modulate = Color(1.25, 1.25, 1.25)
	else:
		block_button.scale = Vector2(1, 1)
		block_button.self_modulate = Color(1, 1, 1)
