extends Control

signal control_event

@onready var blockpicker_popup = preload("res://pages/editor/setting_popups/block_picker/block_picker_popup.gd")
@onready var blocksettingsmenu_popup = preload("res://pages/editor/block_settings_menu/blocksettingsmenupopup.gd")
@onready var block_menu = $BlockMenu
@onready var selection_glow = $BlockMenu/SelectionGlow
@onready var block_mover_button = $BlockMenu/BlockMover/TextureButton
@onready var block_killer_button = $BlockMenu/BlockKiller/TextureButton
@onready var block_draw_panel = $BlockMenu/BlockDrawPanel
@onready var block_dropper_button = $BlockMenu/BlockDropper/TextureButton
@onready var block_draw_button = $BlockMenu/BlockDraw/TextureButton
@onready var block_draw_teleport_colorin = $BlockMenu/BlockDraw/TextureButton/TeleportColorin
@onready var block_options_panel = $BlockMenu/BlockOptionsPanel
@onready var block_options_node = $BlockMenu/BlockOptions
@onready var block_options_button = $BlockMenu/BlockOptions/TextureButton
@onready var layer_panel = $LayerPanel

static var selected_block_id: String
static var selected_block_settings: ConfigurableBlockSettings = ConfigurableBlockSettings.new()
var active: bool = true
var current_layers: Node2D
var editor_events: EditorEvents
var current_editor = null
var selected_button: TextureButton


func _ready() -> void:
	block_mover_button.pressed.connect(_click_block_menu.bind(block_mover_button))
	block_killer_button.pressed.connect(_click_block_menu.bind(block_killer_button))
	block_dropper_button.pressed.connect(_click_block_menu.bind(block_dropper_button))
	if !selected_block_id:
		selected_block_id = "601"
		var settings = {}
		if selected_block_id in BlockManager._block_lookup:
			settings = BlockManager._block_lookup[selected_block_id].settings
		selected_block_settings.import_settings(settings)
	block_draw_button.pressed.connect(_show_block_picker)
	block_options_button.pressed.connect(_show_block_options)
	_click_block_menu(block_dropper_button)


func init() -> void:
	layer_panel.init(current_editor, current_layers, "blocks")
	editor_events.connect_to([layer_panel])
	var settings = {}
	_set_current_block({"id": selected_block_id, "settings": selected_block_settings.get_settings()})
	if active:
		layer_panel._render()


func deactivate():
	active = false


func activate():
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": "blocks"
	})
	active = true
	if layer_panel.current_layers != null and layer_panel.current_editor != null:
		layer_panel._render()


func _process(_delta: float) -> void:
	if active:
		visible = true
		for child in block_menu.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
		if selected_button == block_dropper_button:
			block_draw_panel.visible = true
			block_draw_button.visible = true
			if selected_block_settings != null:
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

		if selected_button:
			set_selection_glow()
	else:
		visible = false
	if selected_block_settings and block_draw_teleport_colorin.visible:
		block_draw_teleport_colorin.self_modulate = selected_block_settings.teleport_color


func _set_current_block(block_data: Dictionary) -> void:
	selected_block_id = block_data.id
	selected_block_settings.import_settings(block_data.settings)
	block_draw_teleport_colorin.visible = false
	emit_signal("control_event", {
			"type": EditorEvents.SELECT_BLOCK,
			"block_id": selected_block_id,
			"block_settings": selected_block_settings,
			"block_settings_info": {"settings": selected_block_settings.get_settings(), "edited_settings": selected_block_settings.get_edited_settings()}
		})
	block_draw_button.texture_normal = BlockManager.get_block_texture(selected_block_id)
	if selected_block_settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		block_draw_teleport_colorin.texture = BlockManager.get_block_teleport_texture(selected_block_id)
		block_draw_teleport_colorin.visible = true


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


func _click_block_menu(button: TextureButton):
	selected_button = button
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
	PopupManager.add_custom_popup(blockpicker_popup, {"blockpicker_func": Callable(self, "_set_current_block"), "popup_position": Vector2(block_draw_panel.global_position.x + (block_draw_panel.size.x + 20), block_draw_panel.global_position.y)}, self)


func _show_block_options():
	PopupManager.add_custom_popup(blocksettingsmenu_popup, {"block_settings": selected_block_settings, "popup_position": Vector2(block_options_button.global_position.x + (block_options_button.size.x + 20), block_options_button.global_position.y)}, self)
	#if block_options_popup.get_node("PopupHolder").get_child_count() > 0:
		#block_options_popup.size = block_options_popup.get_node("PopupHolder").get_child(0).size
		#block_options_popup.position = Vector2(block_options_panel.global_position.x + block_options_panel.size.x + 10, block_options_panel.global_position.y)
		#block_options_popup.show()


func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)
