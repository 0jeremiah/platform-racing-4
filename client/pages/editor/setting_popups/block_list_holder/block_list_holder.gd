extends Control

signal block_list_changed

@onready var block_pattern_color_rect = $BlockPatternColorRect
@onready var scroll_container = $ScrollContainer
@onready var blocks_container = $ScrollContainer/BlocksContainer
@onready var selected_block_texture = $SelectedBlockTexture
@onready var teleport_colorin_texture = $SelectedBlockTexture/TeleportColorinTexture

var block_button = preload("res://blocks/block_button.tscn")
var block_list_size: Vector2 = Vector2(430.0, 248.0)
var block_list: Array = []
var quick_click_timer: float = 0.3
var quick_click: bool = false
var from_block_picker: bool = true
var block_picker_rect = Rect2(Vector2(0.0, 0.0), Vector2(0.0, 0.0))
var old_mouse_position: Vector2 = Vector2(0, 0)
var check_if_not_clicking: bool = false
var selected_block_id: String = ""
var max_blocks: int = 150
var allow_duplicate_blocks: bool = true


func init(new_block_list: Array):
	block_list = new_block_list.slice(0, max_blocks)
	if !allow_duplicate_blocks:
		remove_duplicate_blocks()
	_update_block_list()


func _process(delta: float) -> void:
	if check_if_not_clicking:
		selected_block_texture.global_position = get_global_mouse_position() - Vector2(selected_block_texture.size.x / 2, selected_block_texture.size.y / 2)
		var block_dropoff_position = Vector2(round(blocks_container.get_local_mouse_position().x / 68), int(blocks_container.get_local_mouse_position().y / 68))
		if quick_click_timer - delta <= 0:
			quick_click = false
			quick_click_timer = 0.0
		else:
			quick_click_timer -= delta
		if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if quick_click:
				if (from_block_picker and block_picker_rect.has_point(get_global_mouse_position())) or (blocks_container.get_local_mouse_position() != old_mouse_position and Rect2(Vector2.ZERO, scroll_container.size).has_point(scroll_container.get_local_mouse_position())):
					_maybe_add_block(selected_block_id)
			elif Rect2(Vector2.ZERO, scroll_container.size).has_point(scroll_container.get_local_mouse_position()):
				var block_index = int(block_dropoff_position.x + (blocks_container.columns * block_dropoff_position.y))
				if block_index < block_list.size():
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
		child.queue_free()
	for block in block_list.size():
		var tile_settings = BlockManager._block_lookup[block_list[block]].settings
		var new_block_button = block_button.instantiate()
		new_block_button.send_data = false
		var _block_data = {
			"id": block_list[block],
			"index": block
			}
		new_block_button.block_clicked.connect(_select_block.bind(_block_data))
		blocks_container.add_child(new_block_button)
		new_block_button.init(block_list[block], tile_settings)


func _select_block(block_data: Dictionary):
	block_list.remove_at(block_data.index)
	_update_block_list()
	block_data.erase("index")
	quick_click = true
	old_mouse_position = blocks_container.get_local_mouse_position()
	_drag_block(block_data, false)
	check_if_not_clicking = true


func _drag_block(block_data: Dictionary, _from_block_picker: bool = true) -> void:
	# blockpicker returns block id and block settings but we only need block id (i'm not adding customizable
	# settings to change settings ui dawg)
	from_block_picker = _from_block_picker
	quick_click = true
	selected_block_id = block_data.id
	update_block_icon(block_data.id)
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


func _maybe_add_block(id: String, index: int = block_list.size()):
	if allow_duplicate_blocks or (!allow_duplicate_blocks and !block_list.has(id)):
		if block_list.size() < max_blocks:
			block_list.insert(index, id)
			emit_signal("block_list_changed", block_list)
		_update_block_list()


func set_max_blocks(new_max_blocks: int):
	max_blocks = new_max_blocks
	if block_list.size() > max_blocks:
		block_list.slice(0, max_blocks)
	_update_block_list()


func set_allow_duplicate_blocks(new_allow_duplicate_blocks: bool):
	allow_duplicate_blocks = new_allow_duplicate_blocks
	if !allow_duplicate_blocks:
		remove_duplicate_blocks()
	_update_block_list()


func remove_duplicate_blocks():
	var clean_block_list = []
	for block in block_list:
		if block not in clean_block_list:
			clean_block_list.append(block)
	block_list = clean_block_list


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


func set_block_pattern_size(new_size: Vector2):
	block_list_size = Vector2(max(new_size.x, 80.0), max(new_size.y, 68.0))
	blocks_container.columns = (int(block_list_size.x) / 68) + 1
	scroll_container.size = Vector2(block_list_size.x, block_list_size.y)
	block_pattern_color_rect.size = scroll_container.size


func set_block_picker_rect(block_picker_info: Dictionary):
	block_picker_rect = Rect2(block_picker_info.position, block_picker_info.size)
