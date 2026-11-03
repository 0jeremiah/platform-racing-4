class_name BlockSettingsSubmenu
extends Control

#signal control_event

@onready var block_settings_panel = $BlockSettingsPanel
@onready var block_sides_seperator = $BlockSidesSeperator
@onready var block_settings_seperator = $BlockSettingsSeperator
@onready var matter_type_setting_button = $MatterTypeSetting/MatterTypeSettingButton
@onready var block_type_setting_button = $BlockTypeSetting/BlockTypeSettingButton
@onready var sides_settings = $SidesSettings
@onready var block_settings_menu = $BlockSettingsMenu
@onready var dropdown_popup = preload("res://ui/dropdown/dropdownpopup.gd")

static var block_settings: ConfigurableBlockSettings = ConfigurableBlockSettings.new()

# all available options the block settings submenu can see
# its very convoluted but with the upside that you can add new options and it will be added automatically
static var settings_presets: Dictionary = {
	"matter_types": {
		"solid": {
			"label": "Solid",
			"setting": ConfigurableBlockSettings.SOLID,
			"side_setting_category": "solids",
			"block_types": {
				"active": {"label": "Active", "setting": ConfigurableBlockSettings.ACTIVE, "side_category": "block_sides"},
				"impervious": {"label": "Impervious", "setting": ConfigurableBlockSettings.IMPERVIOUS, "side_category": "block_sides"},
				"move": {"label": "Move", "setting": ConfigurableBlockSettings.MOVE, "side_category": "block_sides"},
				"change": {"label": "Change", "setting": ConfigurableBlockSettings.CHANGE, "side_category": "block_sides"},
				"gear": {"label": "Gear", "setting": ConfigurableBlockSettings.GEAR, "side_category": "block_sides"},
				"egg": {"label": "Egg", "setting": ConfigurableBlockSettings.EGG, "side_category": "block_sides"}
				},
			"side_categories": {
				"block_sides": {
					"active": {"label": "Active", "setting": ConfigurableBlockSideSettings.ACTIVE},
					"inactive": {"label": "Inactive", "setting": ConfigurableBlockSideSettings.INACTIVE},
					"appear": {"label": "Appear", "setting": ConfigurableBlockSideSettings.APPEAR},
					"arrow": {"label": "Arrow", "setting": ConfigurableBlockSideSettings.ARROW},
					"attach": {"label": "Attach", "setting": ConfigurableBlockSideSettings.ATTACH},
					"push": {"label": "Be Pushed", "setting": ConfigurableBlockSideSettings.PUSH},
					"bounce": {"label": "Bounce", "setting": ConfigurableBlockSideSettings.BOUNCE},
					"change_size": {"label": "Change Size", "setting": ConfigurableBlockSideSettings.CHANGE_SIZE},
					"change_stats": {"label": "Change Stats", "setting": ConfigurableBlockSideSettings.CHANGE_STATS},
					"crumble": {"label": "Crumble", "setting": ConfigurableBlockSideSettings.CRUMBLE},
					"custom_stats": {"label": "Custom Stats", "setting": ConfigurableBlockSideSettings.CUSTOM_STATS},
					"explode": {"label": "Explode", "setting": ConfigurableBlockSideSettings.MINE},
					"finish": {"label": "Finish", "setting": ConfigurableBlockSideSettings.FINISH},
					"heart": {"label": "Give HP", "setting": ConfigurableBlockSideSettings.HEART},
					"item": {"label": "Give Item", "setting": ConfigurableBlockSideSettings.ITEM},
					"time": {"label": "Give Time", "setting": ConfigurableBlockSideSettings.TIME},
					"hurt": {"label": "Hurt", "setting": ConfigurableBlockSideSettings.HURT},
					"ice": {"label": "Ice", "setting": ConfigurableBlockSideSettings.ICE},
					"rotate": {"label": "Rotate", "setting": ConfigurableBlockSideSettings.ROTATE},
					"safety": {"label": "Safety", "setting": ConfigurableBlockSideSettings.SAFETY},
					"shatter": {"label": "Shatter", "setting": ConfigurableBlockSideSettings.SHATTER},
					"sniper": {"label": "Sniper", "setting": ConfigurableBlockSideSettings.SNIPER},
					"sticky": {"label": "Sticky", "setting": ConfigurableBlockSideSettings.STICKY},
					"teleport": {"label": "Teleport", "setting": ConfigurableBlockSideSettings.TELEPORT},
					"vanish": {"label": "Vanish", "setting": ConfigurableBlockSideSettings.VANISH}
				}
			}
		},
		"liquid": {
			"label": "Liquid",
			"setting": ConfigurableBlockSettings.LIQUID,
			"side_setting_category": "non-solids",
			"block_types": {
				"water": {"label": "Water", "setting": ConfigurableBlockSettings.WATER, "side_category": "water"}
			},
			"side_categories": {
				"water": {
					"water": {"label": "Water", "setting": ConfigurableBlockSideSettings.WATER}
				}
			}
		},
		"gas": {
			"label": "Gas",
			"setting": ConfigurableBlockSettings.GAS,
			"side_setting_category": "non-solids",
			"block_types": {
				"inactive": {"label": "Inactive", "setting": ConfigurableBlockSettings.INACTIVE, "side_category": "inactive"},
				"start_position": {"label": "Start Position", "setting": ConfigurableBlockSettings.START_POSITION, "side_category": "start_position"},
				"switch": {"label": "Switch", "setting": ConfigurableBlockSettings.SWITCH, "side_category": "switch"},
				"lightbreaker": {"label": "Lightbreaker", "setting": ConfigurableBlockSettings.LIGHTBREAKER, "side_category": "lightbreakers"},
			},
			"side_categories": {
				"inactive": {
					"inactive": {"label": "Inactive", "setting": ConfigurableBlockSideSettings.INACTIVE}
				},
				"start_position": {
					"start_position": {"label": "Start Position", "setting": ConfigurableBlockSideSettings.START_POSITION}
				},
				"switch": {
					"switch": {"label": "Switch", "setting": ConfigurableBlockSideSettings.SWITCH}
				},
				"lightbreakers": {
					"lightbreaker": {"label": "Lightbreaker", "setting": ConfigurableBlockSideSettings.LIGHTBREAKER}
				}
			}
		}
	}
}

