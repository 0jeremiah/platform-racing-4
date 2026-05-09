extends BlockSideSetting

signal time_side_settings_changed

@onready var seconds_box = $SecondsBox

var seconds: float = 10.0


func _ready() -> void:
	seconds_box.init("float", "10.0", -9999999.9, 99999999.9)
	seconds_box.return_line.connect(_change_seconds)
	connect_node(self, "time_side_settings_changed")


func _change_seconds(new_seconds: float):
	seconds = new_seconds
	emit_signal("time_side_settings_changed", {"seconds": seconds})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("seconds"):
		seconds = clamp(new_side_settings.seconds, -9999999.9, 99999999.9)
		seconds_box._update_text(str(seconds))
	side_settings = {"seconds": seconds}
