extends Control

signal control_event

@onready var block_menu = $BlockMenu
@onready var selection_glow = $BlockMenu/SelectionGlow
@onready var block_mover_button = $BlockMenu/BlockMover/TextureButton
@onready var block_killer_button = $BlockMenu/BlockKiller/TextureButton
@onready var block_draw_panel = $BlockMenu/BlockDrawPanel
@onready var block_dropper_button = $BlockMenu/BlockDropper/TextureButton
@onready var block_draw_button = $BlockMenu/BlockDraw/TextureButton
@onready var block_draw_teleport_colorin = $BlockMenu/BlockDraw/TextureButton/TeleportColorin
@onready var block_picker_popup = $BlockMenu/BlockPickerPopup
@onready var block_picker = $BlockMenu/BlockPickerPopup/Blockpicker
@onready var block_options_panel = $BlockMenu/BlockOptionsPanel
@onready var block_options_node = $BlockMenu/BlockOptions
@onready var block_options_button = $BlockMenu/BlockOptions/TextureButton
@onready var block_options_popup = $BlockMenu/BlockOptions/BlockOptionsPopup
@onready var layer_panel = $LayerPanel

static var selected_block_id: int
static var selected_block_options: TileOptions
var active: bool = false
var layers: Node2D
var editor_events: EditorEvents
var texture: Texture2D = preload("res://tiles/tileatlas.png")
var selected_button: TextureButton
var custom_stats_popup = preload("res://popups/customstatsoptionspopup.tscn")
var stats_popup = preload("res://popups/statsoptionspopup.tscn")
var teleport_popup = preload("res://popups/teleportoptionspopup.tscn")


func _ready() -> void:
	block_mover_button.pressed.connect(_click_block_menu.bind(block_mover_button))
	block_killer_button.pressed.connect(_click_block_menu.bind(block_killer_button))
	block_dropper_button.pressed.connect(_click_block_menu.bind(block_dropper_button))
	if selected_block_id <= 0:
		selected_block_id = 1
	block_draw_button.pressed.connect(_show_block_picker)
	block_picker.connect("change_selected_block", _set_current_block)
	block_options_button.pressed.connect(_show_block_options)
	_click_block_menu(block_dropper_button)


func init() -> void:
	layer_panel.init(layers, "blocks")
	editor_events.connect_to([layer_panel])
	_set_current_block({"block_id": selected_block_id, "block_atlas_coords": CoordinateUtils.to_atlas_coords(selected_block_id)})


func deactivate():
	active = false


func activate():
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": "blocks"
	})
	active = true


func _physics_process(delta: float) -> void:
	if active:
		visible = true
		for child in block_menu.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
		if selected_button == block_dropper_button:
			block_draw_panel.visible = true
			block_draw_button.visible = true
			if selected_block_options != null:
				block_options_panel.visible = true
				block_options_node.visible = true
			else:
				block_options_panel.visible = false
				block_options_node.visible = false
		else:
			block_draw_panel.visible = false
			block_draw_button.visible = false
			block_options_panel.visible = false
			block_options_node.visible = false

		block_picker_popup.size = block_picker.size

		if selected_button:
			set_selection_glow()
	else:
		visible = false


