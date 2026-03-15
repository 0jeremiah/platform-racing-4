extends Control

signal control_event

@onready var art_menu = $ArtMenu
@onready var selection_glow = $ArtMenu/SelectionGlow
@onready var background_texture = $ArtMenu/BackgroundBox/BackgroundTexture
@onready var background_button = $ArtMenu/BackgroundBox/Button
@onready var brush_button = $ArtMenu/BrushBox/TextureButton
@onready var eraser_button = $ArtMenu/EraserBox/TextureButton
@onready var stamp_button = $ArtMenu/StampBox/TextureButton
@onready var text_button = $ArtMenu/TextBox/TextureButton
@onready var art_settings = $ArtSettings
@onready var art_settings_panel = $ArtSettings/ArtSettingsPanel
@onready var color_box_button = $ArtSettings/ColorBox
@onready var color_picker_texture = $ArtSettings/ColorBox/TextureButton/ColorPicker
@onready var color_picker_colorin = $ArtSettings/ColorBox/TextureButton/ColorPickerColorin
@onready var stamp_texture = $ArtSettings/SelectedStampBox/StampTexture
@onready var selected_stamp_box = $ArtSettings/SelectedStampBox
@onready var selected_stamp_texture = $ArtSettings/SelectedStampBox/StampTexture
@onready var selected_stamp_button = $ArtSettings/SelectedStampBox/Button
@onready var size_box = $ArtSettings/SizeBox
@onready var size_text = $ArtSettings/SizeBox/SizeText
@onready var size_button = $ArtSettings/SizeBox/Button
@onready var alpha_box = $ArtSettings/AlphaBox
@onready var alpha_label = $ArtSettings/AlphaBox/AlphaLabel
@onready var alpha_text = $ArtSettings/AlphaBox/AlphaText
@onready var rotation_box = $ArtSettings/RotationBox
@onready var rotation_label = $ArtSettings/RotationBox/RotationLabel
@onready var rotation_text = $ArtSettings/RotationBox/RotationText
@onready var bg_picker_popup = $BGPickerPopup
@onready var bg_picker = $BGPickerPopup/BGPicker
@onready var stamp_picker_popup = $StampPickerPopup
@onready var stamp_picker = $StampPickerPopup/StampPicker
@onready var layer_panel = $LayerPanel


var active: bool = false
var level_layers: Node2D
var editor_events: EditorEvents
var background_graphics: Array = []
var background_array: Array = []
var stamp_graphics: Array = []
var stamp_array: Array = []
var selected_button: TextureButton
var dont_change_color_list: Array = ["ColorBox", "SelectedStampBox", "SizeBox", "AlphaBox", "RotationBox", "BackgroundBox", "BGButtonContainer"]
var bg_id: String
var bg_color: Color = Color("BBBBDDFF")
var draw_color: Color = Color("000000FF")
var draw_size: float = 5
var draw_alpha: float = 100
var erase_size: float = 5
var erase_alpha: float = 100
var stamp_id: String = "cactus"
var stamp_size: float = 100
var stamp_rotation: float = 0
var text_size: float = 14
var text_rotation: float = 0
var text_color: Color = Color("071E6BFF")
var color_box = preload("res://ui/colorbutton.tscn")


func _ready() -> void:
	background_button.pressed.connect(_show_bg_picker_popup)
	brush_button.pressed.connect(_click_art_menu.bind(brush_button))
	eraser_button.pressed.connect(_click_art_menu.bind(eraser_button))
	stamp_button.pressed.connect(_click_art_menu.bind(stamp_button))
	text_button.pressed.connect(_click_art_menu.bind(text_button))
	selected_stamp_button.pressed.connect(_show_stamp_picker_popup)
	bg_picker.connect("change_selected_background", _set_bg.bind())
	stamp_picker.connect("change_selected_stamp", _select_stamp.bind())
	
	_click_art_menu(brush_button)


func init() -> void:
	layer_panel.init(level_layers, "art")
	editor_events.connect_to([layer_panel])
	editor_events.level_event.connect(_on_level_event)


func deactivate():
	active = false


func activate():
	if selected_button == brush_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "draw"
		})
	elif selected_button == eraser_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "erase"
		})
	elif selected_button == stamp_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "stamp"
		})
	elif selected_button == text_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "text"
		})
	active = true


