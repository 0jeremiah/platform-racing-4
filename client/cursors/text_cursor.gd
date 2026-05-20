extends Node2D

signal level_event

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
var current_textbox: TextEdit
var current_layers = null
var text_color: Color = Color("071E6BFF")
var text_font_size: int = 28
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


func init(_current_layers) -> void:
	if _current_layers is LevelLayers or _current_layers is BlockLayers:
		current_layers = _current_layers
	

func on_mouse_down():
	if active:
		var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		var texts: Node2D = layer.texts
		var camera: Camera2D = get_viewport().get_camera_2d()
		var mouse_position = texts.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.get_layer_scale()))
		if layer.get_text_at_position(mouse_position) != null:
				var selected_text = layer.get_text_at_position(mouse_position)
				var object_box = get_parent().editor_menu.current_editor.object_box
				var spawn_position = camera.to_local(selected_text.position)
				#object_box.set_object_info({"delete": true, "resize": true, "options": false, "edit": false},
				#{"type": "text", "node": selected_text.text_box, "position": spawn_position,
				#"rotation": selected_stamp.text_rotation, "offset": Vector2(0, 0),
				#"size": selected_stamp.text_box.size, "scale": selected_stamp.text_box.scale})
		else:
			sample_text.set("theme_override_font_sizes/normal_font_size", text_font_size)
			var text_height = sample_text.get_line_height(0) / 2
			emit_signal("level_event", {
				"type": EditorEvents.ADD_TEXT,
				"layer_name": current_layers.get_target_art_layer(),
				"text": "Hello World!",
				"font": "actionman",
				"font_size": text_font_size,
				"scale": {
					"x": 1,
					"y": 1
				},
				"position": {
					"x": mouse_position.round().x,
					"y": mouse_position.round().y
				},
				"rotation": 0,
				"color": text_color
			})


func on_drag():
	pass


func on_mouse_up():
	pass


func update_display():
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
	caret.position = Vector2((-caret.size.x * camera.zoom.x) / 2, (-caret.size.y * camera.zoom.y) / 2)
	caret.scale = camera.zoom
