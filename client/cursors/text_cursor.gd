extends Node2D

signal editor_event

@onready var sample_text = $SampleText
@onready var caret = $Caret
@onready var white_caret = $Caret/WhiteCaret
@onready var white_caret_top = $Caret/WhiteCaret/WhiteCaretTop
@onready var white_caret_middle = $Caret/WhiteCaret/WhiteCaretMiddle
@onready var white_caret_bottom = $Caret/WhiteCaret/WhiteCaretBottom
@onready var black_caret = $Caret/BlackCaret
@onready var black_caret_top = $Caret/BlackCaret/BlackCaretTop
@onready var black_caret_middle = $Caret/BlackCaret/BlackCaretMiddle
@onready var black_caret_bottom = $Caret/BlackCaret/BlackCaretBottom

var active: bool = false
var current_layers = null
var cursor_parent = null
var current_textbox: TextEdit
var text_font: String = "actionman"
var text_color: Color = Color("071E6BFF")
var text_font_size: int = 56
var text_rotation: int = 0


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		caret.visible = false
		var touching_gui: bool = get_parent().touching_gui
		if touching_gui:
			caret.visible = true
			update_display()
	else:
		visible = false


func init(_current_layers, _cursor_parent) -> void:
	print("TextCursor::init")
	if _current_layers is LevelLayers or _current_layers is BlockLayers:
		current_layers = _current_layers
	cursor_parent = _cursor_parent
	cursor_parent.editor_menu.connect("control_event", _on_control_event)


func _on_control_event(event: Dictionary) -> void:
	if active:
		print("TextCursor::_on_control_event", event)


func on_mouse_down():
	if active and cursor_parent.editor_menu.can_edit and cursor_parent.editor_menu.can_edit:
		var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		var texts: Node2D = layer.texts
		var camera: Camera2D = get_viewport().get_camera_2d()
		var mouse_position = texts.get_local_mouse_position() + (camera.get_screen_center_position() * layer.get_layer_scale()) - (camera.get_screen_center_position() * layer.get_layer_scale())
		if layer.get_text_at_position(mouse_position) != null:
				var selected_text = layer.get_text_at_position(mouse_position)
				var object_box = get_parent().editor_menu.current_editor.object_box
				var spawn_position = selected_text.position
				object_box.set_object_info({"delete": true, "resize": true, "options": false, "text": true},
				{"type": "text", "node": selected_text, "position": spawn_position,
				"rotation": selected_text.text_rotation, "offset": Vector2(0, 0),
				"size": selected_text.text_box.size, "scale": selected_text.text_scale,
				"text": selected_text.text_string, "info": str(layer.name)}, {"font": text_font})
		else:
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_TEXT,
				"layer_name": current_layers.get_target_art_layer(),
				"text": "Hello World!",
				"font": text_font,
				"font_size": text_font_size,
				"scale": {
					"x": 1,
					"y": 1
				},
				"position": {
					"x": mouse_position.round().x,
					"y": mouse_position.round().y - (sample_text.get_line_height(0) / 2)
				},
				"rotation": text_rotation,
				"color": text_color
			})


func on_drag():
	pass


func on_mouse_up():
	pass


func set_text_font_size(new_size: int) -> void:
	text_font_size = new_size
	update_display()


func set_text_color(new_color: Color) -> void:
	text_color = new_color
	update_display()


func set_text_rotation(new_rotation: int) -> void:
	text_rotation = new_rotation
	update_display()


func set_text_font(new_font: String) -> void:
	text_font = new_font
	update_display()


func _object_moved(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.SET_TEXT_POSITION,
		"layer_name": object_info.info,
		"text_name": str(object_info.node.name),
		"position": object_info.node.position
	})


func _object_deleted(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.DELETE_TEXT,
		"layer_name": object_info.info,
		"text_name": str(object_info.node.name)
	})


func _object_resized(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.SET_TEXT_SCALE,
		"layer_name": object_info.info,
		"text_name": str(object_info.node.name),
		"scale": object_info.node.scale
	})


func _object_text_edited(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.SET_TEXT_STRING,
		"layer_name": object_info.info,
		"text_name": str(object_info.node.name),
		"text": object_info.text
	})


func update_display():
	sample_text.set("theme_override_fonts/normal_font", FontManager.get_font(text_font))
	sample_text.set("theme_override_font_sizes/normal_font_size", text_font_size)
	var text_height = sample_text.get_line_height(0) / 2
	white_caret_middle.size.y = text_height
	black_caret_middle.size.y = text_height
	white_caret_bottom.position.y = white_caret_middle.position.y + white_caret_middle.size.y
	black_caret_bottom.position.y = black_caret_middle.position.y + black_caret_middle.size.y
	white_caret.size.y = white_caret_bottom.position.y + white_caret_bottom.size.y
	black_caret.size.y = black_caret_bottom.position.y + black_caret_bottom.size.y
	caret.size.y = white_caret.position.y + white_caret.size.y
	var camera: Camera2D = get_viewport().get_camera_2d()
	var layer_scale = 1.0
	var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
	if layer:
		layer_scale = layer.get_layer_scale()
	caret.position = Vector2((-caret.size.x * camera.zoom.x) / 2, (-caret.size.y * camera.zoom.y) / 2)
	caret.scale = Vector2(layer_scale, layer_scale) * camera.zoom
	caret.rotation_degrees = text_rotation
