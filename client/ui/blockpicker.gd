extends Control

signal block_clicked
signal change_selected_block

@onready var block_picker_panel = $BlockPickerPanel
@onready var tab_bar = $TabBar
@onready var navigation = $Navigation
@onready var light_color_rect = $LightColorRect
@onready var dark_color_rect = $DarkColorRect
@onready var block_picker_block_row_1 = $BlockContainer/BlockRow1
@onready var block_picker_block_row_2 = $BlockContainer/BlockRow2
@onready var block_picker_block_row_3 = $BlockContainer/BlockRow3
@onready var block_picker_block_row_4 = $BlockContainer/BlockRow4
@onready var block_picker_block_row_5 = $BlockContainer/BlockRow5
@onready var block_container = $BlockContainer
@onready var no_blocks_text = $NoBlocksText

var texture: Texture2D = preload("res://tiles/tileatlas.png")
var selected_category: String = "pr4"
var block_picker_pages: int = 1
var block_picker_page: int = 1
var current_block_list: Array = []


func _ready() -> void:
	navigation.set_align("right")
	navigation.connect("set_page", _on_set_page)
	_update_block_list_display(selected_category)
	tab_bar.tab_changed.connect(_change_tab)


func _process(_delta: float) -> void:
	for node in block_container.get_children():
		_check_clicked_button(node)
		
	
func _change_tab(new_index: int):
	match new_index:
		0: selected_category = "pr4"
		1: selected_category = "desert"
		2: selected_category = "industrial"
		3: selected_category = "jungle"
		4: selected_category = "underwater"
		5: selected_category = "space"
		6: selected_category = "pr2"
		7: selected_category = "custom"
	_update_block_list_display(selected_category)


func _update_block_list_display(selected_category: String):
	var selected_block_category = BlockManager._blocks_categories.get(selected_category, [])
	current_block_list = []
	for child in block_container.get_children():
		child.free()
	block_picker_pages = 1
	var page_counter: int = 1
	var full_block_list = selected_block_category
	while (50 * page_counter) < selected_block_category.size():
		block_picker_pages += 1
		page_counter += 1
	current_block_list = full_block_list.slice((50 * (block_picker_page - 1)), (50 * block_picker_page))
	navigation.init(block_picker_page, block_picker_pages, 6, true)
	if !current_block_list.is_empty():
		no_blocks_text.visible = false
		navigation.init(block_picker_page, block_picker_pages, 6, true)
		for block in current_block_list.size():
			var tile_id = current_block_list[block].id
			var tile_settings = BlockManager._block_lookup[tile_id].settings
			var coords = Vector2i(block % 10, block / 10)
			var new_block_button = TextureButton.new()
			new_block_button.ignore_texture_size = true
			new_block_button.stretch_mode = 0
			new_block_button.texture_normal = BlockManager.get_block_texture(tile_id)
			new_block_button.size = Vector2(48, 48)
			new_block_button.global_position = Vector2i(68 * coords.x, 68 * coords.y)
			new_block_button.pivot_offset = Vector2(new_block_button.size.x / 2, new_block_button.size.y / 2)
			new_block_button.focus_mode = 1
			new_block_button.name = "BlockButton" + str(block)
			#new_block_button.tooltip_text = BlockManager._block_lookup[tile_id].title + "\n" + BlockManager._block_lookup[tile_id].comment
			new_block_button.button_down.connect(_click_block.bind(tile_id, tile_settings))
			new_block_button.pressed.connect(_set_current_block.bind(tile_id, tile_settings))
			block_container.add_child(new_block_button)
			var block_instance = BlockManager._blocks[tile_id]
			if block_instance.settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
				var default_teleport_color = TextureRect.new()
				default_teleport_color.ignore_texture_size = true
				default_teleport_color.stretch_mode = 0
				default_teleport_color.texture = BlockManager.get_block_teleport_texture(tile_id)
				default_teleport_color.size = Vector2(48, 48)
				default_teleport_color.name = "TeleportBlockColor"
				default_teleport_color.self_modulate = Color(block_instance.settings.teleport_color)
				default_teleport_color.show_behind_parent = true
				new_block_button.add_child(default_teleport_color)
	else:
		no_blocks_text.visible = true
		navigation.init(1, 0, 6, false)
		
	var block_rows = 1
	while 10 * block_rows < current_block_list.size():
		block_rows += 1
	dark_color_rect.size.y = 68 * block_rows
	light_color_rect.size.y = (68 * block_rows) + 10
	block_picker_panel.size.y = light_color_rect.position.y + light_color_rect.size.y + 20
	no_blocks_text.position.x = light_color_rect.position.x + ((light_color_rect.size.x - no_blocks_text.size.x) / 2)
	no_blocks_text.position.y = light_color_rect.position.y + ((light_color_rect.size.y - no_blocks_text.size.y) / 2)
	size = block_picker_panel.size


func _click_block(block_id: String, block_settings: Dictionary = {}) -> void:
	emit_signal("block_clicked", block_id, block_settings)


func _set_current_block(block_id: String, block_settings: Dictionary = {}) -> void:
	emit_signal("change_selected_block", block_id, block_settings)


func _on_set_page(new_page_number: int):
	_set_page(false, clamp(new_page_number, 1, block_picker_pages))


func _check_clicked_button(node: Node):
	if node is TextureButton:
		if node.visible and node.is_hovered():
			if node.is_pressed():
				node.scale = Vector2(1, 1)
				node.self_modulate = Color(0.75, 0.75, 0.75)
			else:
				node.scale = Vector2(1.25, 1.25)
				node.self_modulate = Color(1.25, 1.25, 1.25)
		else:
			node.scale = Vector2(1, 1)
			node.self_modulate = Color(1, 1, 1)


func _set_page(incordec: bool, new_page_number: int):
	if incordec:
		block_picker_page += new_page_number
	else:
		block_picker_page = new_page_number
	_update_block_list_display(selected_category)