func _physics_process(delta: float) -> void:
	if active:
		visible = true
		for child in art_menu.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
		for child in art_settings.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
		bg_picker_popup.size = bg_picker.size
		stamp_picker_popup.size = stamp_picker.size
		if selected_button:
			set_selection_glow()
	else:
		visible = false


func _on_level_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_BACKGROUND:
		var sprite2d = Sprite2D.new()
		var bgs = Backgrounds.new()
		bgs.get_bg(sprite2d, bg_id, bg_color)
		background_texture.texture = sprite2d.texture
	if event.type == EditorEvents.SELECT_STAMP:
		var sprite2d = Sprite2D.new()
		var stamps = Stamps.new()
		stamps.get_stamp(sprite2d, stamp_id)
		selected_stamp_texture.texture = sprite2d.texture


func _check_clicked_button(node: Node):
	var color1: Color
	var color2: Color
	if node.get_parent().name == "BrushBox":
		color1 = Color("7f7f7f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "EraserBox":
		color1 = Color("eb8a9f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "StampBox":
		color1 = Color("be8b61")
		color2 = Color("ffffff")
	elif node.get_parent().name == "TextBox":
		color1 = Color("071e6b")
		color2 = Color("ffffff")
	if node.get_parent().name != "ColorBox" and (node is TextureButton or node is Button):
		if node.visible and node.is_hovered() and !node.is_pressed():
			if node.get_parent().name != "BGButtonContainer":
				node.get_parent().scale = Vector2(1.25, 1.25)
			else:
				node.scale = Vector2(1.25, 1.25)
		else:
			if node.get_parent().name != "BGButtonContainer":
				node.get_parent().scale = Vector2(1, 1)
			else:
				node.scale = Vector2(1, 1)
		if node.get_parent().name not in dont_change_color_list:
			if selected_button.get_parent() == node.get_parent():
				node.self_modulate = color2
			else:
				node.self_modulate = color1
	elif node is ColorRect:
		if node.get_parent().name not in dont_change_color_list:
			if selected_button.get_parent() == node.get_parent():
				node.self_modulate = color1
			else:
				node.self_modulate = color2


func _show_bg_picker_popup():
	bg_picker_popup.position = Vector2(art_menu.global_position.x + art_menu.size.x + 10, background_button.global_position.y)
	bg_picker_popup.show()


func _show_stamp_picker_popup():
	stamp_picker_popup.position = Vector2(art_menu.global_position.x + art_menu.size.x + 10, selected_stamp_button.global_position.y)
	stamp_picker_popup.show()


func disconnect_button(button):
	for child in button.get_children():
		if child is Button:
			if child.is_connected("colorbutton_color_changed", _select_draw_color.bind()):
				child.disconnect("colorbutton_color_changed", _select_draw_color.bind())
			if child.is_connected("colorbutton_color_changed", _select_text_color.bind()):
				child.disconnect("colorbutton_color_changed", _select_text_color.bind())
			if child.is_connected("slider_value_changed", _select_draw_size.bind()):
				child.disconnect("slider_value_changed", _select_draw_size.bind())
			if child.is_connected("slider_value_changed", _select_draw_alpha.bind()):
				child.disconnect("slider_value_changed", _select_draw_alpha.bind())


func _click_art_menu(button: TextureButton):
	selected_button = button
	var tool_id: String = ""
	color_box_button.visible = false
	disconnect_button(color_box_button)
	disconnect_button(size_box)
	disconnect_button(alpha_box)
	selected_stamp_box.visible = false
	size_box.visible = false
	alpha_box.visible = false
	rotation_box.visible = false
	if selected_button == brush_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "draw"
		})
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_BRUSH_MODE,
			"mode": "draw"
		})
		color_box_button.visible = true
		color_box_button.position = Vector2(20, 20)
		color_box_button.spawn_x = color_box_button.size.x
		color_box_button.set_color(draw_color)
		color_box_button.connect("colorbutton_color_changed", _select_draw_color.bind())
		size_box.visible = true
		size_box.position = Vector2(20, 88)
		size_box.spawn_x = size_box.size.x + 10
		size_box.set_button("Size", draw_size, 1, 200)
		size_box.connect("slider_value_changed", _select_draw_size.bind())
		alpha_box.visible = true
		alpha_box.position = Vector2(20, 156)
		alpha_box.spawn_x = alpha_box.size.x + 10
		alpha_box.set_button("Alpha", draw_alpha, 1, 100)
		alpha_box.connect("slider_value_changed", _select_draw_alpha.bind())
		art_settings_panel.size = Vector2(88, 224)
		art_settings.size = Vector2(98, 234)
	elif selected_button == eraser_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "erase"
		})
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_BRUSH_MODE,
			"mode": "erase"
		})
		size_box.visible = true
		size_box.position = Vector2(20, 20)
		size_box.spawn_x = size_box.size.x + 10
		size_box.set_button("Size", erase_size, 1, 200)
		size_box.connect("slider_value_changed", _select_erase_size.bind())
		alpha_box.visible = true
		alpha_box.position = Vector2(20, 88)
		alpha_box.spawn_x = alpha_box.size.x + 10
		alpha_box.set_button("Alpha", erase_alpha, 1, 100)
		alpha_box.connect("slider_value_changed", _select_erase_alpha.bind())
		art_settings_panel.size = Vector2(88, 156)
		art_settings.size = Vector2(98, 166)
	elif selected_button == stamp_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "stamp"
		})
		selected_stamp_box.visible = true
		selected_stamp_box.position = Vector2(20, 20)
		size_box.visible = true
		size_box.position = Vector2(20, 88)
		size_box.set_button("Size", stamp_size, 1, 500)
		size_box.connect("slider_value_changed", _select_stamp_size.bind())
		rotation_box.visible = true
		rotation_box.position = Vector2(20, 156)
		rotation_box.set_button("Rot", stamp_rotation, 0, 359)
		rotation_box.connect("slider_value_changed", _select_stamp_rotation.bind())
		art_settings_panel.size = Vector2(88, 224)
		art_settings.size = Vector2(98, 234)
	elif selected_button == text_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_TOOL,
			"tool": "text"
		})
		color_box_button.visible = true
		color_box_button.position = Vector2(20, 20)
		color_box_button.spawn_x = color_box_button.size.x
		color_box_button.set_color(text_color)
		color_box_button.connect("colorbutton_color_changed", _select_text_color.bind())
		size_box.visible = true
		size_box.position = Vector2(20, 88)
		size_box.set_button("Size", text_size, 1, 200)
		size_box.connect("slider_value_changed", _select_text_size.bind())
		rotation_box.visible = true
		rotation_box.position = Vector2(20, 156)
		rotation_box.set_button("Rot", text_rotation, 0, 359)
		rotation_box.connect("slider_value_changed", _select_text_rotation.bind())
		art_settings_panel.size = Vector2(88, 224)
		art_settings.size = Vector2(98, 234)