func _set_current_block(block_data: Dictionary) -> void:
	selected_block_id = block_data.block_id
	var teleport_colorin_coords = Vector2i(-1, -1)
	var teleport_color = "FFFFFF"
	block_draw_teleport_colorin.visible = false
	for child in block_options_popup.get_node("PopupHolder").get_children():
		child.free()
	if block_data.has("block_options"):
		selected_block_options = block_data.block_options
		if block_data.block_options.option is StatsOptions:
			var popup = block_data.block_options.popup.instantiate()
			block_options_popup.get_node("PopupHolder").add_child(popup)
			var block_label = ""
			var description_label = ""
			if CoordinateUtils.to_true_block_id(selected_block_id) == 28:
				block_label = "Sad"
				description_label = "decrease"
			else:
				block_label = "Happy"
				description_label = "increase"
			popup.init(5, block_label, description_label)
			popup.connect("amount_changed", change_stat_amount)
		elif block_data.block_options.option is CustomStatsOptions:
			var popup = block_data.block_options.popup.instantiate()
			block_options_popup.get_node("PopupHolder").add_child(popup)
			popup.set_custom_stats([50, 50, 50, 50])
			popup.connect("custom_stats_changed", change_custom_stats)
		elif block_data.block_options.option is TeleportOptions:
			if block_data.has("teleport_colorin_coords"):
				teleport_colorin_coords = block_data.teleport_colorin_coords
			if block_data.has("teleport_color"):
				teleport_color = block_data.teleport_color
			block_draw_teleport_colorin.visible = true
			block_draw_teleport_colorin.texture.region = Rect2((128 * teleport_colorin_coords.x), (128 * teleport_colorin_coords.y), 128, 128)
			block_draw_teleport_colorin.self_modulate = teleport_color
			var popup = block_data.block_options.popup.instantiate()
			block_options_popup.get_node("PopupHolder").add_child(popup)
			popup.init(Color(teleport_color), block_draw_button.texture_normal.atlas, Rect2((128 * block_data.block_atlas_coords.x), (128 * block_data.block_atlas_coords.y), 128, 128), Rect2((128 * teleport_colorin_coords.x), (128 * teleport_colorin_coords.y), 128, 128))
			popup.connect("teleport_color_changed", change_teleport_color)
	else:
		selected_block_options = null
	emit_signal("control_event", {
			"type": EditorEvents.SELECT_BLOCK,
			"block_id": selected_block_id,
			"block_options": selected_block_options,
			"teleport_colorin_coords": teleport_colorin_coords,
			"teleport_color": teleport_color
		})
	block_draw_button.texture_normal.region = Rect2((128 * block_data.block_atlas_coords.x), (128 * block_data.block_atlas_coords.y), 128, 128)
	block_picker_popup.hide()


func _check_clicked_button(node: Node):
	var color1: Color
	var color2: Color
	if node.get_parent().name == "BlockMover":
		color1 = Color("8d49fa")
		color2 = Color("ffffff")
	elif node.get_parent().name == "BlockKiller":
		color1 = Color("ff5f5f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "BlockDropper":
		color1 = Color("00c05f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "BlockOptions":
		color1 = Color("ff8a21")
		color2 = Color("ffffff")
	if node is TextureButton:
		if node.visible and node.is_hovered() and !node.is_pressed():
			node.get_parent().scale = Vector2(1.25, 1.25)
		else:
			node.get_parent().scale = Vector2(1, 1)
		if node.get_parent().name == "BlockMover" or node.get_parent().name == "BlockKiller" or node.get_parent().name == "BlockDropper":
			if selected_button.get_parent() == node.get_parent():
				node.self_modulate = color2
			else:
				node.self_modulate = color1
	elif node is ColorRect:
		if selected_button.get_parent() == node.get_parent():
			node.self_modulate = color1
		else:
			node.self_modulate = color2


func change_stat_amount(new_amount: int):
	if selected_block_options and selected_block_options.option is StatsOptions:
		selected_block_options.option.set_amount(new_amount)


func change_custom_stats(new_custom_stats: Array):
	if selected_block_options and selected_block_options.option is CustomStatsOptions:
		selected_block_options.option.set_custom_stats(new_custom_stats)


func change_teleport_color(new_color: Color):
	if selected_block_options and selected_block_options.option is TeleportOptions:
		selected_block_options.option.set_color(new_color)
		block_draw_teleport_colorin.self_modulate = selected_block_options.option.color


func _click_block_menu(button: TextureButton):
	var tool_id: String = ""
	selected_button = button
	print(selected_block_id)
	if selected_button == block_mover_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_BLOCK_MODE,
			"mode": "move"
		})
	elif selected_button == block_killer_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_BLOCK_MODE,
			"mode": "erase"
		})
	elif selected_button == block_dropper_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_BLOCK_MODE,
			"mode": "draw"
		})


func _show_block_picker():
	block_picker_popup.show()


func _show_block_options():
	if block_options_popup.get_node("PopupHolder").get_child_count() > 0:
		block_options_popup.size = block_options_popup.get_node("PopupHolder").get_child(0).size
		block_options_popup.position = Vector2(block_options_panel.global_position.x + block_options_panel.size.x + 10, block_options_panel.global_position.y)
		block_options_popup.show()


func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)
