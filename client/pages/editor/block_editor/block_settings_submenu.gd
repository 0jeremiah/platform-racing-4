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
	"be_pushed": {"label": "Be Pushed", "setting": "bepushed"},
	"bounce": {"label": "Bounce", "setting": "bounce"},
	"crumble": {"label": "Crumble", "setting": "crumble"},
	"dec_stats": {"label": "Dec Stats", "setting": "decstats"},
	"enlarge": {"label": "Enlarge", "setting": "enlarge"},
	"explode": {"label": "Explode", "setting": "explode"},
	"finish": {"label": "Finish", "setting": "finish"},
	"gear": {"label": "Gear", "setting": "gear"},
	"give_hp": {"label": "Give HP", "setting": "givehp"},
	"give_item": {"label": "Give Item", "setting": "giveitem"},
	"give_stats": {"label": "Give Stats", "setting": "givestats"},
	"give_time": {"label": "Give Time", "setting": "givetime"},
	"hurt": {"label": "Hurt", "setting": "hurt"},
	"ice": {"label": "Ice", "setting": "ice"},
	"inc_stats": {"label": "Inc Stats", "setting": "incstats"},
	"push_down": {"label": "Push Down", "setting": "pushdown"},
	"push_left": {"label": "Push Left", "setting": "pushleft"},
	"push_right": {"label": "Push Right", "setting": "pushright"},
	"push_up": {"label": "Push Up", "setting": "pushup"},
	"rotate_left": {"label": "Rotate Left", "setting": "rotateleft"},
	"rotate_right": {"label": "Rotate Right", "setting": "rotateleft"},
	"safety": {"label": "Safety", "setting": "safety"},
	"shatter": {"label": "Shatter", "setting": "shatter"},
	"shrink": {"label": "Shrink", "setting": "shrink"},
	"sniper": {"label": "Sniper", "setting": "sniper"},
	"stick": {"label": "Stick", "setting": "stick"},
	"teleport": {"label": "Teleport", "setting": "teleport"},
	"vanish": {"label": "Vanish", "setting": "vanish"}
}
var sides_settings_array: Array = []
var matter_type_setting: String = "solid"
var block_type_setting: String = "active"
var top_setting: String = "active"
var bottom_setting: String = "active"
var left_setting: String = "active"
var right_setting: String = "active"
var bump_setting: String = "active"


func _ready() -> void:
	sides_settings_array = [top_setting_button, bottom_setting_button, left_setting_button, right_setting_button,
	bump_setting_button]
	#var block_type_array_keys = block_type_array.keys()
	#for type_options in block_type_array.size():
		#block_type_setting_button.get_popup().add_item(block_type_array[block_type_array_keys[type_options]].label, type_options)
	#var sides_type_dictionary_keys = sides_type_dictionary.keys()
	#for side_setting in sides_settings_array.size():
		#for side_options in sides_type_dictionary.size():
			#sides_settings_array[side_setting].get_popup().add_item(sides_type_dictionary[sides_type_dictionary_keys[side_options]].label, side_options)
	matter_type_setting_button.pressed.connect(_show_matter_types.bind(matter_type_setting_button))
	block_type_setting_button.pressed.connect(_show_block_types.bind(block_type_setting_button))
	top_setting_button.pressed.connect(_show_sides_types.bind(top_setting_button))
	bottom_setting_button.pressed.connect(_show_sides_types.bind(bottom_setting_button))
	left_setting_button.pressed.connect(_show_sides_types.bind(left_setting_button))
	right_setting_button.pressed.connect(_show_sides_types.bind(right_setting_button))
	bump_setting_button.pressed.connect(_show_sides_types.bind(bump_setting_button))
	dropdown_popup.return_dropdown_data.connect(_set_button.bind())
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
		dropdown_popup.add_option(matter_type_dictionary[matter_type_dictionary_keys[matter_type]].label, matter_type)
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_block_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	if matter_type_setting in matter_type_dictionary:
		dropdown_popup.holder = button
		if matter_type_setting == "solid":
			var solid_type_dictionary_keys = solid_type_dictionary.keys()
			for solid_type in solid_type_dictionary.size():
				dropdown_popup.add_option(solid_type_dictionary[solid_type_dictionary_keys[solid_type]].label, solid_type)
			dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)
		if matter_type_setting == "liquid":
			var liquid_type_dictionary_keys = liquid_type_dictionary.keys()
			for liquid_type in liquid_type_dictionary.size():
				dropdown_popup.add_option(liquid_type_dictionary[liquid_type_dictionary_keys[liquid_type]].label, liquid_type)
			dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)
		if matter_type_setting == "gas":
			var gas_type_dictionary_keys = gas_type_dictionary.keys()
			for gas_type in gas_type_dictionary.size():
				dropdown_popup.add_option(gas_type_dictionary[gas_type_dictionary_keys[gas_type]].label, gas_type)
			dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_sides_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	var sides_type_dictionary_keys = sides_type_dictionary.keys()
	for side_type in sides_type_dictionary.size():
		dropdown_popup.add_option(sides_type_dictionary[sides_type_dictionary_keys[side_type]].label, side_type)
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _set_button(new_index: int):
	var sides_type_dictionary_keys = sides_type_dictionary.keys()
	match dropdown_popup.holder:
		matter_type_setting_button: change_matter_type(new_index)
		block_type_setting_button: change_block_type(new_index)
		top_setting_button: top_setting = sides_type_dictionary_keys[new_index]; dropdown_popup.holder.text = sides_type_dictionary[sides_type_dictionary_keys[new_index]].label
		bottom_setting_button: bottom_setting = sides_type_dictionary_keys[new_index]; dropdown_popup.holder.text = sides_type_dictionary[sides_type_dictionary_keys[new_index]].label
		left_setting_button: left_setting = sides_type_dictionary_keys[new_index]; dropdown_popup.holder.text = sides_type_dictionary[sides_type_dictionary_keys[new_index]].label
		right_setting_button: right_setting = sides_type_dictionary_keys[new_index]; dropdown_popup.holder.text = sides_type_dictionary[sides_type_dictionary_keys[new_index]].label
		bump_setting_button: bump_setting = sides_type_dictionary_keys[new_index]; dropdown_popup.holder.text = sides_type_dictionary[sides_type_dictionary_keys[new_index]].label
	update_display()