func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)


func _set_bg(bg_data: Array):
	bg_color = bg_data[0]
	bg_id = bg_data[1]
	emit_signal("control_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": bg_id,
		"fade_color": bg_color.to_html(false)
	})
	bg_picker_popup.hide()


func _select_draw_color(new_color: Color):
	draw_color = new_color
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_DRAW_COLOR,
		"color": draw_color.to_html(true) # Include alpha in hex format (e.g. FFFFFFFF)
	})


func _select_draw_size(new_size: int):
	draw_size = new_size
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_DRAW_SIZE,
		"size": draw_size
	})


func _select_draw_alpha(new_alpha: int):
	draw_alpha = new_alpha
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_DRAW_ALPHA,
		"alpha": float(draw_alpha) / 100
	})


func _select_erase_size(new_size: int):
	erase_size = new_size
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_ERASE_SIZE,
		"size": erase_size
	})


func _select_erase_alpha(new_alpha: int):
	erase_alpha = new_alpha
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_ERASE_ALPHA,
		"alpha": float(erase_alpha) / 100
	})


func _select_stamp(new_id: String):
	stamp_id = new_id
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_STAMP,
		"stamp": stamp_id,
	})
	stamp_picker_popup.hide()


func _select_stamp_size(new_size: int):
	stamp_size = new_size
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_STAMP_SIZE,
		"size": stamp_size
	})


func _select_stamp_rotation(new_rotation: int):
	stamp_rotation = new_rotation
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_STAMP_ROTATION,
		"rotation": stamp_rotation
	})


func _select_text_color(new_color: Color):
	text_color = new_color


func _select_text_size(new_size: int):
	text_size = new_size
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TEXT_SIZE,
		"size": text_size
	})


func _select_text_rotation(new_rotation: int):
	text_rotation = new_rotation
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TEXT_ROTATION,
		"rotation": text_rotation
	})