var active: bool = false
var editor_events: EditorEvents
var dropdown_options: Array = []


func _ready() -> void:
	matter_type_setting_button.pressed.connect(_show_matter_types.bind(matter_type_setting_button))
	block_type_setting_button.pressed.connect(_show_block_types.bind(block_type_setting_button))
	update_display()


func init() -> void:
	block_settings_menu.init(block_settings)
	editor_events.editor_event.connect(_on_editor_event)


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta: float) -> void:
	if active:
		visible = true
	else:
		visible = false


func _show_matter_types(button: Button):
	dropdown_options = []
	for matter_type in settings_presets.matter_types:
		dropdown_options.append({"label": settings_presets.matter_types[matter_type].label, "data": {"category": settings_presets.matter_types[matter_type].side_setting_category, "setting": settings_presets.matter_types[matter_type].setting, "button": button}})
	PopupManager.add_custom_popup(dropdown_popup, {"dropdownpicker_func": Callable(self, "_change_setting"), "dropdown_size": Vector2(button.size.x, 200), "options": dropdown_options, "popup_global_position": Vector2(button.global_position.x, button.global_position.y + button.size.y)}, self)


func _show_block_types(button: Button):
	dropdown_options = []
	var matter_type = settings_presets.matter_types.get(block_settings.matter_type, settings_presets.matter_types[settings_presets.matter_types.keys()[0]])
	var side_setting_category = matter_type.side_setting_category
	var matter_type_block_types = matter_type.block_types
	for matter_type_block_type in matter_type_block_types:
		dropdown_options.append({"label": matter_type_block_types[matter_type_block_type].label, "data": {"category": side_setting_category, "setting": matter_type_block_types[matter_type_block_type].setting, "button": button}})
	PopupManager.add_custom_popup(dropdown_popup, {"dropdownpicker_func": Callable(self, "_change_setting"), "dropdown_size": Vector2(button.size.x, 200), "options": dropdown_options, "popup_global_position": Vector2(button.global_position.x, button.global_position.y + button.size.y)}, self)


