extends Node2D

signal editor_event

@onready var stamp_icon = $StampIcon

var active: bool = false
var current_layers = null
var cursor_parent = null
var mode: String = "sticker"
var stamp_id: String = "cactus"
var stamp_size: int = 200
var stamp_rotation: int = 0


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		stamp_icon.visible = false
		var touching_gui: bool = get_parent().touching_gui
		if touching_gui:
			stamp_icon.visible = true
	else:
		visible = false
	update_display()


func init(_current_layers, _cursor_parent) -> void:
	print("StampCursor::init")
	if _current_layers is LevelLayers or _current_layers is BlockLayers:
		current_layers = _current_layers
	cursor_parent = _cursor_parent
	cursor_parent.editor_menu.connect("control_event", _on_control_event)


func _on_control_event(event: Dictionary) -> void:
	if active:
		print("StampCursor::_on_control_event", event)


func on_mouse_down():
	if active and cursor_parent.editor_menu.can_edit and cursor_parent.editor_menu.can_edit:
		if stamp_id:
			var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
			var location: Node2D = null
			if mode == "stamp":
				location = layer.lines
			else:
				location = layer.stamps
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = location.get_local_mouse_position() + (camera.get_screen_center_position() * layer.get_layer_scale()) - (camera.get_screen_center_position() * layer.get_layer_scale())
			if mode == "stamp":
				emit_signal("editor_event", {
					"type": EditorEvents.ADD_LINE,
					"layer_name": current_layers.get_target_art_layer(),
					"line_type": "stamp",
					"id": stamp_id,
					"position": {
						"x": mouse_position.round().x - round((stamp_icon.texture.get_size() / 2).rotated(deg_to_rad(stamp_rotation)).x * (0.01 * stamp_size)),
						"y": mouse_position.round().y - round((stamp_icon.texture.get_size() / 2).rotated(deg_to_rad(stamp_rotation)).y * (0.01 * stamp_size))
					},
					"scale": {
						"x": (0.01 * stamp_size),
						"y": (0.01 * stamp_size)
					},
					"rotation": stamp_rotation
				})
			elif mode == "sticker" and layer.get_stamp_at_position(mouse_position) != null:
				var selected_stamp = layer.get_stamp_at_position(mouse_position)
				if "object_box" in cursor_parent.editor_menu.current_editor:
					var object_box = cursor_parent.editor_menu.current_editor.object_box
					var spawn_position = location.to_local(selected_stamp.position)
					object_box.set_object_info({"delete": true, "resize": true, "options": true, "text": false},
					{"type": "stamp", "node": selected_stamp, "position": spawn_position,
					"rotation": selected_stamp.rotation_degrees, "offset": selected_stamp.offset,
					"size": selected_stamp.texture.get_size(), "scale": selected_stamp.scale, "info": str(layer.name)})
			else:
				emit_signal("editor_event", {
					"type": EditorEvents.ADD_STAMP,
					"layer_name": current_layers.get_target_art_layer(),
					"id": stamp_id,
					"position": {
						"x": mouse_position.round().x - round((stamp_icon.texture.get_size() / 2).rotated(deg_to_rad(stamp_rotation)).x * (0.01 * stamp_size)),
						"y": mouse_position.round().y - round((stamp_icon.texture.get_size() / 2).rotated(deg_to_rad(stamp_rotation)).y * (0.01 * stamp_size))
					},
					"scale": {
						"x": (0.01 * stamp_size),
						"y": (0.01 * stamp_size)
					},
					"rotation": stamp_rotation
				})


func on_drag():
	pass


func on_mouse_up():
	pass


func set_stamp_id(new_id: String) -> void:
	stamp_id = new_id
	if stamp_id:
		stamp_icon.texture = StampManager.get_stamp_texture(stamp_id)
		update_display()


func set_stamp_size(new_size: int) -> void:
	stamp_size = new_size
	update_display()


func set_stamp_rotation(new_rotation: float) -> void:
	stamp_rotation = new_rotation
	update_display()


func set_stamp_mode(new_mode: String) -> void:
	mode = new_mode


func _object_moved(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.SET_STAMP_POSITION,
		"layer_name": object_info.info,
		"stamp_name": str(object_info.node.name),
		"position": object_info.node.position
	})


func _object_deleted(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.DELETE_STAMP,
		"layer_name": object_info.info,
		"stamp_name": str(object_info.node.name)
	})


func _object_resized(object_info: Dictionary):
	emit_signal("editor_event", {
		"type": EditorEvents.SET_STAMP_SCALE,
		"layer_name": object_info.info,
		"stamp_name": str(object_info.node.name),
		"scale": object_info.node.scale
	})


func update_display():
	var camera: Camera2D = get_viewport().get_camera_2d()
	var camera_zoom = camera.zoom.x
	if "camera_zoom" in camera:
		camera_zoom = camera.camera_zoom
	var layer_scale = 1.0
	var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
	if layer:
		layer_scale = layer.get_layer_scale()
	stamp_icon.position = Vector2(round((-stamp_icon.texture.get_size().rotated(deg_to_rad(stamp_rotation)).x / 2) * ((0.01 * stamp_size) * layer_scale) * (camera_zoom)), round((-stamp_icon.texture.get_size().rotated(deg_to_rad(stamp_rotation)).y / 2) * ((0.01 * stamp_size) * layer_scale) * (camera_zoom)))
	stamp_icon.rotation_degrees = stamp_rotation
	stamp_icon.scale = Vector2(((0.01 * stamp_size) * layer_scale) * (camera_zoom), ((0.01 * stamp_size) * layer_scale) * (camera_zoom))
