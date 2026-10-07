extends BlockSetting

signal teleport_settings_changed

@onready var teleport_color_button = $TeleportColorButton
@onready var teleport_throttle_box = $TeleportThrottleBox

var teleport_color: Color = Color(ConfigurableBlockSettings.default_block_properties.teleport_color)
var teleport_throttle: float = ConfigurableBlockSettings.default_block_properties.teleport_throttle


func _ready() -> void:
	teleport_color_button.set_color(teleport_color)
	teleport_color_button.colorbutton_color_changed.connect(_change_teleport_color)
	teleport_throttle_box.init("float", str(teleport_throttle), 0.0, 99999999.9)
	teleport_throttle_box.return_line.connect(_change_teleport_throttle)
	connect_node(self, "teleport_settings_changed")


func _change_teleport_color(new_teleport_color: Color):
	teleport_color = new_teleport_color
	emit_signal("teleport_settings_changed", {"teleport_color": teleport_color.to_html(false), "teleport_throttle": teleport_throttle})


func _change_teleport_throttle(new_teleport_throttle: float):
	teleport_throttle = new_teleport_throttle
	emit_signal("teleport_settings_changed", {"teleport_color": teleport_color.to_html(false), "teleport_throttle": teleport_throttle})


func set_settings(new_settings: Dictionary):
	if new_settings.has("teleport_color"):
		teleport_color = Color(new_settings.teleport_color)
		teleport_color_button.set_color(teleport_color)
	if new_settings.has("teleport_throttle"):
		teleport_throttle = clamp(new_settings.teleport_throttle, 0.0, 99999999.9)
		teleport_throttle_box._update_text(str(teleport_throttle))
