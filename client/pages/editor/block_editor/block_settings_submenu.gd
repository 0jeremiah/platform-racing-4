extends Control

signal control_event

@onready var block_type_setting_button = $BlockTypeSetting/BlockTypeSettingButton
@onready var top_setting_button = $TopSetting/TopSettingButton
@onready var bottom_setting_button = $BottomSetting/BottomSettingButton
@onready var left_setting_button = $LeftSetting/LeftSettingButton
@onready var right_setting_button = $RightSetting/RightSettingButton
@onready var bump_setting_button = $BumpSetting/BumpSettingButton
@onready var dropdown_popup = $DropdownPopup

var active: bool = false
var block_type_dictionary: Dictionary = {
	"active": {"label": "Active", "setting": "active" },
	"inactive": {"label": "Inactive", "setting": "inactive"},
	"impervious": {"label": "Impervious", "setting": "impervious"},
	"start_position": {"label": "Start Position", "setting": "startpos"},
	"water": {"label": "Water", "setting": "water"},
	"move": {"label": "Move", "setting": "move"},
	"change": {"label": "Change", "setting": "change"},
	"egg": {"label": "Egg", "setting": "egg"},
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
var sides_settings: Array = []
var block_type_setting: String = ""
var top_setting: String = ""
var bottom_setting: String = ""
var left_setting: String = ""
var right_setting: String = ""
var bump_setting: String = ""


func _ready() -> void:
	sides_settings = [top_setting_button, bottom_setting_button, left_setting_button, right_setting_button,
	bump_setting_button]
	#var block_type_array_keys = block_type_array.keys()
	#for type_options in block_type_array.size():
		#block_type_setting_button.get_popup().add_item(block_type_array[block_type_array_keys[type_options]].label, type_options)
	#var sides_type_dictionary_keys = sides_type_dictionary.keys()
	#for side_setting in sides_settings.size():
		#for side_options in sides_type_dictionary.size():
			#sides_settings[side_setting].get_popup().add_item(sides_type_dictionary[sides_type_dictionary_keys[side_options]].label, side_options)
	block_type_setting_button.pressed.connect(_show_block_types.bind(block_type_setting_button))
	top_setting_button.pressed.connect(_show_sides_types.bind(top_setting_button))
	bottom_setting_button.pressed.connect(_show_sides_types.bind(bottom_setting_button))
	left_setting_button.pressed.connect(_show_sides_types.bind(left_setting_button))
	right_setting_button.pressed.connect(_show_sides_types.bind(right_setting_button))
	bump_setting_button.pressed.connect(_show_sides_types.bind(bump_setting_button))
	dropdown_popup.return_dropdown_data.connect(_set_button.bind())
	


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


func _show_block_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	for block_type in block_type_dictionary:
		dropdown_popup.add_option(block_type_dictionary[block_type].label, block_type)
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_sides_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	for side_type in sides_type_dictionary:
		dropdown_popup.add_option(sides_type_dictionary[side_type].label, side_type)
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _set_button(key: String):
	match dropdown_popup.holder:
		block_type_setting_button: block_type_setting = block_type_dictionary[key].setting; dropdown_popup.holder.text = block_type_dictionary[key].label
		top_setting_button: top_setting = sides_type_dictionary[key].setting; dropdown_popup.holder.text = sides_type_dictionary[key].label
		bottom_setting_button: bottom_setting = sides_type_dictionary[key].setting; dropdown_popup.holder.text = sides_type_dictionary[key].label
		left_setting_button: left_setting = sides_type_dictionary[key].setting; dropdown_popup.holder.text = sides_type_dictionary[key].label
		right_setting_button: right_setting = sides_type_dictionary[key].setting; dropdown_popup.holder.text = sides_type_dictionary[key].label
		bump_setting_button: bump_setting = sides_type_dictionary[key].setting; dropdown_popup.holder.text = sides_type_dictionary[key].label
