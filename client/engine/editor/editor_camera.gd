extends Camera2D

var velocity = 2000
var camera_zoom = 0.5
var target_zoom = 0.5
var is_zooming : bool = false
var camera_speed_multiplier = 1.0
var camera_rotation: float = 0.0
var control_vector = Vector2(0, 0)
var manual_control_vector = Vector2(0, 0)

# Zoom settings
var zoom_array: Array = [0.125, 0.25, 0.375, 0.5, 0.75, 1.25, 2.5]
var zoom_index: int = 3


func _ready():
	set_position_smoothing_enabled(true)
	set_position_smoothing_speed(7)


func _process(delta):
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner and (focus_owner is LineEdit or focus_owner is TextEdit):
		return
		
	set_zoom(Vector2(camera_zoom, camera_zoom))
	control_vector = Vector2(0, 0)
	
	if Input.is_action_pressed("right") or manual_control_vector.x == 1:
		control_vector.x = 1
	if Input.is_action_pressed("left") or manual_control_vector.x == -1:
		control_vector.x = -1
	if Input.is_action_pressed("down") or manual_control_vector.y == 1:
		control_vector.y = 1
	if Input.is_action_pressed("up") or manual_control_vector.y == -1:
		control_vector.y = -1
		
	if Input.is_key_pressed(KEY_CTRL):
		camera_speed_multiplier = 2.5
	else:
		camera_speed_multiplier = 1.0
	position += control_vector * ((velocity * (0.5 / zoom_array[zoom_index])) * camera_speed_multiplier) * delta
	
	if is_zooming:
		var factor_to_zoom = target_zoom / camera_zoom
		camera_zoom = lerp(camera_zoom, target_zoom, max(abs(factor_to_zoom), 1/abs(factor_to_zoom))*delta*5)
		if abs(factor_to_zoom - 1) < 0.001:
			camera_zoom = target_zoom
			is_zooming = false


func change_camera_zoom(new_index: int):
	zoom_index = clamp(new_index, 0, zoom_array.size() - 1)
	is_zooming = true
	target_zoom = zoom_array[zoom_index]
