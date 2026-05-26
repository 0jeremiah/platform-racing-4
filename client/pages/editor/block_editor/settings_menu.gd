extends Control

signal block_settings_changed

@onready var settings_dropdown_button = $SettingsDropdownButton
@onready var settings_container = $SettingsContainer
@onready var settings = $SettingsContainer/Settings
@onready var dropdown_popup = $DropdownPopup

var settings_dictionary: Dictionary = {}
var current_setting: String = ""
var block_properties: Dictionary = {}
var has_settings: bool = false
var block_settings: ConfigurableBlockSettings = null
var container_y: float = 80


func _ready() -> void:
	for default_setting in ConfigurableBlockSettings.default_properties:
		block_properties[default_setting] = ConfigurableBlockSettings.default_properties[default_setting]
	for setting in settings.properties:
		settings.properties[setting].node.set_key(setting)
		settings.properties[setting].node.set_settings(settings.properties[setting].settings)
		settings.properties[setting].node.setting_changed.connect(_change_properties.bind())
		settings_dictionary[setting] = false
	settings_dropdown_button.pressed.connect(_show_dropdown)
	dropdown_popup.set_dropdown_size(Vector2(settings_dropdown_button.size.x, 240))
	dropdown_popup.return_dropdown_data.connect(_select_options.bind())
	populate_options()


func init(_block_settings: ConfigurableBlockSettings):
	block_settings = _block_settings


func _change_properties(new_settings: Dictionary):
	for key in new_settings.settings:
		if key in block_properties:
			block_properties[key] = new_settings.settings[key]
			if block_settings and key in block_settings:
				block_settings[key] = block_properties[key]


func _show_dropdown():
	if has_settings:
		dropdown_popup.show_popup(settings_dropdown_button.global_position.x, settings_dropdown_button.global_position.y + settings_dropdown_button.size.y)
		

func populate_options():
	dropdown_popup.clear()
	has_settings = false
	for setting in settings_dictionary:
		if settings_dictionary[setting] == true:
			has_settings = true
			dropdown_popup.add_option(settings.properties[setting].label, {"setting": setting})


func _maybe_enable_settings(setting_info: Dictionary):
	var enabled_settings = []
	if setting_info.has("block_settings"):
		for setting in settings_dictionary:
			if setting_info.block_settings.has(setting):
				if setting_info.block_settings[setting].enabled == true:
					settings_dictionary[setting] = true
					enabled_settings.append(setting)
				else:
					settings_dictionary[setting] = false
	if !has_settings and !enabled_settings.is_empty():
		_select_options({"setting": enabled_settings[0]}) 
	elif current_setting in settings_dictionary:
		_select_options({"setting": current_setting})
	populate_options()


func _select_options(setting_info: Dictionary):
	if setting_info.setting in settings_dictionary and settings_dictionary[setting_info.setting] == true:
		current_setting = setting_info.setting
		settings_dropdown_button.text = settings.properties[setting_info.setting].label
		show_option(setting_info)
	else:
		var still_has_settings = false
		for setting in settings_dictionary:
			if settings_dictionary[setting] == true:
				still_has_settings = true
				current_setting = setting
				settings_dropdown_button.text = settings.properties[setting].label
				show_option({"setting": setting})
				break
		if !still_has_settings:
			current_setting = ""
			settings_dropdown_button.text = "None"
			show_option({})


func show_option(setting_info: Dictionary):
	for child in settings.get_child_count():
		settings.get_child(child).visible = false
	if "setting" in setting_info and setting_info.setting in settings.properties:
		settings.properties[setting_info.setting].node.visible = true
		settings.custom_minimum_size = settings.properties[setting_info.setting].node.size
		settings_container.size = Vector2(clampf(settings.properties[setting_info.setting].node.size.x + 12, 0, 238), clampf(settings.properties[setting_info.setting].node.size.y + 12, 0, container_y))
