extends Control

signal bounce_options_changed

@onready var bounciness_box = $BouncinessBox
@onready var speed_limit_box = $SpeedLimitBox

var bounciness: float = 0.3
var speed_limit: float = 2.0


func _ready() -> void:
	bounciness_box.init("float", "0.3", 0.0, 99999999.9)
	bounciness_box.return_line.connect(_change_bounciness)
	speed_limit_box.init("float", "2.0", 0.0, 99999999.9)
	speed_limit_box.return_line.connect(_change_speed_limit)


func _change_bounciness(new_bounciness: float):
	bounciness = new_bounciness
	emit_signal("bounce_options_changed", {"bounciness": bounciness, "speed_limit": speed_limit})


func set_bounciness(new_bounciness: float):
	bounciness_box._update_text(str(new_bounciness))
	bounciness = new_bounciness


func _change_speed_limit(new_speed_limit: float):
	speed_limit = new_speed_limit
	emit_signal("bounce_options_changed", {"bounciness": bounciness, "speed_limit": speed_limit})


func set_speed_limit(new_speed_limit: float):
	speed_limit_box._update_text(str(new_speed_limit))
	speed_limit = new_speed_limit
