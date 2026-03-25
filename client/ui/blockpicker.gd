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

const STYLE_LIST: Array = [6, 1, 2, 3, 5, 4, 0, 0]
const BLOCK_LIST: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 35, 36, 37, 38, 39, 40, 41, 42, 43]

var texture: Texture2D = preload("res://tiles/tileatlas.png")
var custom_stats_popup = preload("res://popups/customstatsoptionspopup.tscn")
var stats_popup = preload("res://popups/statsoptionspopup.tscn")
var teleport_popup = preload("res://popups/teleportoptionspopup.tscn")
var block_picker_focused: bool = false
var block_row_list: Array
var current_tab: int
var block_picker_pages: int = 1
var block_picker_page: int = 1
var current_block_list: Array = []
var custom_block_list: Array = []


func _ready() -> void:
	block_row_list = [block_picker_block_row_1, block_picker_block_row_2, block_picker_block_row_3, block_picker_block_row_4, block_picker_block_row_5]
	navigation.set_align("right")
	navigation.connect("set_page", _on_set_page)
	_update_block_list_display()
	current_tab = tab_bar.current_tab


func _physics_process(delta: float) -> void:
	if current_tab != tab_bar.current_tab:
		_update_block_list_display()
	current_tab = tab_bar.current_tab
	for node in block_container.get_children():
		_check_clicked_button(node)
		
	
func _update_block_list_display():
	current_block_list = []
	# print(tab_bar.current_tab)
	for child in block_container.get_children():
		child.free()
	block_picker_pages = 1
	var page_counter: int = 1
	if tab_bar.current_tab == 7:
		pass # custom blocks code goes here
	else:
		var full_block_list = BLOCK_LIST
		while (50 * page_counter) < BLOCK_LIST.size():
			block_picker_pages += 1
			page_counter += 1
		current_block_list = full_block_list.slice((50 * (block_picker_page - 1)), (50 * block_picker_page))
		navigation.init(block_picker_page, block_picker_pages, 6, true)
	var block_gap = CoordinateUtils.seperator
	if !current_block_list.is_empty():
		no_blocks_text.visible = false
		navigation.init(block_picker_page, block_picker_pages, 6, true)
		for block in current_block_list.size():
			var tile_id = current_block_list[block]
			var true_tile_id = tile_id + (block_gap * STYLE_LIST[tab_bar.current_tab])
			var atlas_coords = CoordinateUtils.to_atlas_coords(true_tile_id)
			var coords = CoordinateUtils.to_atlas_coords(block + 1)
			var new_block_button = TextureButton.new()
			new_block_button.ignore_texture_size = true
			new_block_button.stretch_mode = 0
			new_block_button.texture_normal = AtlasTexture.new()
			new_block_button.texture_normal.atlas = texture
			new_block_button.texture_normal.region = Rect2((128 * atlas_coords.x), (128 * atlas_coords.y), 128, 128)
			new_block_button.size = Vector2(48, 48)
			new_block_button.global_position = Vector2(68 * coords.x, 68 * coords.y)
			new_block_button.pivot_offset = Vector2(new_block_button.size.x / 2, new_block_button.size.y / 2)
			new_block_button.focus_mode = 1
			new_block_button.name = "BlockButton" + str(block)
			new_block_button.tooltip_text = CoordinateUtils.get_description(CoordinateUtils.to_true_block_id(true_tile_id))
			new_block_button.button_down.connect(_click_block.bind(tile_id + (100 * STYLE_LIST[tab_bar.current_tab]), atlas_coords))
			new_block_button.pressed.connect(_set_current_block.bind(tile_id + (100 * STYLE_LIST[tab_bar.current_tab]), atlas_coords))
			block_container.add_child(new_block_button)
			if current_block_list[block] == 33:
				var default_teleport_color = TextureRect.new()
				var teleport_atlas_coords = CoordinateUtils.to_atlas_coords(34 + (block_gap * STYLE_LIST[tab_bar.current_tab]))
				default_teleport_color.ignore_texture_size = true
				default_teleport_color.stretch_mode = 0
				default_teleport_color.texture = AtlasTexture.new()
				default_teleport_color.texture.atlas = texture
				default_teleport_color.texture.region = Rect2((128 * teleport_atlas_coords.x), (128 * teleport_atlas_coords.y), 128, 128)
				default_teleport_color.size = Vector2(48, 48)
				default_teleport_color.name = "TeleportBlockColor"
				default_teleport_color.self_modulate = Color("E22B2EFF")
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


func _click_block(block_id: int, block_atlas_coords: Vector2) -> void:
	var block_data: Dictionary = {
		"block_id": block_id,
		"block_atlas_coords": block_atlas_coords
	}
	var block_options = null
	if CoordinateUtils.to_true_block_id(block_data.block_id) == 27 or CoordinateUtils.to_true_block_id(block_data.block_id) == 28:
		block_options = TileOptions.new()
		block_options.option = StatsOptions.new()
		block_options.set_popup(stats_popup)
		block_data.get_or_add("block_options", block_options)
	elif CoordinateUtils.to_true_block_id(block_data.block_id) == 32:
		block_options = TileOptions.new()
		block_options.option = CustomStatsOptions.new()
		block_options.set_popup(custom_stats_popup)
		block_data.get_or_add("block_options", block_options)
	elif CoordinateUtils.to_true_block_id(block_data.block_id) == 33:
		block_options = TileOptions.new()
		block_options.option = TeleportOptions.new()
		block_options.set_popup(teleport_popup)
		block_data.get_or_add("block_options", block_options)
		var teleport_colorin_coords = CoordinateUtils.to_atlas_coords(block_data.block_id + 1)
		block_data.get_or_add("teleport_colorin_coords", teleport_colorin_coords)
		var teleport_color = "E22B2E"
		block_data.get_or_add("teleport_color", teleport_color)
	emit_signal("block_clicked", block_data)


func _set_current_block(block_id: int, block_atlas_coords: Vector2) -> void:
	var block_data: Dictionary = {
		"block_id": block_id,
		"block_atlas_coords": block_atlas_coords
	}
	var block_options = null
	if CoordinateUtils.to_true_block_id(block_data.block_id) == 27 or CoordinateUtils.to_true_block_id(block_data.block_id) == 28:
		block_options = TileOptions.new()
		block_options.option = StatsOptions.new()
		block_options.set_popup(stats_popup)
		block_data.get_or_add("block_options", block_options)
	elif CoordinateUtils.to_true_block_id(block_data.block_id) == 32:
		block_options = TileOptions.new()
		block_options.option = CustomStatsOptions.new()
		block_options.set_popup(custom_stats_popup)
		block_data.get_or_add("block_options", block_options)
	elif CoordinateUtils.to_true_block_id(block_data.block_id) == 33:
		block_options = TileOptions.new()
		block_options.option = TeleportOptions.new()
		block_options.set_popup(teleport_popup)
		block_data.get_or_add("block_options", block_options)
		var teleport_colorin_coords = CoordinateUtils.to_atlas_coords(block_data.block_id + 1)
		block_data.get_or_add("teleport_colorin_coords", teleport_colorin_coords)
		var teleport_color = "E22B2E"
		block_data.get_or_add("teleport_color", teleport_color)
	emit_signal("change_selected_block", block_data)


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
	_update_block_list_display()
