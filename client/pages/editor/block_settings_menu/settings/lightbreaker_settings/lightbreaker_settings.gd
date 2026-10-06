extends BlockSetting

signal lightbreaker_settings_changed

@onready var light_color_button = $LightColorButton

var light_color: Color = Color(ConfigurableBlockSettings.default_block_properties.light_color)


func _ready() -> void:
	light_color_button.set_color(light_color)
	light_color_button.colorbutton_color_changed.connect(_change_light_color)
	connect_node(self, "lightbreaker_settings_changed")


func _change_light_color(new_light_color: Color):
	light_color = new_light_color
	emit_signal("lightbreaker_settings_changed", {"light_color": light_color.to_html(false)})


func set_settings(new_settings: Dictionary):
	if new_settings.has("light_color"):
		light_color = Color(new_settings.light_color)
		light_color_button.set_color(light_color)
