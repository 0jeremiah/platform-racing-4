extends BlockSideSetting

signal rotate_side_settings_changed

@onready var rotations_box = $RotationsBox
@onready var rotation_speed_box = $RotationSpeedBox

var rotations: int = 1
var rotation_speed: float = 0.025


func _ready() -> void:
	rotations_box.init("int", "1", -999999999, 9999999999)
	rotations_box.return_line.connect(_change_rotations)
	rotation_speed_box.init("float", "0.025", 0.0, 1.0)
	rotation_speed_box.return_line.connect(_change_rotation_speed)
	connect_node(self, "rotate_side_settings_changed")


func _change_rotations(new_rotations: int):
	rotations = new_rotations
	emit_signal("rotate_side_settings_changed", {"rotations": rotations, "rotation_speed": rotation_speed})


func _change_rotation_speed(new_rotation_speed: float):
	rotation_speed = new_rotation_speed
	emit_signal("rotate_side_settings_changed", {"rotations": rotations, "rotation_speed": rotation_speed})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("rotations"):
		rotations = clamp(new_side_settings.rotations, -999999999, 9999999999)
		rotations_box._update_text(str(rotations))
	if new_side_settings.has("rotation_speed"):
		rotation_speed = clamp(new_side_settings.rotation_speed, 0.0, 1.0)
		rotation_speed_box._update_text(str(rotation_speed))
	side_settings = {"rotations": rotations, "rotation_speed": rotation_speed}
