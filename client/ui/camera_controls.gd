extends Control

@onready var zoom_in_button = $ZoomInButton
@onready var zoom_out_button = $ZoomOutButton
@onready var zoom_dropdown_button = $ZoomDropdownButton
@onready var camera_up_button = $CameraUpButton
@onready var camera_left_button = $CameraLeftButton
@onready var camera_right_button = $CameraRightButton
@onready var camera_down_button = $CameraDownButton
@onready var dropdown_popup = $DropdownPopup

var camera: Camera2D = null


func _ready():
	pass


func init(new_camera: Camera2D):
	camera = new_camera
	zoom_in_button.pressed.connect(_inc_or_dec_camera_zoom.bind(1))
	zoom_out_button.pressed.connect(_inc_or_dec_camera_zoom.bind(-1))
	#for zoom in camera.zoom_array:
		#zoom_dropdown_button.get_popup().add_item(str(int(zoom * 200)) + "%")
	zoom_dropdown_button.pressed.connect(_show_zoom_list)
	zoom_dropdown_button.text = str(int(camera.zoom_array[camera.zoom_index] * 200)) + "%"
	dropdown_popup.return_dropdown_data.connect(_change_camera_zoom.bind())


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
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(zoom_dropdown_button.size.x - dropdown_popup.dropdown_picker.padding_size.x, 200))
	dropdown_popup.holder = zoom_dropdown_button
	for zoom in camera.zoom_array.size():
		dropdown_popup.add_option(str(int(camera.zoom_array[zoom] * 200)) + "%", zoom)
	dropdown_popup.show_popup(zoom_dropdown_button.global_position.x, zoom_dropdown_button.global_position.y - dropdown_popup.size.y)


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
