extends Node2D

signal level_event

@onready var stamp_icon = $StampIcon
var active: bool = false
var layers: Layers
var mode: String = "vector"
var stamp_graphics: Array = []
var stamp_array: Array = []
var stamp_id: String = "cactus"
var stamp_size: int = 100
var stamp_rotation: int = 0


func _ready() -> void:
	var stamp_container: Stamps = Stamps.new()
	stamp_graphics = stamp_container.stamp_graphic_list
	stamp_array = stamp_container.stamp_list


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
	queue_redraw()


func _draw() -> void:
	var touching_gui: bool = get_parent().touching_gui
	if touching_gui:
		var layer: ParallaxBackground = layers.art_layers.get_node(layers.get_target_art_layer())
		var packed_vector2_array = layer.get_stamp_draw_packed_vector2_array_for_debug(stamp_icon)
		for lines in packed_vector2_array.size():
			if lines + 1 < packed_vector2_array.size():
				draw_line(packed_vector2_array[lines], packed_vector2_array[lines + 1], Color.WHITE, 1.0, false)
			else:
				draw_line(packed_vector2_array[lines], packed_vector2_array[0], Color.WHITE, 1.0, false)


func init(_menu, _layers) -> void:
	layers = _layers
	_menu.connect("control_event", _on_control_event)


func _on_control_event(event: Dictionary) -> void:
	print("BlockCursor::_on_control_event", event)
	if event.type == EditorEvents.SELECT_STAMP_MODE:
		mode = event.mode


func on_mouse_down():
	if active:
		if stamp_id:
			var layer: ParallaxBackground = layers.art_layers.get_node(layers.get_target_art_layer())
			var stamps: Node2D = layer.get_node("Stamps")
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = stamps.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
			if layer.get_stamp_at_position(mouse_position) != null:
				var selected_stamp = layer.get_stamp_at_position(mouse_position)
				#get_parent().object_box.set_object_info({"delete": true, "resize": true, "options": false, "edit": false},
				#{"type": "stamp", "node": selected_stamp, "position": selected_stamp.position,
				#"rotation": selected_stamp.rotation_degrees, "offset": selected_stamp.offset,
				#"size": selected_stamp.texture.get_size(), "scale": selected_stamp.scale})
			else:
				emit_signal("level_event", {
					"type": EditorEvents.ADD_STAMP,
					"layer_name": layers.get_target_art_layer(),
					"id": stamp_id,
					"position": {
						"x": mouse_position.round().x - round(stamp_icon.texture.get_size().rotated(deg_to_rad(stamp_rotation)).x * (0.01 * stamp_size)),
						"y": mouse_position.round().y - round(stamp_icon.texture.get_size().rotated(deg_to_rad(stamp_rotation)).y * (0.01 * stamp_size))
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
		var stamps = Stamps.new()
		stamps.get_stamp(stamp_icon, stamp_id)
		update_display()


func set_stamp_size(new_size: int) -> void:
	stamp_size = new_size
	update_display()


func set_stamp_rotation(new_rotation: float) -> void:
	stamp_rotation = new_rotation
	update_display()


func update_display():
	stamp_icon.position = Vector2(round((-stamp_icon.texture.get_size().rotated(deg_to_rad(stamp_rotation)).x / 2) * (0.01 * stamp_size)), round((-stamp_icon.texture.get_size().rotated(deg_to_rad(stamp_rotation)).y / 2) * (0.01 * stamp_size)))
	stamp_icon.rotation_degrees = stamp_rotation
	stamp_icon.scale = Vector2(0.01 * stamp_size, 0.01 * stamp_size)
