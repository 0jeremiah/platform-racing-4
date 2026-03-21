extends Node2D

signal level_event

@onready var caret = $Caret
var active: bool = false
var current_textbox: TextEdit
var current_layers = null
var text_color: Color = Color("071E6BFF")
var text_size: int = 28
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
			emit_signal("level_event", {
				"type": EditorEvents.ADD_TEXT,
				"layer_name": current_layers.get_target_art_layer(),
				"text": "Hello World!",
				"font": "quicksand",
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