func change_matter_type(new_index: int):
	var matter_type_dictionary_keys = matter_type_dictionary.keys()
	if matter_type_dictionary_keys[new_index] == "solid" and matter_type_setting != "solid":
		var solid_type_dictionary_keys = solid_type_dictionary.keys()
		block_type_setting = solid_type_dictionary_keys[0]
	elif matter_type_dictionary_keys[new_index] == "liquid" and matter_type_setting != "liquid":
		var liquid_type_dictionary_keys = liquid_type_dictionary.keys()
		block_type_setting = liquid_type_dictionary_keys[0]
	elif matter_type_dictionary_keys[new_index] == "gas" and matter_type_setting != "gas":
		var gas_type_dictionary_keys = gas_type_dictionary.keys()
		block_type_setting = gas_type_dictionary_keys[0]
	matter_type_setting = matter_type_dictionary_keys[new_index]


func change_block_type(new_index: int):
	if matter_type_setting == "solid":
		var solid_type_dictionary_keys = solid_type_dictionary.keys()
		block_type_setting = solid_type_dictionary_keys[new_index]
	elif matter_type_setting == "liquid":
		var liquid_type_dictionary_keys = liquid_type_dictionary.keys()
		block_type_setting = liquid_type_dictionary_keys[new_index]
	elif matter_type_setting == "gas":
		var gas_type_dictionary_keys = gas_type_dictionary.keys()
		block_type_setting = gas_type_dictionary_keys[new_index]


func update_display():
	var panel_size = Vector2(290, block_type_setting_button.get_parent().position.y + block_type_setting_button.get_parent().size.y + 20)
	sides_settings_seperator.visible = false
	block_options_seperator.visible = false
	sides_settings.visible = false
	move_settings.visible = false
	change_settings.visible = false
	matter_type_setting_button.text = matter_type_dictionary[matter_type_setting].label
	if matter_type_setting == "solid":
		block_type_setting_button.text = solid_type_dictionary[block_type_setting].label
	elif matter_type_setting == "liquid":
		block_type_setting_button.text = liquid_type_dictionary[block_type_setting].label
	elif matter_type_setting == "gas":
		block_type_setting_button.text = gas_type_dictionary[block_type_setting].label
	if matter_type_setting == "solid" and block_type_setting != "change" and block_type_setting != "egg":
		sides_settings_seperator.position.y = panel_size.y - 10
		sides_settings_seperator.visible = true
		sides_settings.visible = true
		panel_size.y += (sides_settings.position.y + sides_settings.size.y + 20) - panel_size.y
	top_setting_button.text = sides_type_dictionary[top_setting].label
	bottom_setting_button.text = sides_type_dictionary[bottom_setting].label
	left_setting_button.text = sides_type_dictionary[left_setting].label
	right_setting_button.text = sides_type_dictionary[right_setting].label
	bump_setting_button.text = sides_type_dictionary[bump_setting].label
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
	block_settings_panel.size = panel_size
	sides_settings_seperator.size.x = panel_size.x - 40
	block_options_seperator.size.x = panel_size.x - 40
