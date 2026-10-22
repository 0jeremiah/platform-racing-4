extends Control

signal activatable_settings_changed

@onready var activatable_settings_container = $ActivatableSettingsContainer

var activatable_options_presets: Dictionary = {
	"settings": {
		"gear": {"setting": ConfigurableBlockSettings.GEAR, "name": "Activate Gear Blocks"}
	},
	"side_settings": {
		"brick": {"setting": ConfigurableBlockSideSettings.SHATTER, "name": "Break Brick Blocks"},
		"mine": {"setting": ConfigurableBlockSideSettings.MINE, "name": "Explode Mine Blocks"},
		"crumble": {"setting": ConfigurableBlockSideSettings.CRUMBLE, "name": "Explode Mine Blocks"},
		"vanish": {"setting": ConfigurableBlockSideSettings.VANISH, "name": "Touch Vanish Blocks"},
		"appear": {"setting": ConfigurableBlockSideSettings.APPEAR, "name": "Touch Appear Blocks"}
		}
}
var activatable_settings_buttons: Dictionary = {}
var activatable_side_settings_buttons: Dictionary = {}
var activatable_settings_array: Array = []
var activatable_side_settings_array: Array = []
var button_size: Vector2 = Vector2(200.0, 30.0)


func _ready() -> void:
	for activatable_options_preset in activatable_options_presets.settings:
		add_activatable_option_to_array(activatable_options_preset, activatable_options_presets.settings[activatable_options_preset], activatable_settings_buttons, activatable_settings_array)
	create_separator()
	for activatable_options_preset in activatable_options_presets.side_settings:
		add_activatable_option_to_array(activatable_options_preset, activatable_options_presets.side_settings[activatable_options_preset], activatable_side_settings_buttons, activatable_side_settings_array)
	activatable_settings_container.resized.connect(_change_size)


func init(new_side_settings: Dictionary) -> void:
	if new_side_settings.has("settings"):
		activatable_settings_array = new_side_settings.settings
		update_activatable_settings()
	if new_side_settings.has("side_settings"):
		activatable_side_settings_array = new_side_settings.side_settings
		update_activatable_side_settings()


func add_activatable_option_to_array(activatable_option_name: String, activatable_dictionary: Dictionary, button_array: Dictionary, activatable_array: Array):
	button_array[activatable_option_name] = activatable_dictionary
	button_array[activatable_option_name]["button"] = create_button(activatable_dictionary.name)
	button_array[activatable_option_name]["button"].pressed.connect(maybe_add_activatable_setting.bind(activatable_option_name, button_array, activatable_array))
	activatable_array.append(button_array[activatable_option_name].setting)


func create_button(button_text: String) -> CheckBox:
	var activatable_option_check_box = CheckBox.new()
	activatable_option_check_box.size = button_size
	activatable_option_check_box.custom_minimum_size = button_size
	activatable_option_check_box.clip_text = true
	activatable_option_check_box.set("theme_override_font_sizes/font_size", 17)
	activatable_option_check_box.text = button_text
	activatable_option_check_box.set_pressed_no_signal(true)
	activatable_settings_container.add_child(activatable_option_check_box)
	return activatable_option_check_box


func create_separator():
	var separator = HSeparator.new()
	separator.size = Vector2(button_size.x, 10.0)
	separator.custom_minimum_size = Vector2(button_size.x, 10.0)
	activatable_settings_container.add_child(separator)


func _change_size() -> void:
	size = activatable_settings_container.size
	custom_minimum_size = activatable_settings_container.size
	activatable_settings_container.resized.disconnect(_change_size)


func maybe_add_activatable_setting(activatable_option_name: String, button_array: Dictionary, activatable_array: Array) -> void:
	if activatable_option_name in button_array:
		if button_array[activatable_option_name].button.button_pressed:
			if !activatable_array.has(button_array[activatable_option_name].setting):
				activatable_array.append(button_array[activatable_option_name].setting)
		else:
			while activatable_array.has(button_array[activatable_option_name].setting):
				activatable_array.erase(button_array[activatable_option_name].setting)
		emit_signal("activatable_settings_changed", {"settings": activatable_settings_array, "side_settings": activatable_side_settings_array})


func update_activatable_settings() -> void:
	for activatable_setting in activatable_settings_buttons:
		if activatable_settings_array.has(activatable_settings_buttons[activatable_setting].setting):
			activatable_settings_buttons[activatable_setting].button.set_pressed_no_signal(true)
		else:
			activatable_settings_buttons[activatable_setting].button.set_pressed_no_signal(false)


func update_activatable_side_settings() -> void:
	for activatable_side_setting in activatable_side_settings_buttons:
		if activatable_side_settings_array.has(activatable_side_settings_buttons[activatable_side_setting].setting):
			activatable_side_settings_buttons[activatable_side_setting].button.set_pressed_no_signal(true)
		else:
			activatable_side_settings_buttons[activatable_side_setting].button.set_pressed_no_signal(false)
