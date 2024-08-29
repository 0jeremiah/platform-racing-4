extends Node2D

signal level_event

var current_usertextbox: TextEdit


func on_mouse_down():
	var layer_name = get_parent().layer_name
	var layer: ParallaxBackground = get_node("../../../Layers/"+layer_name)
	var textboxes: Node2D = layer.get_node("UserTextboxes")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = textboxes.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))

	var usertextbox_background_color = Color(1.0, 0.0, 0.0, 0.0)
	var usertextbox_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
	var usertextbox_font_size = 150
	
	emit_signal("level_event", {
		"type": EditorEvents.ADD_USERTEXT,
		"layer_name": get_parent().layer_name,
		"position": mouse_position.round(),
		"usertext": "Text!",
		"font": usertextbox_font,
		"font_size": usertextbox_font_size
	})
	
	self.get_parent().get_node("Control").mouse_filter = 2 #edit text mode until add text is reselected


func on_drag():
	pass


func on_mouse_up():
	pass