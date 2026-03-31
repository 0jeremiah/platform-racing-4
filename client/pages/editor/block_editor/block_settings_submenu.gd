extends Control

signal control_event

@onready var block_settings_panel = $BlockSettingsPanel
@onready var sides_settings_seperator = $SidesSettingsSeperator
@onready var block_options_seperator = $BlockOptionsSeperator
@onready var sides_options_seperator = $SidesOptionsSeperator
@onready var matter_type_setting_button = $MatterTypeSetting/MatterTypeSettingButton
@onready var block_type_setting_button = $BlockTypeSetting/BlockTypeSettingButton
@onready var sides_settings = $SidesSettings
@onready var top_setting_button = $SidesSettings/TopSetting/TopSettingButton
@onready var bottom_setting_button = $SidesSettings/BottomSetting/BottomSettingButton
@onready var left_setting_button = $SidesSettings/LeftSetting/LeftSettingButton
@onready var right_setting_button = $SidesSettings/RightSetting/RightSettingButton
@onready var bump_setting_button = $SidesSettings/BumpSetting/BumpSettingButton
@onready var dropdown_popup = $DropdownPopup
@onready var move_settings = $MoveSettings
@onready var change_settings = $ChangeSettings
@onready var side_options_container = $SideOptionsContainer
@onready var side_options = $SideOptionsContainer/SideOptions

var active: bool = false
var matter_type_dictionary: Dictionary = {
	"solid": {"label": "Solid", "setting": "solid" },
	"liquid": {"label": "Liquid", "setting": "liquid"},
	"gas": {"label": "Gas", "setting": "gas"}
}
var solid_type_dictionary: Dictionary = {
	"active": {"label": "Active", "setting": "active" },
	"impervious": {"label": "Impervious", "setting": "impervious"},
	"move": {"label": "Move", "setting": "move"},
	"change": {"label": "Change", "setting": "change"},
	"egg": {"label": "Egg", "setting": "egg"}
}
var liquid_type_dictionary: Dictionary = {
	"water": {"label": "Water", "setting": "water"}
}
var gas_type_dictionary: Dictionary = {
	"inactive": {"label": "Inactive", "setting": "inactive"},
	"start_position": {"label": "Start Position", "setting": "startpos"},
	"sun": {"label": "Sun", "setting": "sun"},
	"moon": {"label": "Moon", "setting": "moon"},
	"firefly": {"label": "Firefly", "setting": "firefly"}
}
var sides_type_dictionary: Dictionary = {
	"active": {"label": "Active", "setting": "active"},
	"inactive": {"label": "Inactive", "setting": "inactive"},
	"appear": {"label": "Appear", "setting": "appear"},
	"be_pushed": {"label": "Be Pushed", "setting": "push"},
	"bounce": {"label": "Bounce", "setting": "bounce"},
	"crumble": {"label": "Crumble", "setting": "crumble"},
	"sad": {"label": "Dec Stats", "setting": "sad"},
	"enlarge": {"label": "Enlarge", "setting": "enlarge"},
	"explode": {"label": "Explode", "setting": "mine"},
	"finish": {"label": "Finish", "setting": "finish"},
	"gear": {"label": "Gear", "setting": "gear"},
	"heart": {"label": "Give HP", "setting": "heart"},
	"item": {"label": "Give Item", "setting": "item"},
	"give_stats": {"label": "Give Stats", "setting": "custom_stats"},
	"give_time": {"label": "Give Time", "setting": "time"},
	"hurt": {"label": "Hurt", "setting": "hurt"},
	"ice": {"label": "Ice", "setting": "ice"},
	"happy": {"label": "Inc Stats", "setting": "happy"},
	"arrow_down": {"label": "Push Down", "setting": "arrow_down"},
	"arrow_left": {"label": "Push Left", "setting": "arrow_left"},
	"arrow_right": {"label": "Push Right", "setting": "arrow_right"},
	"arrow_up": {"label": "Push Up", "setting": "arrow_up"},
	"rotate_left": {"label": "Rotate Left", "setting": "rotate_left"},
	"rotate_right": {"label": "Rotate Right", "setting": "rotate_right"},
	"safety": {"label": "Safety", "setting": "safety"},
	"shatter": {"label": "Shatter", "setting": "shatter"},
	"shrink": {"label": "Shrink", "setting": "shrink"},
	"sniper": {"label": "Sniper", "setting": "sniper"},
	"sticky": {"label": "Sticky", "setting": "sticky"},
	"teleport": {"label": "Teleport", "setting": "teleport"},
	"vanish": {"label": "Vanish", "setting": "vanish"}
}
var matter_type_setting: String = "solid"
var block_type_setting: String = "active"
var top_setting: String = "active"
var bottom_setting: String = "active"
var left_setting: String = "active"
var right_setting: String = "active"
var bump_setting: String = "active"
#var sides_dictionary: Dictionary = {
	#"top": {"label": "Top", "setting": "active", "options": null},
	#"bottom": {"label": "Bottom", "setting": "active", "options": null},
	#"left": {"label": "Left", "setting": "active", "options": null},
	#"right": {"label": "Right", "setting": "active", "options": null},
	#"bump": {"label": "Bump", "setting": "active", "options": null},
	#"any_side": {"label": "Any Side", "setting": "active", "options": null},
	#"stand": {"label": "Stand", "setting": "active", "options": null}#,
	#"area": {"label": "Area", "setting": "active"}
