extends Control

signal side_changed

@onready var options_dropdown_button = $OptionsDropdownButton
@onready var options = $Options
@onready var dropdown_popup = $DropdownPopup

var sides_properties: Dictionary = {
	"appear": {"label": "Appear Options", "options": {"animation_duration": 0.3, "cooldown": 2.0}, "node": null},
	"arrow_down": {"label": "Down Arrow Options", "options": {"force": 110.0, "direction": Vector2(0.0, 1.0)}, "node": null},
	"arrow_left": {"label": "Left Arrow Options", "options": {"force": 125.0, "direction": Vector2(-1.0, 0.0)}, "node": null},
	"arrow_right": {"label": "Right Arrow Options", "options": {"force": 125.0, "direction": Vector2(1.0, 0.0)}, "node": null},
	"arrow_up": {"label": "Up Arrow Options", "options": {"force": 110.0, "direction": Vector2(0.0, -1.0)}, "node": null},
	"bounce": {"label": "Bounce Options", "options": {"bounciness": 0.1, "speed_limit": 12500.0}, "node": null},
	"crumble": {"label": "Crumble Options", "options": {"health": 100, "armor": 10, "damage_ratio": 0.03}, "node": null},
	"custom_stats": {"label": "Custom Stats Options", "options": {"reset": false, "speed": 50, "accel": 50, "jump": 50, "skill": 50}, "node": null},
	"enlarge": {"label": "Enlarge Options", "options": {"exact": false, "multiplier": 0.5}, "node": null},
	"mine": {"label": "Mine Options", "options": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": null},
	"gear": {"label": "Gear Options", "options": {"rotation": 90.0, "tick": 4000.0, "tock": 500.0}, "node": null},
	"happy": {"label": "Happy Options", "options": {"amount": 5}, "node": null},
	"heart": {"label": "Heart Options", "options": {"hp": 1.0, "exact": false, "invincibility": false}, "node": null},
	"hurt": {"label": "Hurt Options", "options": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": null},
	"ice": {"label": "Ice Options", "options": {"ice_friction": 0.2}, "node": null},
	"item": {"label": "Item Options", "options": {"item_supply": 1, "infinite": false, "item_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]}, "node": null},
	"rotate_left": {"label": "Rotate Left Options", "options": {"rotations": -1, "rotation_speed": 0.025}, "node": null},
	"rotate_right": {"label": "Rotate Right Options", "options": {"rotations": 1, "rotation_speed": 0.025}, "node": null},
	"sad": {"label": "Sad Options", "options": {"amount": 5}, "node": null},
	"shrink": {"label": "Shrink Options", "options": {"exact": false, "multiplier": 0.5}, "node": null},
	"sticky": {"label": "Sticky Options", "options": {"stickiness": 2.5}, "node": null},
	"vanish": {"label": "Vanish Options", "options": {"animation_duration": 0.3, "cooldown": 2.0}, "node": null}
}
var sides_dictionary: Dictionary = {
	"top": {"label": "Top", "setting": "active", "options": null},
	"bottom": {"label": "Bottom", "setting": "active", "options": null},
	"left": {"label": "Left", "setting": "active", "options": null},
	"right": {"label": "Right", "setting": "active", "options": null},
	"bump": {"label": "Bump", "setting": "active", "options": null},
	"any_side": {"label": "Any Side", "setting": "active", "options": null},
	"stand": {"label": "Stand", "setting": "active", "options": null}#,
	#"area": {"label": "Area", "setting": "active"}
}
var current_side: String = "top"
var has_options: bool = false


func _ready() -> void:
	var sides_properties_keys = sides_properties.keys()
	for child in options.get_child_count():
		options.get_child(child).set_side(current_side)
		options.get_child(child).set_key(sides_properties_keys[child])
		options.get_child(child).set_options(sides_properties[sides_properties_keys[child]].options)
		sides_properties[sides_properties_keys[child]].node = options.get_child(child)
		options.get_child(child).side_option_changed.connect(_change_sides_properties.bind())
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
		if sides_dictionary[side].setting in sides_properties:
			has_options = true
			dropdown_popup.add_option(sides_dictionary[side].label + " - " + sides_properties[sides_dictionary[side].setting].label, {"side": side, "setting": sides_dictionary[side].setting, "options": sides_dictionary[side].options})


func _update_sides(side_info: Dictionary):
	if side_info.side in sides_dictionary:
		if side_info.setting in sides_properties and side_info.setting != sides_dictionary[side_info.side].setting:
			sides_dictionary[side_info.side].setting = side_info.setting
			sides_dictionary[side_info.side].options = sides_properties[side_info.setting].options
		elif side_info.setting not in sides_properties:
			sides_dictionary[side_info.side].setting = side_info.setting
			sides_dictionary[side_info.side].options = null
	if current_side == side_info.side:
		change_side(side_info)
	else:
		var sides_dictionary_keys = sides_dictionary.keys()
		for side in sides_dictionary_keys:
			if sides_dictionary[side].setting in sides_properties:
				change_side({"side": side, "setting": sides_dictionary[side].setting, "options": sides_dictionary[side].options})
				break
	populate_options()
	


func change_side(side_info: Dictionary):
	if side_info.side in sides_dictionary:
		current_side = side_info.side
		for child in options.get_child_count():
			options.get_child(child).set_side(current_side)
		_select_options(side_info)


func _select_options(options_dictionary: Dictionary):
	if options_dictionary.setting in sides_properties:
		options_dropdown_button.text = sides_dictionary[options_dictionary.side].label + " - " + sides_properties[options_dictionary.setting].label
		show_option(options_dictionary)
	else:
		var sides_dictionary_keys = sides_dictionary.keys()
		var still_has_options = false
		for side in sides_dictionary_keys:
			if sides_dictionary[side].setting in sides_properties:
				still_has_options = true
				options_dropdown_button.text = sides_dictionary[side].label + " - " + sides_properties[sides_dictionary[side].setting].label
				change_side({"side": side, "setting": sides_dictionary[side].setting})
				show_option({"side": side, "setting": sides_dictionary[side].setting, "options": sides_dictionary[side].options})
				break
		if !still_has_options:
			options_dropdown_button.text = "None"
			show_option({})


func show_option(options_dictionary: Dictionary):
	for child in options.get_child_count():
		options.get_child(child).visible = false
	if "setting" in options_dictionary and options_dictionary.setting in sides_properties:
		sides_properties[options_dictionary.setting].node.visible = true
		if "side" in options_dictionary and "options" in sides_dictionary[options_dictionary.side] and sides_dictionary[options_dictionary.side].options != null:
			sides_properties[options_dictionary.setting].node.set_options(sides_dictionary[options_dictionary.side].options)
