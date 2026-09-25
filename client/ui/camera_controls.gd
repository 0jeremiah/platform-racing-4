extends Control

@onready var zoom_in_button = $ZoomInButton
@onready var zoom_out_button = $ZoomOutButton
@onready var zoom_dropdown_button = $ZoomDropdownButton
@onready var camera_up_button = $CameraUpButton
@onready var camera_left_button = $CameraLeftButton
@onready var camera_right_button = $CameraRightButton
@onready var camera_down_button = $CameraDownButton
@onready var dropdown_popup = preload("res://ui/dropdown/dropdownpopup.gd")

var camera: Camera2D = null
var dropdown_options: Array = []


func _ready():
	pass


func init(new_camera: Camera2D):
	camera = new_camera
	zoom_in_button.pressed.connect(_inc_or_dec_camera_zoom.bind(1))
	zoom_out_button.pressed.connect(_inc_or_dec_camera_zoom.bind(-1))
	zoom_dropdown_button.pressed.connect(_show_zoom_list)
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


func _show_zoom_list():
	dropdown_options = []
	for zoom in camera.zoom_array.size():
		dropdown_options.append({"label": str(int(camera.zoom_array[zoom] * 200)) + "%", "data": zoom})
	PopupManager.add_custom_popup(dropdown_popup, {"dropdownpicker_func": Callable(self, "_change_camera_zoom"), "dropdown_size": Vector2(zoom_dropdown_button.size.x - 20.0, 200), "options": dropdown_options, "popup_position": Vector2(zoom_dropdown_button.global_position.x, zoom_dropdown_button.global_position.y - 200)}, self)


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_inc_or_dec_camera_zoom(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_inc_or_dec_camera_zoom(-1)


func _inc_or_dec_camera_zoom(by: int):
	if camera:
		camera.change_camera_zoom(camera.zoom_index + by)
		zoom_dropdown_button.text = str(int(camera.zoom_array[camera.zoom_index] * 200)) + "%"


func _change_camera_zoom(new_zoom_index: int):
	if camera:
		camera.change_camera_zoom(new_zoom_index)
		zoom_dropdown_button.text = str(int(camera.zoom_array[camera.zoom_index] * 200)) + "%"