func _show_sides_types(side: String, button: Button):
	dropdown_options = []
	var matter_type = settings_presets.matter_types.get(block_settings.matter_type, settings_presets.matter_types[settings_presets.matter_types.keys()[0]])
	var side_setting_category = matter_type.side_setting_category
	var matter_type_block_types = matter_type.block_types
	var block_type = matter_type_block_types.get(block_settings.block_type, matter_type_block_types[matter_type_block_types.keys()[0]])
	var side_category = matter_type.side_categories.get(block_type.side_category, matter_type.side_categories[matter_type.side_categories.keys()[0]])
	for side_type in side_category:
		dropdown_options.append({"label": side_category[side_type].label, "data": {"category": side_setting_category, "side": side, "setting": side_category[side_type].setting, "button": button}})
	PopupManager.add_custom_popup(dropdown_popup, {"dropdownpicker_func": Callable(self, "_change_setting"), "dropdown_size": Vector2(button.size.x, 200), "options": dropdown_options, "popup_global_position": Vector2(button.global_position.x, button.global_position.y + button.size.y)}, self)


func _change_setting(selected_dictionary: Dictionary):
	if selected_dictionary.button == matter_type_setting_button:
		block_settings.matter_type = selected_dictionary.setting
	elif selected_dictionary.button == block_type_setting_button:
		block_settings.block_type = selected_dictionary.setting
	block_settings_menu.update_side_settings(selected_dictionary)
	block_settings_menu.update_settings_menu()
	update_display()


func _on_editor_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_BLOCK_SETTINGS:
		block_settings.import_settings(event.settings)
		var sides = block_settings.get_sides()
		var matter_type = settings_presets.matter_types.get(block_settings.matter_type, settings_presets.matter_types[settings_presets.matter_types.keys()[0]])
		var side_setting_category = matter_type.side_setting_category
		for side in sides:
			var updated_side =  {"category": side_setting_category, "side": side, "setting": sides[side].type, "side_settings": sides[side].params}
			block_settings_menu.update_side_settings(updated_side)
		var settings = block_settings.get_settings()
		if !settings.is_empty():
			block_settings_menu.update_settings(settings)
		block_settings_menu.update_settings_menu()
		update_display()


func update_display():
	var panel_size = Vector2(290, block_type_setting_button.get_parent().position.y + block_type_setting_button.get_parent().size.y + 20)
	block_sides_seperator.visible = false
	block_settings_seperator.visible = false
	sides_settings.visible = false
	block_settings_menu.visible = false
	update_buttons()
	block_sides_seperator.size.x = panel_size.x - 40
	block_sides_seperator.position.y = panel_size.y - 10
	block_sides_seperator.visible = true
	block_settings_seperator.visible = true
	block_settings_menu.change_container_size(Vector2(488.0, 298.0))
	block_settings_menu.visible = true
	if block_settings.block_type != ConfigurableBlockSettings.CHANGE and block_settings.block_type != ConfigurableBlockSettings.EGG:
		sides_settings.visible = true
	panel_size.x += (block_settings_menu.position.x + block_settings_menu.size.x + 20) - panel_size.x
	panel_size.y += (block_settings_menu.position.y + block_settings_menu.size.y + 20) - panel_size.y
	block_settings_panel.size = panel_size


static func get_side_setting_category(matter_type: String) -> String:
	var side_setting_category: String
	if matter_type in settings_presets.matter_types:
		side_setting_category = settings_presets.matter_types[matter_type].side_setting_category
	else:
		side_setting_category = settings_presets[settings_presets.matter_types[settings_presets.matter_types.keys()[0]].side_setting_category]
	return side_setting_category


static func get_side_setting_key(matter_type: String, block_type: String, side_setting: String) -> String:
	var current_matter_type: String
	var matter_type_keys = settings_presets.matter_types.keys()
	var matter_type_list = []
	for matter_type_string in matter_type_keys:
		matter_type_list.append(settings_presets.matter_types[matter_type_string].setting)
	var matter_type_index = matter_type_list.find(matter_type)
	if matter_type_index > -1:
		current_matter_type = matter_type_keys[matter_type_index]
	else:
		current_matter_type = matter_type_keys[0]
	var current_block_type: String
	var block_type_side_category: String
	var block_type_keys = settings_presets.matter_types[current_matter_type].block_types.keys()
	var block_type_list = []
	for block_type_string in block_type_keys:
		block_type_list.append(settings_presets.matter_types[current_matter_type].block_types[block_type_string].setting)
	var block_type_index = block_type_list.find(block_type)
	if block_type_index > -1:
		current_block_type = block_type_keys[block_type_index]
	else:
		current_block_type = block_type_keys[0]
	block_type_side_category = settings_presets.matter_types[current_matter_type].block_types[current_block_type].side_category
	var side_setting_key: String
	var side_category_keys = settings_presets.matter_types[current_matter_type].side_categories[block_type_side_category].keys()
	var side_category_list = []
	for side_category_string in side_category_keys:
		side_category_list.append(settings_presets.matter_types[current_matter_type].side_categories[block_type_side_category][side_category_string].setting)
	var side_category_index = side_category_list.find(side_setting)
	if side_category_index > -1:
		side_setting_key = side_category_keys[side_category_index]
	else:
		side_setting_key = side_category_keys[0]
	return side_setting_key


