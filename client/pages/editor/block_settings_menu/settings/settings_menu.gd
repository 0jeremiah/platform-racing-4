extends Control

signal block_settings_changed

@onready var settings_dropdown_button = $SettingsDropdownButton
@onready var settings_container = $SettingsContainer
@onready var settings_list = $SettingsContainer/SettingsList
@onready var dropdown_popup = preload("res://ui/dropdown/dropdownpopup.gd")

var settings_dictionary: Dictionary = {}
var current_setting: String = ""
var block_properties: Dictionary = {}
var has_settings: bool = false
var block_settings: ConfigurableBlockSettings = null
var container_size: Vector2 = Vector2(488.0, 298.0)
var container_y: float = 80
var dropdown_options: Array = []


func _ready() -> void:
	for default_setting in ConfigurableBlockSettings.default_block_properties:
		block_properties[default_setting] = ConfigurableBlockSettings.default_block_properties[default_setting]
	for setting in settings_list.properties:
		settings_list.properties[setting].node.set_key(setting)
		settings_list.properties[setting].node.set_settings(settings_list.properties[setting].settings)
		settings_list.properties[setting].node.setting_changed.connect(_change_properties.bind())
		settings_dictionary[setting] = false
	settings_dropdown_button.pressed.connect(_show_dropdown)
	populate_options()


func init(_block_settings: ConfigurableBlockSettings):
	block_settings = _block_settings


func _change_properties(new_settings: Dictionary):
	for key in new_settings.settings:
		if key in block_properties:
			block_properties[key] = new_settings.settings[key]
			if block_settings and key in block_settings:
				block_settings[key] = block_properties[key]
	emit_signal("block_settings_changed", block_properties)


func _show_dropdown():
	if has_settings:
		PopupManager.add_custom_popup(dropdown_popup, {"dropdownpicker_func": Callable(self, "_select_options"), "dropdown_size": Vector2(settings_dropdown_button.size.x, 240), "options": dropdown_options, "popup_position": Vector2(settings_dropdown_button.global_position.x, settings_dropdown_button.global_position.y + settings_dropdown_button.size.y)}, self)


func populate_options():
	dropdown_options = []
	has_settings = false
	for setting in settings_dictionary:
		if settings_dictionary[setting] == true:
			has_settings = true
			dropdown_options.append({"label": settings_list.properties[setting].label, "data": {"setting": setting}})


func _update_settings(new_settings: Dictionary):
	for key in new_settings:
		if key in block_properties:
			block_properties[key] = new_settings[key]
	for setting in settings_list.properties:
		settings_list.properties[setting].node.set_settings(new_settings)


func update_enabled_settings() -> void:
	_maybe_enable_settings({
		"block_settings": {
			"general": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID, "setting": "general"},
			ConfigurableBlockSettings.MOVE: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.MOVE, "setting": ConfigurableBlockSettings.MOVE},
			ConfigurableBlockSettings.CHANGE: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.CHANGE, "setting": ConfigurableBlockSettings.CHANGE},
			"stat": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and (block_settings.has_side_type(ConfigurableBlockSideSettings.CHANGE_STATS) or block_settings.has_side_type(ConfigurableBlockSideSettings.CUSTOM_STATS)), "setting": "stat"},
			ConfigurableBlockSideSettings.ITEM: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.ITEM), "setting": ConfigurableBlockSideSettings.ITEM},
			ConfigurableBlockSideSettings.TELEPORT: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT), "setting": ConfigurableBlockSideSettings.TELEPORT},
			ConfigurableBlockSideSettings.TIME: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.TIME), "setting": ConfigurableBlockSideSettings.TIME},
			ConfigurableBlockSettings.GEAR: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.GEAR, "setting": ConfigurableBlockSettings.GEAR}
		}
	})


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
		settings_dropdown_button.text = settings_list.properties[setting_info.setting].label
		show_option(setting_info)
	else:
		var still_has_settings = false
		for setting in settings_dictionary:
			if settings_dictionary[setting] == true:
				still_has_settings = true
				current_setting = setting
				settings_dropdown_button.text = settings_list.properties[setting].label
				show_option({"setting": setting})
				break
		if !still_has_settings:
			current_setting = ""
			settings_dropdown_button.text = "None"
			show_option({})


func show_option(setting_info: Dictionary):
	for child in settings_list.get_child_count():
		settings_list.get_child(child).visible = false
	if "setting" in setting_info and setting_info.setting in settings_list.properties:
		settings_list.properties[setting_info.setting].node.visible = true
		settings_list.custom_minimum_size = settings_list.properties[setting_info.setting].node.size
		settings_container.size = Vector2(clampf(settings_list.properties[setting_info.setting].node.size.x + 12, 0, container_size.x), clampf(settings_list.properties[setting_info.setting].node.size.y + 12, 0, container_size.y))


func change_container_size(new_container_size: Vector2):
	container_size = new_container_size
	settings_container.size = container_size
