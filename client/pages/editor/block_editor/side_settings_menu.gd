extends Control

@onready var side_settings_dropdown_button = $SideSettingsDropdownButton
@onready var side_settings = $SideSettings
@onready var dropdown_popup = $DropdownPopup

var sides_dictionary: Dictionary = {
	"solids": {
		"top": {"label": "Top", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null},
		"bottom": {"label": "Bottom", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null},
		"left": {"label": "Left", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null},
		"right": {"label": "Right", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null},
		"bump": {"label": "Bump", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null},
		"stand": {"label": "Stand", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null},
		"any_side": {"label": "Any Side", "setting": ConfigurableBlockSideSettings.ACTIVE, "side_settings": null}
		},
	"non-solids": {
		"area": {"label": "Area", "setting": ConfigurableBlockSideSettings.INACTIVE, "side_settings": null}
	}
}
var current_category: String = "solids"
var current_side: String = "top"
var has_side_settings: bool = false
var block_settings: ConfigurableBlockSettings = null


func _ready() -> void:
	for side_setting in side_settings.sides_properties:
		side_settings.sides_properties[side_setting].node.set_category(current_category)
		side_settings.sides_properties[side_setting].node.set_side(current_side)
		side_settings.sides_properties[side_setting].node.set_key(side_setting)
		side_settings.sides_properties[side_setting].node.set_side_settings(side_settings.sides_properties[side_setting].side_settings)
		side_settings.sides_properties[side_setting].node.side_setting_changed.connect(_change_sides_properties.bind())
	side_settings_dropdown_button.pressed.connect(_show_dropdown)
	dropdown_popup.set_dropdown_size(Vector2(side_settings_dropdown_button.size.x, 240))
	dropdown_popup.return_dropdown_data.connect(_change_side.bind())
	populate_options()


func init(_block_settings: ConfigurableBlockSettings):
	block_settings = _block_settings


func _change_sides_properties(new_sides_properties: Dictionary):
	sides_dictionary[new_sides_properties.category][new_sides_properties.side].side_settings = new_sides_properties.side_settings
	if block_settings:
		var block_sides = block_settings.get_sides()
		if new_sides_properties.side in block_sides:
			var type = new_sides_properties.side
			var params = {}
			if sides_dictionary[new_sides_properties.category][new_sides_properties.side].side_settings != null:
				params = sides_dictionary[new_sides_properties.category][new_sides_properties.side].side_settings
			block_settings[new_sides_properties.side].set_type({"type": type, "params": params})


func _show_dropdown():
	if has_side_settings:
		dropdown_popup.show_popup(side_settings_dropdown_button.global_position.x, side_settings_dropdown_button.global_position.y + side_settings_dropdown_button.size.y)


func populate_options():
	dropdown_popup.clear()
	var current_sides_dictionary = sides_dictionary[current_category]
	var current_sides_dictionary_keys = current_sides_dictionary.keys()
	has_side_settings = false
	for side in current_sides_dictionary_keys:
		if current_sides_dictionary[side].setting in side_settings.sides_properties:
			has_side_settings = true
			dropdown_popup.add_option(current_sides_dictionary[side].label + " - " + side_settings.sides_properties[current_sides_dictionary[side].setting].label, {"category": current_category, "side": side, "setting": current_sides_dictionary[side].setting, "side_settings": current_sides_dictionary[side].side_settings})


func _update_sides(side_info: Dictionary):
	if side_info.has("side") and side_info.side in sides_dictionary[side_info.category]:
		if side_info.setting in side_settings.sides_properties and side_info.setting != sides_dictionary[side_info.category][side_info.side].setting:
			sides_dictionary[side_info.category][side_info.side].setting = side_info.setting
			sides_dictionary[side_info.category][side_info.side].side_settings = side_settings.sides_properties[side_info.setting].side_settings
		elif side_info.setting not in side_settings.sides_properties:
			sides_dictionary[side_info.category][side_info.side].setting = side_info.setting
			sides_dictionary[side_info.category][side_info.side].side_settings = null
		if block_settings:
			var block_sides = block_settings.get_sides()
			if side_info.side in block_sides:
				var type = sides_dictionary[side_info.category][side_info.side].setting
				var params = {}
				if sides_dictionary[side_info.category][side_info.side].side_settings != null:
					params = sides_dictionary[side_info.category][side_info.side].side_settings
				block_settings[side_info.side].set_type({"type": type, "params": params})
	if current_category != side_info.category:
		_change_category(side_info)
	if (side_info.has("side") and current_side == side_info.side) or !has_side_settings:
		_change_side(side_info)
	populate_options()


func _change_category(side_info: Dictionary):
	if side_info.category in sides_dictionary:
		current_category = side_info.category
		for child in side_settings.get_child_count():
			side_settings.get_child(child).set_category(current_category)
		_select_options(side_info)


func _change_side(side_info: Dictionary):
	if side_info.has("side") and side_info.side in sides_dictionary[side_info.category]:
		current_side = side_info.side
		for child in side_settings.get_child_count():
			side_settings.get_child(child).set_side(current_side)
		_select_options(side_info)


func _select_options(options_dictionary: Dictionary):
	if options_dictionary.setting in side_settings.sides_properties:
		side_settings_dropdown_button.text = sides_dictionary[options_dictionary.category][options_dictionary.side].label + " - " + side_settings.sides_properties[options_dictionary.setting].label
		show_option(options_dictionary)
	else:
		var current_sides_dictionary_keys = sides_dictionary[options_dictionary.category].keys()
		var still_has_options = false
		for side in current_sides_dictionary_keys:
			if sides_dictionary[options_dictionary.category][side].setting in side_settings.sides_properties:
				still_has_options = true
				side_settings_dropdown_button.text = sides_dictionary[options_dictionary.category][side].label + " - " + side_settings.sides_properties[sides_dictionary[options_dictionary.category][side].setting].label
				_change_side({"category": options_dictionary.category, "side": side, "setting": sides_dictionary[options_dictionary.category][side].setting})
				show_option({"category": options_dictionary.category, "side": side, "setting": sides_dictionary[options_dictionary.category][side].setting, "side_settings": sides_dictionary[options_dictionary.category][side].side_settings})
				break
		if !still_has_options:
			side_settings_dropdown_button.text = "None"
			show_option({})


func show_option(options_dictionary: Dictionary):
	for child in side_settings.get_child_count():
		side_settings.get_child(child).visible = false
	if "setting" in options_dictionary and options_dictionary.setting in side_settings.sides_properties:
		side_settings.sides_properties[options_dictionary.setting].node.visible = true
		if "side" in options_dictionary and "side_settings" in sides_dictionary[options_dictionary.category][options_dictionary.side] and sides_dictionary[options_dictionary.category][options_dictionary.side].side_settings != null:
			side_settings.sides_properties[options_dictionary.setting].node.set_side_settings(sides_dictionary[options_dictionary.category][options_dictionary.side].side_settings)