func update_buttons():
	if block_settings.matter_type not in settings_presets.matter_types:
		block_settings.matter_type = settings_presets.matter_types[settings_presets.matter_types.keys()[0]].setting
	var matter_type = settings_presets.matter_types.get(block_settings.matter_type, settings_presets.matter_types[settings_presets.matter_types.keys()[0]])
	if block_settings.block_type not in matter_type.block_types:
		block_settings.block_type = matter_type.block_types[matter_type.block_types.keys()[0]].setting
	var block_type = matter_type.block_types.get(block_settings.block_type, matter_type.block_types[matter_type.block_types.keys()[0]])
	matter_type_setting_button.text = matter_type.label
	matter_type_setting_button.pressed.connect(_show_matter_types.bind(matter_type_setting_button))
	block_type_setting_button.text = block_type.label
	block_type_setting_button.pressed.connect(_show_block_types.bind(block_type_setting_button))
	block_settings_menu.update_settings_menu()
	var current_sides = block_settings_menu.side_settings_menu.sides_dictionary[matter_type.side_setting_category]
	var current_sides_keys = current_sides.keys()
	for child in sides_settings.get_children():
		child.queue_free()
	for side in current_sides.size():
		var side_category = block_type.side_category
		var current_side_category = matter_type.side_categories.get(side_category, matter_type.side_categories[matter_type.side_categories.keys()[0]])
		var side_setting_key = get_side_setting_key(block_settings.matter_type, block_settings.block_type, current_sides[current_sides_keys[side]].setting)
		if side_setting_key not in current_side_category:
			side_setting_key = current_side_category.keys()[0]
			current_sides[current_sides_keys[side]].setting = current_side_category[side_setting_key].setting
		var side_instance = block_settings.get(current_sides_keys[side])
		if side_instance != null:
			var side_type = ""
			var side_params = {}
			var side_info = side_instance.get_type().duplicate(true)
			if side_info.type == current_side_category[side_setting_key].setting:
				side_type = side_info.type
				side_params = side_info.params
			else:
				side_type = current_side_category[side_setting_key].setting
				var sides_property = block_settings_menu.side_settings_menu.side_settings_list.sides_properties.get(current_side_category[side_setting_key].setting, {})
				if sides_property.has("side_settings"):
					side_params = sides_property.side_settings
			var updated_side =  {"category": matter_type.side_setting_category, "side": current_sides_keys[side], "setting": side_type, "side_settings": side_params}
			block_settings_menu.update_side_settings(updated_side)
		var side_control = Control.new()
		side_control.size = Vector2(250.0, 30.0)
		side_control.position = Vector2(0, 40 * side)
		var side_label = RichTextLabel.new()
		side_label.size = Vector2(120.0, 30.0)
		side_label.set("theme_override_font_sizes/normal_font_size", 20)
		side_label.text = current_sides[current_sides_keys[side]].label + ":"
		side_label.horizontal_alignment = 2
		side_label.vertical_alignment = 1
		var side_button = Button.new()
		side_button.size = Vector2(120.0, 30.0)
		side_button.set("theme_override_font_sizes/font_size", 17)
		side_button.text = current_side_category[get_side_setting_key(matter_type.setting, block_type.setting, current_sides[current_sides_keys[side]].setting)].label
		side_button.alignment = 0
		side_button.clip_text = true
		side_button.position = Vector2(130.0, 0.0)
		side_control.add_child(side_label)
		side_control.add_child(side_button)
		sides_settings.add_child(side_control)
		side_button.pressed.connect(_show_sides_types.bind(current_sides_keys[side], side_button))
		sides_settings.size = Vector2(250, side_control.position.y + side_control.size.y)
		block_settings_seperator.size.y = 130.0 + (side_control.position.y + side_control.size.y)