#}


func _ready() -> void:
	matter_type_setting_button.pressed.connect(_show_matter_types.bind(matter_type_setting_button))
	block_type_setting_button.pressed.connect(_show_block_types.bind(block_type_setting_button))
	for side in side_options.sides_dictionary.size():
		var sides_dictionary_keys = side_options.sides_dictionary.keys()
		var side_control = Control.new()
		side_control.size = Vector2(250.0, 30.0)
		side_control.position = Vector2(0, 40 * side)
		var side_label = RichTextLabel.new()
		side_label.size = Vector2(120.0, 30.0)
		side_label.set("theme_override_font_sizes/normal_font_size", 20)
		side_label.text = side_options.sides_dictionary[sides_dictionary_keys[side]].label + ":"
		side_label.horizontal_alignment = 2
		side_label.vertical_alignment = 1
		var side_button = Button.new()
		side_button.size = Vector2(120.0, 30.0)
		side_button.set("theme_override_font_sizes/font_size", 17)
		side_button.text = sides_type_dictionary[side_options.sides_dictionary[sides_dictionary_keys[side]].setting].label
		side_button.alignment = 0
		side_button.clip_text = true
		side_button.position = Vector2(130.0, 0.0)
		side_control.add_child(side_label)
		side_control.add_child(side_button)
		sides_settings.add_child(side_control)
		side_button.pressed.connect(_show_sides_types.bind(sides_dictionary_keys[side], side_button))
		sides_settings.size = Vector2(250, side_control.position.y + side_control.size.y)
	dropdown_popup.return_dropdown_data.connect(_change_setting.bind())
	update_display()
	


func init() -> void:
	pass


func deactivate():
	active = false


func activate():
	active = true


func _physics_process(_delta: float) -> void:
	if active:
		visible = true
	else:
		visible = false


