extends Control

signal change_settings_changed

@onready var tick_box = $TickBox
@onready var scroll_container = $ScrollContainer
@onready var blocks_container = $ScrollContainer/BlocksContainer
@onready var block_picker = $BlockPicker
@onready var selected_block_texture = $SelectedBlockTexture
@onready var teleport_colorin_texture = $SelectedBlockTexture/TeleportColorinTexture

var tile_atlas = preload("res://tiles/tileatlas.png")
var change_tick: float = ConfigurableBlockSettings.default_properties.change_tick
var change_pattern: Array = ConfigurableBlockSettings.default_properties.change_pattern
var quick_click_timer: float = 0.3
var quick_click: bool = false
var from_block_picker: bool = true
var old_mouse_position: Vector2 = Vector2(0, 0)
var check_if_not_clicking: bool = false
var selected_block_id: String = ""


func _ready() -> void:
	BlockManager.load_default_block_configs()
	tick_box.init("float", str(change_tick), 0.0, 99999999.9)
	tick_box.return_line.connect(_update_tick)
	block_picker.block_clicked.connect(_drag_block)
	_update_block_list()


func _process(delta: float) -> void:
	if check_if_not_clicking:
		selected_block_texture.global_position = get_global_mouse_position() - Vector2(selected_block_texture.size.x / 2, selected_block_texture.size.y / 2)
		var block_dropoff_position = Vector2(round(blocks_container.get_local_mouse_position().x / 58), int(blocks_container.get_local_mouse_position().y / 58))
		if quick_click_timer - delta <= 0:
			quick_click = false
			quick_click_timer = 0.0
		else:
			quick_click_timer -= delta
		if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if quick_click:
				if (from_block_picker and Rect2(Vector2.ZERO, block_picker.size).has_point(block_picker.get_local_mouse_position())) or (blocks_container.get_local_mouse_position() != old_mouse_position and Rect2(Vector2.ZERO, scroll_container.size).has_point(scroll_container.get_local_mouse_position())):
					_maybe_add_block(selected_block_id)
			elif Rect2(Vector2.ZERO, scroll_container.size).has_point(scroll_container.get_local_mouse_position()):
				var block_index = int(block_dropoff_position.x + (blocks_container.columns * block_dropoff_position.y))
				if block_index < change_pattern.size():
					_maybe_add_block(selected_block_id, block_index)
				else:
					_maybe_add_block(selected_block_id)
			teleport_colorin_texture.visible = false
			selected_block_texture.visible = false
			check_if_not_clicking = false
			quick_click_timer = 0.3
			quick_click = false
			selected_block_id = ""
	for node in blocks_container.get_children():
		_check_clicked_button(node)



func _update_block_list():
	for child in blocks_container.get_children():
		child.free()
	for block in change_pattern.size():
		var block_container = Control.new()
		block_container.size = Vector2(58, 58)
		block_container.custom_minimum_size = Vector2(58, 58)
		var block_button = TextureButton.new()
		block_button.ignore_texture_size = true
		block_button.stretch_mode = 0
		block_button.texture_normal = BlockManager.get_block_texture(change_pattern[block])
		block_button.size = Vector2(48, 48)
		block_button.position = Vector2(5, 5)
		block_button.pivot_offset = Vector2(block_button.size.x / 2, block_button.size.y / 2)
		var _block_data = {
			"block_id": change_pattern[block],
			"block_index": block
			}
		block_container.add_child(block_button)
		blocks_container.add_child(block_container)
		block_button.button_down.connect(_select_block.bind(_block_data))


func _update_tick(new_change_tick: float) -> void:
	change_tick = new_change_tick
	emit_signal("change_settings_changed", {"change_tick": change_tick, "change_pattern": change_pattern})


func _select_block(block_data: Dictionary):
	change_pattern.remove_at(block_data.block_index)
	_update_block_list()
	block_data.erase("block_index")
	quick_click = true
	old_mouse_position = blocks_container.get_local_mouse_position()
	_drag_block(block_data.block_id, false)
	check_if_not_clicking = true


func _drag_block(block_id: String, _from_block_picker: bool = true) -> void:
	from_block_picker = _from_block_picker
	quick_click = true
	selected_block_id = block_id
	update_block_icon(block_id)
	_update_block_list()
	check_if_not_clicking = true


func update_block_icon(block_id: String):
	selected_block_texture.global_position = get_global_mouse_position() - Vector2(selected_block_texture.size.x / 2, selected_block_texture.size.y / 2)
	teleport_colorin_texture.visible = false
	selected_block_texture.visible = true
	selected_block_texture.texture = BlockManager.get_block_texture(block_id)
	var block_instance = BlockManager._blocks[block_id] if block_id in BlockManager._blocks else null
	if block_instance and block_instance.settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		teleport_colorin_texture.visible = true
		teleport_colorin_texture.texture = BlockManager.get_block_teleport_texture(block_id)
		teleport_colorin_texture.self_modulate = Color( block_instance.settings.teleport_color + "7F")


func _maybe_add_block(id: String, index: int = change_pattern.size()):
	if change_pattern.size() < 150:
		change_pattern.insert(index, id)
		emit_signal("change_settings_changed", {"change_tick": change_tick, "change_pattern": change_pattern})
	_update_block_list()


func _check_clicked_button(node: Node):
	if node.get_child(0) is TextureButton:
		var button = node.get_child(0)
		if button.visible and button.is_hovered():
			if button.is_pressed():
				button.scale = Vector2(1, 1)
				button.self_modulate = Color(0.75, 0.75, 0.75)
			else:
				button.scale = Vector2(1.25, 1.25)
				button.self_modulate = Color(1.25, 1.25, 1.25)
		else:
			button.scale = Vector2(1, 1)
			button.self_modulate = Color(1, 1, 1)


func set_settings(new_settings: Dictionary):
	if new_settings.has("change_tick"):
		change_tick = new_settings.change_tick
	if new_settings.has("change_pattern"):
		change_pattern = new_settings.change_pattern
		_update_block_list()
