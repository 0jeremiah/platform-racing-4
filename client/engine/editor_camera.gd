extends Camera2D

var velocity = 2000
var camera_zoom = 1.0
var target_zoom = 1.0
var is_zooming : bool = false
var camera_speed_multiplier = 1.0
var camera_rotation: float = 0.0

# Zoom settings
var zoom_increment: int = 3
var min_zoom_increment: int = 0
var max_zoom_increment: int = 6
var zoom_amounts: Array = [25, 50, 75, 100, 150, 250, 500] # Zoom amounts listed in percentage.


func _ready():
	set_position_smoothing_enabled(true)
	set_position_smoothing_speed(7)


func _process(delta):
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner and (focus_owner is LineEdit or focus_owner is TextEdit):
		return
		
	set_zoom(Vector2(camera_zoom, camera_zoom))
	var control_vector = Vector2(0, 0)
	
	if Input.is_action_pressed("right"):
		control_vector.x = 1
	if Input.is_action_pressed("left"):
		control_vector.x = -1
	if Input.is_action_pressed("down"):
		control_vector.y = 1
	if Input.is_action_pressed("up"):
		control_vector.y = -1
		
	if Input.is_key_pressed(KEY_CTRL):
		camera_speed_multiplier = 2.5
	else:
		camera_speed_multiplier = 1.0
	position += control_vector * (velocity * camera_speed_multiplier) * delta
	
	if is_zooming:
		var factor_to_zoom = target_zoom / camera_zoom
		camera_zoom = lerp(camera_zoom, target_zoom, max(factor_to_zoom, 1/factor_to_zoom)*delta*5)
		if abs(factor_to_zoom - 1) < 0.001:
			camera_zoom = target_zoom
			is_zooming = false


func change_camera_zoom(new_zoom_value):
	is_zooming = true
	target_zoom = clamp(new_zoom_value, 0, zoom_amounts.size() - 1)