func _show_matter_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	var matter_type_dictionary_keys = matter_type_dictionary.keys()
	for matter_type in matter_type_dictionary.size():
		dropdown_popup.add_option(matter_type_dictionary[matter_type_dictionary_keys[matter_type]].label, {"key": matter_type_dictionary_keys[matter_type], "button": button})
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_block_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	if matter_type_setting in matter_type_dictionary:
		dropdown_popup.holder = button
		if matter_type_setting == "solid":
			var solid_type_dictionary_keys = solid_type_dictionary.keys()
			for solid_type in solid_type_dictionary.size():
				dropdown_popup.add_option(solid_type_dictionary[solid_type_dictionary_keys[solid_type]].label, {"key": solid_type_dictionary_keys[solid_type], "button": button})
			dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)
		if matter_type_setting == "liquid":
			var liquid_type_dictionary_keys = liquid_type_dictionary.keys()
			for liquid_type in liquid_type_dictionary.size():
				dropdown_popup.add_option(liquid_type_dictionary[liquid_type_dictionary_keys[liquid_type]].label, {"key": liquid_type_dictionary_keys[liquid_type], "button": button})
			dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)
		if matter_type_setting == "gas":
			var gas_type_dictionary_keys = gas_type_dictionary.keys()
			for gas_type in gas_type_dictionary.size():
				dropdown_popup.add_option(gas_type_dictionary[gas_type_dictionary_keys[gas_type]].label, {"key": gas_type_dictionary_keys[gas_type], "button": button})
			dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_sides_types(side: String, button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	var sides_type_dictionary_keys = sides_type_dictionary.keys()
	for side_type in sides_type_dictionary.size():
		dropdown_popup.add_option(sides_type_dictionary[sides_type_dictionary_keys[side_type]].label, {"side": side, "key": sides_type_dictionary_keys[side_type], "setting": sides_type_dictionary[sides_type_dictionary_keys[side_type]].setting, "button": button})
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _change_setting(selected_dictionary: Dictionary):
	if selected_dictionary.button == matter_type_setting_button:
		if selected_dictionary.key == "solid" and matter_type_setting != "solid":
			var solid_type_dictionary_keys = solid_type_dictionary.keys()
			block_type_setting = solid_type_dictionary[solid_type_dictionary_keys[0]].setting
			block_type_setting_button.text = solid_type_dictionary[solid_type_dictionary_keys[0]].label
		elif selected_dictionary.key == "liquid" and matter_type_setting != "liquid":
			var liquid_type_dictionary_keys = liquid_type_dictionary.keys()
			block_type_setting = liquid_type_dictionary[liquid_type_dictionary_keys[0]].setting
			block_type_setting_button.text = liquid_type_dictionary[liquid_type_dictionary_keys[0]].label
		elif selected_dictionary.key == "gas" and matter_type_setting != "gas":
			var gas_type_dictionary_keys = gas_type_dictionary.keys()
			block_type_setting = gas_type_dictionary[gas_type_dictionary_keys[0]].setting
			block_type_setting_button.text = gas_type_dictionary[gas_type_dictionary_keys[0]].label
		matter_type_setting = matter_type_dictionary[selected_dictionary.key].setting
		matter_type_setting_button.text = matter_type_dictionary[selected_dictionary.key].label
	elif selected_dictionary.button == block_type_setting_button:
		if matter_type_setting == "solid":
			block_type_setting = solid_type_dictionary[selected_dictionary.key].setting
			block_type_setting_button.text = solid_type_dictionary[selected_dictionary.key].label
		elif matter_type_setting == "liquid":
			block_type_setting = liquid_type_dictionary[selected_dictionary.key].setting
			block_type_setting_button.text = liquid_type_dictionary[selected_dictionary.key].label
		elif matter_type_setting == "gas":
			block_type_setting = gas_type_dictionary[selected_dictionary.key].setting
			block_type_setting_button.text = gas_type_dictionary[selected_dictionary.key].label
	else:
		selected_dictionary.button.text = sides_type_dictionary[selected_dictionary.key].label
		side_options._update_sides(selected_dictionary)
	update_display()


func update_display():
	var panel_size = Vector2(290, block_type_setting_button.get_parent().position.y + block_type_setting_button.get_parent().size.y + 20)
	sides_settings_seperator.visible = false
	block_options_seperator.visible = false
	sides_options_seperator.visible = false
	sides_settings.visible = false
	move_settings.visible = false
	change_settings.visible = false
	side_options_container.visible = false
	sides_settings_seperator.size.x = panel_size.x - 40
	if matter_type_setting == "solid" and block_type_setting != "change" and block_type_setting != "egg":
		sides_settings_seperator.position.y = panel_size.y - 10
		sides_settings_seperator.visible = true
		sides_settings.visible = true
		panel_size.y += (sides_settings.position.y + sides_settings.size.y + 20) - panel_size.y
	if block_type_setting == "move":
		block_options_seperator.position.y = panel_size.y - 10
		block_options_seperator.visible = true
		move_settings.position.y = panel_size.y
		move_settings.visible = true
		panel_size.x += (move_settings.position.x + move_settings.size.x + 20) - panel_size.x
		panel_size.y += (move_settings.position.y + move_settings.size.y + 20) - panel_size.y
	elif block_type_setting == "change":
		block_options_seperator.position.y = panel_size.y - 10
		block_options_seperator.visible = true
		change_settings.position.y = panel_size.y
		change_settings.visible = true
		panel_size.x += (change_settings.position.x + change_settings.size.x + 20) - panel_size.x
		panel_size.y += (change_settings.position.y + change_settings.size.y + 20) - panel_size.y
	if matter_type_setting == "solid" and block_type_setting != "change" and side_options.has_options:
		sides_options_seperator.visible = true
		side_options_container.visible = true
		panel_size.x += (side_options_container.position.x + side_options_container.size.x + 20) - panel_size.x
	if block_type_setting != "move" and !side_options_container.visible:
		sides_settings_seperator.size.x = panel_size.x - 40
	block_settings_panel.size = panel_size
	block_options_seperator.size.x = panel_size.x - 40
