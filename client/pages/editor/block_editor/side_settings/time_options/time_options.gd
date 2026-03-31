extends SideOption

signal time_options_changed

@onready var seconds_box = $SecondsBox

var seconds: float = 10.0


func _ready() -> void:
	seconds_box.init("float", "10.0", -9999999.9, 99999999.9)
	seconds_box.return_line.connect(_change_seconds)
	connect_node(self, "time_options_changed")


func _change_seconds(new_seconds: float):
	seconds = new_seconds
	emit_signal("time_options_changed", {"seconds": seconds})


func set_options(new_options: Dictionary):
	if new_options.has("seconds"):
		seconds = clamp(new_options.seconds, -9999999.9, 99999999.9)
		seconds_box._update_text(str(seconds))
	options = {"seconds": seconds}
