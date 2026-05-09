extends BlockSetting

signal teleport_settings_changed

@onready var color_button = $ColorButton
@onready var throttle_ms_box = $ThrottlemsBox

var teleport_color: Color = Color("FF7F50")
var throttle_ms: float = 1000.0


func _ready() -> void:
	color_button.set_color(teleport_color)
	color_button.colorbutton_color_changed.connect(_change_color)
	throttle_ms_box.init("float", "1000.0", 0.0, 99999999.9)
	throttle_ms_box.return_line.connect(_change_throttle_ms)


func _change_color(new_teleport_color: Color):
	teleport_color = new_teleport_color
	emit_signal("teleport_settings_changed", {"color": teleport_color.to_html(false), "throttle_ms": throttle_ms})


func _change_throttle_ms(new_throttle_ms: float):
	throttle_ms = new_throttle_ms
	emit_signal("teleport_settings_changed", {"color": teleport_color.to_html(false), "throttle_ms": throttle_ms})


func set_settings(new_settings: Dictionary):
	if new_settings.has("color"):
		teleport_color = Color(new_settings.color)
		color_button.set_color(teleport_color)
	if new_settings.has("throttle_ms"):
		throttle_ms = clamp(new_settings.throttle_ms, 0.0, 99999999.9)
		throttle_ms_box._update_text(str(throttle_ms))
