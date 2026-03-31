extends SideOption

signal bounce_options_changed

@onready var bounciness_box = $BouncinessBox
@onready var speed_limit_box = $SpeedLimitBox

var bounciness: float = 0.1
var speed_limit: float = 12500.0


func _ready() -> void:
	bounciness_box.init("float", "0.1", 0.0, 99999999.9)
	bounciness_box.return_line.connect(_change_bounciness)
	speed_limit_box.init("float", "12500.0", 0.0, 99999999.9)
	speed_limit_box.return_line.connect(_change_speed_limit)
	connect_node(self, "bounce_options_changed")


func _change_bounciness(new_bounciness: float):
	bounciness = new_bounciness
	emit_signal("bounce_options_changed", {"bounciness": bounciness, "speed_limit": speed_limit})


func _change_speed_limit(new_speed_limit: float):
	speed_limit = new_speed_limit
	emit_signal("bounce_options_changed", {"bounciness": bounciness, "speed_limit": speed_limit})


func set_options(new_options: Dictionary):
	if new_options.has("bounciness"):
		bounciness = clamp(new_options.bounciness, 0.0, 99999999.9)
		bounciness_box._update_text(str(bounciness))
	if new_options.has("speed_limit"):
		speed_limit = clamp(new_options.speed_limit, 0.0, 99999999.9)
		speed_limit_box._update_text(str(speed_limit))
	options = {"bounciness": bounciness, "speed_limit": speed_limit}
