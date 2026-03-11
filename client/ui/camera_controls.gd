extends Control

@onready var zoom_in_button = $ZoomInButton
@onready var zoom_out_button = $ZoomOutButton
@onready var zoom_dropdown_button = $ZoomDropdownButton
@onready var camera_up_button = $CameraUpButton
@onready var camera_left_button = $CameraLeftButton
@onready var camera_right_button = $CameraRightButton
@onready var camera_down_button = $CameraDownButton

var camera: Camera2D = null


func _ready():
	pass


func init(new_camera: Camera2D):
	camera = new_camera
	zoom_in_button.pressed.connect(_inc_or_dec_camera_zoom.bind(1))
	zoom_out_button.pressed.connect(_inc_or_dec_camera_zoom.bind(-1))
	for zoom in camera.zoom_array:
		zoom_dropdown_button.get_popup().add_item(str(int(zoom * 200)) + "%")
	zoom_dropdown_button.get_popup().index_pressed.connect(_change_camera_zoom.bind())
	zoom_dropdown_button.text = str(int(camera.zoom_array[camera.zoom_index] * 200)) + "%"


func _process(_delta: float) -> void:
	if camera:
		camera.manual_control_vector = Vector2(0, 0)
		if camera_right_button.button_pressed:
			camera.manual_control_vector.x = 1
		if camera_left_button.button_pressed:
			camera.manual_control_vector.x = -1
		if camera_down_button.button_pressed:
			camera.manual_control_vector.y = 1
		if camera_up_button.button_pressed:
			camera.manual_control_vector.y = -1


func _inc_or_dec_camera_zoom(by: int):
	if camera:
		camera.change_camera_zoom(camera.zoom_index + by)
		zoom_dropdown_button.text = str(int(camera.zoom_array[camera.zoom_index] * 200)) + "%"


func _change_camera_zoom(new_zoom_index: int):
	if camera:
		camera.change_camera_zoom(new_zoom_index)
		zoom_dropdown_button.text = str(int(camera.zoom_array[camera.zoom_index] * 200)) + "%"
