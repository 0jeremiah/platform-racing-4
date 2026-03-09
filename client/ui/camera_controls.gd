extends Control

signal zoom_changed(zoom_event)

@onready var zoom_in_button = $ZoomInButton
@onready var zoom_out_button = $ZoomOutButton
@onready var zoom_dropdown_button = $ZoomDropdownButton
@onready var camera_up_button = $CameraUpButton
@onready var camera_left_button = $CameraLeftButton
@onready var camera_right_button = $CameraRightButton
@onready var camera_down_button = $CameraDownButton


func _ready():
	pass


#func _change_zoom(by: int):
	#emit_signal("zoom_changed", {
		#"type": "editor_camera_zoom_change",
		#"zoom": 0.5 * zoom_amounts[zoom_increment] / 100.0
	#})
