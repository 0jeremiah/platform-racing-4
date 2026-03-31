extends SideOption

signal teleport_options_changed

@onready var color_button = $ColorButton
@onready var throttle_ms_box = $ThrottlemsBox

var teleport_color: Color = Color("FF7F50")
var throttle_ms: float = 1000.0


func _ready() -> void:
	color_button.set_color(teleport_color)
	color_button.colorbutton_color_changed.connect(_change_color)
	throttle_ms_box.init("float", "1000.0", 0.0, 99999999.9)
	throttle_ms_box.return_line.connect(_change_throttle_ms)
	connect_node(self, "teleport_options_changed")


func _change_color(new_teleport_color: Color):
	teleport_color = new_teleport_color
	emit_signal("teleport_options_changed", {"color": teleport_color.to_html(false), "throttle_ms": throttle_ms})


func _change_throttle_ms(new_throttle_ms: float):
	throttle_ms = new_throttle_ms
	emit_signal("teleport_options_changed", {"color": teleport_color.to_html(false), "throttle_ms": throttle_ms})


func set_options(new_options: Dictionary):
	if new_options.has("color"):
		teleport_color = Color(new_options.color)
		color_button.set_color(teleport_color)
	if new_options.has("throttle_ms"):
		throttle_ms = clamp(new_options.throttle_ms, 0.0, 99999999.9)
		throttle_ms_box._update_text(str(throttle_ms))
	options = {"color": teleport_color, "throttle_ms": throttle_ms}
