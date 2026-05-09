extends BlockSideSetting

signal stick_side_settings_changed

@onready var speed_stickiness_box = $SpeedStickinessBox
@onready var jump_stickiness_box = $JumpStickinessBox

var speed_stickiness: float = 2.5
var jump_stickiness: float = 8.0


func _ready() -> void:
	speed_stickiness_box.init("float", "2.5", 0.0, 99999999.9)
	speed_stickiness_box.return_line.connect(_change_speed_stickiness)
	jump_stickiness_box.init("float", "8.0", 0.0, 99999999.9)
	jump_stickiness_box.return_line.connect(_change_jump_stickiness)
	connect_node(self, "stick_side_settings_changed")


func _change_speed_stickiness(new_speed_stickiness: float):
	speed_stickiness = new_speed_stickiness
	emit_signal("stick_side_settings_changed", {"speed_stickiness": speed_stickiness, "jump_stickiness": jump_stickiness})


func _change_jump_stickiness(new_jump_stickiness: float):
	jump_stickiness = new_jump_stickiness
	emit_signal("stick_side_settings_changed", {"speed_stickiness": speed_stickiness, "jump_stickiness": jump_stickiness})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("speed_stickiness"):
		speed_stickiness = clamp(new_side_settings.speed_stickiness, 0.0, 99999999.9)
		speed_stickiness_box._update_text(str(speed_stickiness))
	side_settings = {"speed_stickiness": speed_stickiness, "jump_stickiness": jump_stickiness}
