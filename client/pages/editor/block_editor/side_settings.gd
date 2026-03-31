extends Control

signal side_changed

@onready var options_dropdown_button = $OptionsDropdownButton
@onready var side_options = $SideOptions
@onready var dropdown_popup = $DropdownPopup

var sides_dictionary: Dictionary = {
	"top": {"label": "Top", "setting": "active", "options": null},
	"bottom": {"label": "Bottom", "setting": "active", "options": null},
	"left": {"label": "Left", "setting": "active", "options": null},
	"right": {"label": "Right", "setting": "active", "options": null},
	"bump": {"label": "Bump", "setting": "active", "options": null},
	"any_side": {"label": "Any Side", "setting": "active", "options": null},
	"stand": {"label": "Stand", "setting": "active", "options": null}#,
	#"area": {"label": "Area", "setting": "active", "options": null}
}
var current_side: String = "top"
var has_options: bool = false


func _ready() -> void:
	var sides_properties_keys = side_options.sides_properties.keys()
	for child in side_options.get_child_count():
		side_options.get_child(child).set_side(current_side)
		side_options.get_child(child).set_key(sides_properties_keys[child])
		side_options.get_child(child).set_options(side_options.sides_properties[sides_properties_keys[child]].options)
		side_options.sides_properties[sides_properties_keys[child]].node = side_options.get_child(child)
		side_options.get_child(child).side_option_changed.connect(_change_sides_properties.bind())
	options_dropdown_button.pressed.connect(_show_dropdown)
	dropdown_popup.set_dropdown_size(Vector2(options_dropdown_button.size.x, 240))
	dropdown_popup.return_dropdown_data.connect(change_side.bind())
	populate_options()


func _change_sides_properties(new_sides_properties: Dictionary):
	sides_dictionary[new_sides_properties.side].options = new_sides_properties.options


func _show_dropdown():
	if has_options:
		dropdown_popup.show_popup(options_dropdown_button.global_position.x, options_dropdown_button.global_position.y + options_dropdown_button.size.y)


func populate_options():
	dropdown_popup.clear()
	var sides_dictionary_keys = sides_dictionary.keys()
	has_options = false
	for side in sides_dictionary_keys:
		print(sides_dictionary[side].setting)
		if sides_dictionary[side].setting in side_options.sides_properties:
			has_options = true
			dropdown_popup.add_option(sides_dictionary[side].label + " - " + side_options.sides_properties[sides_dictionary[side].setting].label, {"side": side, "setting": sides_dictionary[side].setting, "options": sides_dictionary[side].options})


func _update_sides(side_info: Dictionary):
	if side_info.side in sides_dictionary:
		if side_info.setting in side_options.sides_properties and side_info.setting != sides_dictionary[side_info.side].setting:
			sides_dictionary[side_info.side].setting = side_info.setting
			sides_dictionary[side_info.side].options = side_options.sides_properties[side_info.setting].options
		elif side_info.setting not in side_options.sides_properties:
			sides_dictionary[side_info.side].setting = side_info.setting
			sides_dictionary[side_info.side].options = null
	if current_side == side_info.side:
		change_side(side_info)
	else:
		var sides_dictionary_keys = sides_dictionary.keys()
		for side in sides_dictionary_keys:
			if sides_dictionary[side].setting in side_options.sides_properties:
				change_side({"side": side, "setting": sides_dictionary[side].setting, "options": sides_dictionary[side].options})
				break
	populate_options()
	


func change_side(side_info: Dictionary):
	if side_info.side in sides_dictionary:
		current_side = side_info.side
		for child in side_options.get_child_count():
			side_options.get_child(child).set_side(current_side)
		_select_options(side_info)


func _select_options(options_dictionary: Dictionary):
	if options_dictionary.setting in side_options.sides_properties:
		options_dropdown_button.text = sides_dictionary[options_dictionary.side].label + " - " + side_options.sides_properties[options_dictionary.setting].label
		show_option(options_dictionary)
	else:
		var sides_dictionary_keys = sides_dictionary.keys()
		var still_has_options = false
		for side in sides_dictionary_keys:
			if sides_dictionary[side].setting in side_options.sides_properties:
				still_has_options = true
				options_dropdown_button.text = sides_dictionary[side].label + " - " + side_options.sides_properties[sides_dictionary[side].setting].label
				change_side({"side": side, "setting": sides_dictionary[side].setting})
				show_option({"side": side, "setting": sides_dictionary[side].setting, "options": sides_dictionary[side].options})
				break
		if !still_has_options:
			options_dropdown_button.text = "None"
			show_option({})


func show_option(options_dictionary: Dictionary):
	for child in side_options.get_child_count():
		side_options.get_child(child).visible = false
	if "setting" in options_dictionary and options_dictionary.setting in side_options.sides_properties:
		side_options.sides_properties[options_dictionary.setting].node.visible = true
		if "side" in options_dictionary and "options" in sides_dictionary[options_dictionary.side] and sides_dictionary[options_dictionary.side].options != null:
			side_options.sides_properties[options_dictionary.setting].node.set_options(sides_dictionary[options_dictionary.side].options)
