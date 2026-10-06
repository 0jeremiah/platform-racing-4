extends BlockSideSetting

signal lightbreaker_side_settings_changed

@onready var lightbreaker_type_button = $LightbreakerTypeButton
@onready var dropdown_popup = preload("res://ui/dropdown/dropdownpopup.gd")

var lightbreaker_type: String = "sun"


func _ready() -> void:
	lightbreaker_type_button.pressed.connect(_show_lightbreaker_types)
	connect_node(self, "lightbreaker_side_settings_changed")


func _show_lightbreaker_types():
	var dropdown_options = []
	for type in ConfigurableBlockSideSettings.lightbreaker_types:
		dropdown_options.append({"label": ConfigurableBlockSideSettings.lightbreaker_types[type].label, "data": ConfigurableBlockSideSettings.lightbreaker_types[type]})
	PopupManager.add_custom_popup(dropdown_popup, {"dropdownpicker_func": Callable(self, "_change_lightbreaker_type"), "dropdown_size": Vector2(lightbreaker_type_button.size.x, 240), "options": dropdown_options, "popup_position": Vector2(lightbreaker_type_button.global_position.x, lightbreaker_type_button.global_position.y + lightbreaker_type_button.size.y)}, self)


func _change_lightbreaker_type(selected_lightbreaker_type: Dictionary):
	lightbreaker_type = selected_lightbreaker_type.setting
	lightbreaker_type_button.text = selected_lightbreaker_type.label
	emit_signal("lightbreaker_side_settings_changed", {"lightbreaker_type": lightbreaker_type})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("lightbreaker_type"):
		if new_side_settings.lightbreaker_type in ConfigurableBlockSideSettings.lightbreaker_types:
			lightbreaker_type = new_side_settings.lightbreaker_type
			lightbreaker_type_button.text = ConfigurableBlockSideSettings.lightbreaker_types[lightbreaker_type].label
		else:
			var lightbreaker_types_keys = ConfigurableBlockSideSettings.lightbreaker_types.keys()
			if lightbreaker_types_keys.size() > 0:
				lightbreaker_type = ConfigurableBlockSideSettings.lightbreaker_types[lightbreaker_types_keys[0]].setting
				lightbreaker_type_button.text = ConfigurableBlockSideSettings.lightbreaker_types[lightbreaker_types_keys[0]].label
