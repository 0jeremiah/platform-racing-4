extends BlockSetting

signal teleport_settings_changed

@onready var teleport_color_button = $TeleportColorButton
@onready var teleport_throttle_ms_box = $TeleportThrottleMsBox

var teleport_color: Color = Color("FF7F50")
var teleport_throttle_ms: float = 1000.0


func _ready() -> void:
	teleport_color_button.set_color(teleport_color)
	teleport_color_button.colorbutton_color_changed.connect(_change_teleport_color)
	teleport_throttle_ms_box.init("float", "1000.0", 0.0, 99999999.9)
	teleport_throttle_ms_box.return_line.connect(_change_teleport_throttle_ms)
	connect_node(self, "teleport_settings_changed")


func _change_teleport_color(new_teleport_color: Color):
	teleport_color = new_teleport_color
	emit_signal("teleport_settings_changed", {"teleport_color": teleport_color.to_html(false), "teleport_throttle_ms": teleport_throttle_ms})


func _change_teleport_throttle_ms(new_teleport_throttle_ms: float):
	teleport_throttle_ms = new_teleport_throttle_ms
	emit_signal("teleport_settings_changed", {"teleport_color": teleport_color.to_html(false), "teleport_throttle_ms": teleport_throttle_ms})


func set_settings(new_settings: Dictionary):
	if new_settings.has("teleport_color"):
		teleport_color = Color(new_settings.teleport_color)
		teleport_color_button.set_color(teleport_color)
	if new_settings.has("teleport_throttle_ms"):
		teleport_throttle_ms = clamp(new_settings.teleport_throttle_ms, 0.0, 99999999.9)
		teleport_throttle_ms_box._update_text(str(teleport_throttle_ms))
