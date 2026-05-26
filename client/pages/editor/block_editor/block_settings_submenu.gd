extends Control

signal control_event

@onready var block_settings_panel = $BlockSettingsPanel
@onready var block_sides_seperator = $BlockSidesSeperator
@onready var sides_settings_seperator = $SidesSettingsSeperator
@onready var settings_seperator = $SettingsSeperator
@onready var block_options_seperator = $BlockOptionsSeperator
@onready var matter_type_setting_button = $MatterTypeSetting/MatterTypeSettingButton
@onready var block_type_setting_button = $BlockTypeSetting/BlockTypeSettingButton
@onready var sides_settings = $SidesSettings
@onready var side_settings_menu = $SideSettingsMenu
@onready var settings_menu = $SettingsMenu
@onready var move_settings = $MoveSettings
@onready var change_settings = $ChangeSettings
@onready var dropdown_popup = $DropdownPopup

static var block_settings: ConfigurableBlockSettings = ConfigurableBlockSettings.new()

# all available options the block settings submenu can see
# can add new options and it will be added automatically
var settings_presets: Dictionary = {
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
					"give_time": {"label": "Give Time", "setting": ConfigurableBlockSideSettings.TIME},
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
				"presence_switch": {"label": "Presence Switch", "setting": ConfigurableBlockSettings.PRESENCE_SWITCH, "side_category": "presence_switch"},
				"lightbreaker": {"label": "Lightbreaker", "setting": ConfigurableBlockSettings.LIGHTBREAKER, "side_category": "lightbreakers"},
			},
			"side_categories": {
				"inactive": {
					"inactive": {"label": "Inactive", "setting": ConfigurableBlockSideSettings.INACTIVE}
				},
				"start_position": {
					"start_position": {"label": "Start Position", "setting": ConfigurableBlockSideSettings.START_POSITION}
				},
				"presence_switch": {
					"presence_switch": {"label": "Presence Switch", "setting": ConfigurableBlockSideSettings.PRESENCE_SWITCH}
				},
				"lightbreakers": {
					"sun": {"label": "Sun", "setting": ConfigurableBlockSideSettings.SUN},
					"moon": {"label": "Moon", "setting": ConfigurableBlockSideSettings.MOON},
					"firefly": {"label": "Firefly", "setting": ConfigurableBlockSideSettings.FIREFLY}
				}
			}
		}
	}
}

# needed for the side setting buttons when loading settings
var settings_lookup: Dictionary = {
	"matter_types": {
		ConfigurableBlockSettings.SOLID: {"key": "solid", "next_category": "solid_block_types"},
		ConfigurableBlockSettings.LIQUID: {"key": "liquid", "next_category": "liquid_block_types"},
		ConfigurableBlockSettings.GAS: {"key": "gas", "next_category": "gas_block_types"}
		},
	"solid_block_types": {
		ConfigurableBlockSettings.ACTIVE: {"key": "active", "next_category": "solid_side_types"},
		ConfigurableBlockSettings.IMPERVIOUS: {"key": "impervious", "next_category": "solid_side_types"},
		ConfigurableBlockSettings.MOVE: {"key": "move", "next_category": "solid_side_types"},
		ConfigurableBlockSettings.CHANGE: {"key": "change", "next_category": "solid_side_types"},
		ConfigurableBlockSettings.GEAR: {"key": "gear", "next_category": "solid_side_types"},
		ConfigurableBlockSettings.EGG: {"key": "egg", "next_category": "solid_side_types"}
		},
	"solid_side_types": {
		ConfigurableBlockSideSettings.ACTIVE: {"key": "active"},
		ConfigurableBlockSideSettings.INACTIVE: {"key": "inactive"},
		ConfigurableBlockSideSettings.APPEAR: {"key": "appear"},
		ConfigurableBlockSideSettings.ARROW: {"key": "arrow"},
		ConfigurableBlockSideSettings.ATTACH: {"key": "attach"},
		ConfigurableBlockSideSettings.BOUNCE: {"key": "bounce"},
		ConfigurableBlockSideSettings.CHANGE_SIZE: {"key": "change_size"},
		ConfigurableBlockSideSettings.CHANGE_STATS: {"key": "change_stats"},
		ConfigurableBlockSideSettings.CRUMBLE: {"key": "crumble"},
		ConfigurableBlockSideSettings.CUSTOM_STATS: {"key": "custom_stats"},
		ConfigurableBlockSideSettings.MINE: {"key": "mine"},
		ConfigurableBlockSideSettings.FINISH: {"key": "finish"},
		ConfigurableBlockSideSettings.HEART: {"key": "heart"},
		ConfigurableBlockSideSettings.ITEM: {"key": "item"},
		ConfigurableBlockSideSettings.TIME: {"key": "time"},
		ConfigurableBlockSideSettings.HURT: {"key": "hurt"},
		ConfigurableBlockSideSettings.ICE: {"key": "ice"},
		ConfigurableBlockSideSettings.PUSH: {"key": "push"},
		ConfigurableBlockSideSettings.ROTATE: {"key": "rotate"},
		ConfigurableBlockSideSettings.SAFETY: {"key": "safety"},
		ConfigurableBlockSideSettings.SHATTER: {"key": "shatter"},
		ConfigurableBlockSideSettings.SNIPER: {"key": "sniper"},
		ConfigurableBlockSideSettings.STICKY: {"key": "sticky"},
		ConfigurableBlockSideSettings.TELEPORT: {"key": "teleport"},
		ConfigurableBlockSideSettings.VANISH: {"key": "vanish"}
		},
	"liquid_block_types": {
		ConfigurableBlockSettings.WATER: {"key": "water", "next_category": "liquid_side_types"}
		},
	"liquid_side_types": {
		ConfigurableBlockSideSettings.WATER: {"key": "water"}
		},
	"gas_block_types": {
		ConfigurableBlockSettings.INACTIVE: {"key": "inactive", "next_category": "gas_side_types"},
		ConfigurableBlockSettings.START_POSITION: {"key": "start_position", "next_category": "gas_side_types"},
		ConfigurableBlockSettings.PRESENCE_SWITCH: {"key": "presence_switch", "next_category": "gas_side_types"},
		ConfigurableBlockSettings.LIGHTBREAKER: {"key": "lightbreaker", "next_category": "gas_side_types"}
		},
	"gas_side_types": {
		ConfigurableBlockSideSettings.INACTIVE: {"key": "inactive"},
		ConfigurableBlockSideSettings.START_POSITION: {"key": "start_position"},
		ConfigurableBlockSideSettings.PRESENCE_SWITCH: {"key": "presence_switch"},
		ConfigurableBlockSideSettings.SUN: {"key": "sun"},
		ConfigurableBlockSideSettings.MOON: {"key": "moon"},
		ConfigurableBlockSideSettings.FIREFLY: {"key": "firefly"}
	}
}
var active: bool = false


func _ready() -> void:
	matter_type_setting_button.pressed.connect(_show_matter_types.bind(matter_type_setting_button))
	block_type_setting_button.pressed.connect(_show_block_types.bind(block_type_setting_button))
	dropdown_popup.return_dropdown_data.connect(_change_setting.bind())
	settings_menu.init(block_settings)
	side_settings_menu.init(block_settings)
	settings_menu._maybe_enable_settings({
		"block_settings": {
			"general": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID, "setting": "general"},
			"stat": {"enabled": block_settings.has_side_type(ConfigurableBlockSideSettings.CHANGE_STATS) or block_settings.has_side_type(ConfigurableBlockSideSettings.CUSTOM_STATS), "setting": "stat"},
			ConfigurableBlockSideSettings.ITEM: {"enabled": block_settings.has_side_type(ConfigurableBlockSideSettings.ITEM), "setting": ConfigurableBlockSideSettings.ITEM},
			ConfigurableBlockSideSettings.TELEPORT: {"enabled": block_settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT), "setting": ConfigurableBlockSideSettings.TELEPORT},
			ConfigurableBlockSettings.GEAR: {"enabled": block_settings.block_type == ConfigurableBlockSettings.GEAR, "setting": ConfigurableBlockSettings.GEAR}
		}
	})
	update_display()
	


func init() -> void:
	pass


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
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	for matter_type in settings_presets.matter_types:
		dropdown_popup.add_option(settings_presets.matter_types[matter_type].label, {"category": settings_presets.matter_types[matter_type].side_setting_category, "setting": settings_presets.matter_types[matter_type].setting, "button": button})
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_block_types(button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	var matter_type = settings_presets.matter_types.get(block_settings.matter_type, settings_presets.matter_types[settings_presets.matter_types.keys()[0]])
	var side_setting_category = matter_type.side_setting_category
	var matter_type_block_types = matter_type.block_types
	for matter_type_block_type in matter_type_block_types:
		dropdown_popup.add_option(matter_type_block_types[matter_type_block_type].label, {"category": side_setting_category, "setting": matter_type_block_types[matter_type_block_type].setting, "button": button})
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _show_sides_types(side: String, button: Button):
	dropdown_popup.clear()
	dropdown_popup.set_dropdown_size(Vector2(button.size.x, 200))
	dropdown_popup.holder = button
	var matter_type = settings_presets.matter_types.get(block_settings.matter_type, settings_presets.matter_types[settings_presets.matter_types.keys()[0]])
	var side_setting_category = matter_type.side_setting_category
	var matter_type_block_types = matter_type.block_types
	var block_type = matter_type_block_types.get(block_settings.block_type, matter_type_block_types[matter_type_block_types.keys()[0]])
	var side_category = matter_type.side_categories.get(block_type.side_category, matter_type.side_categories[matter_type.side_categories.keys()[0]])
	for side_type in side_category:
		dropdown_popup.add_option(side_category[side_type].label, {"category": side_setting_category, "side": side, "setting": side_category[side_type].setting, "button": button})
	dropdown_popup.show_popup(button.global_position.x, button.global_position.y + button.size.y)


func _change_setting(selected_dictionary: Dictionary):
	if selected_dictionary.button == matter_type_setting_button:
		block_settings.matter_type = selected_dictionary.setting
	elif selected_dictionary.button == block_type_setting_button:
		block_settings.block_type = selected_dictionary.setting
	side_settings_menu._update_sides(selected_dictionary)
	settings_menu._maybe_enable_settings({
		"block_settings": {
			"general": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID, "setting": "general"},
			"stat": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and (block_settings.has_side_type(ConfigurableBlockSideSettings.CHANGE_STATS) or block_settings.has_side_type(ConfigurableBlockSideSettings.CUSTOM_STATS)), "setting": "stat"},
			ConfigurableBlockSideSettings.ITEM: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.ITEM), "setting": ConfigurableBlockSideSettings.ITEM},
			ConfigurableBlockSideSettings.TELEPORT: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT), "setting": ConfigurableBlockSideSettings.TELEPORT},
			ConfigurableBlockSettings.GEAR: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.GEAR, "setting": ConfigurableBlockSettings.GEAR}
		}
	})
	update_buttons()
	update_display()
#
#
#func _change_health(new_health: float):
	#block_properties.health = new_health
#
#
#func _update_properties(new_dictionary: Dictionary):
	#for key in new_dictionary.keys():
		#if block_properties.has(key):
			#block_properties[key] = new_dictionary[key]
#
#
func update_display():
	var panel_size = Vector2(290, block_type_setting_button.get_parent().position.y + block_type_setting_button.get_parent().size.y + 20)
	block_sides_seperator.visible = false
	sides_settings_seperator.visible = false
	settings_seperator.visible = false
	block_options_seperator.visible = false
	sides_settings.visible = false
	settings_menu.visible = false
	move_settings.visible = false
	change_settings.visible = false
	side_settings_menu.visible = false
	update_buttons()
	block_sides_seperator.size.x = panel_size.x - 40
	if block_settings.block_type != ConfigurableBlockSettings.CHANGE and block_settings.block_type != ConfigurableBlockSettings.EGG:
		block_sides_seperator.position.y = panel_size.y - 10
		block_sides_seperator.visible = true
		side_settings_menu.size.y = side_settings_menu.size.y + (sides_settings.position.y - side_settings_menu.position.y)
		side_settings_menu.change_container_y(side_settings_menu.size.y + (sides_settings.position.y - side_settings_menu.position.y))
		sides_settings.visible = true
		panel_size.y += (sides_settings.position.y + sides_settings.size.y + 20) - panel_size.y
	if block_settings.block_type != ConfigurableBlockSettings.CHANGE and settings_menu.has_settings:
		settings_seperator.position.y = panel_size.y - 10
		settings_seperator.visible = true
		settings_menu.position.y = panel_size.y
		settings_menu.visible = true
		panel_size.y += (settings_menu.position.y + settings_menu.size.y + 20) - panel_size.y
	if block_settings.block_type == ConfigurableBlockSettings.MOVE:
		block_options_seperator.position.y = panel_size.y - 10
		block_options_seperator.visible = true
		move_settings.position.y = panel_size.y
		move_settings.visible = true
		panel_size.x += (move_settings.position.x + move_settings.size.x + 20) - panel_size.x
		panel_size.y += (move_settings.position.y + move_settings.size.y + 20) - panel_size.y
	elif block_settings.block_type == ConfigurableBlockSettings.CHANGE:
		block_options_seperator.position.y = panel_size.y - 10
		block_options_seperator.visible = true
		change_settings.position.y = panel_size.y
		change_settings.visible = true
		panel_size.x += (change_settings.position.x + change_settings.size.x + 20) - panel_size.x
		panel_size.y += (change_settings.position.y + change_settings.size.y + 20) - panel_size.y
	if block_settings.block_type != ConfigurableBlockSettings.CHANGE and block_settings.block_type != ConfigurableBlockSettings.EGG and side_settings_menu.has_side_settings:
		sides_settings_seperator.visible = true
		side_settings_menu.visible = true
		panel_size.x += (side_settings_menu.position.x + side_settings_menu.size.x + 20) - panel_size.x
	if block_settings.block_type != "move" and !side_settings_menu.visible:
		block_sides_seperator.size.x = panel_size.x - 40
	block_settings_panel.size = panel_size
	settings_seperator.size.x = panel_size.x - 40
	block_options_seperator.size.x = panel_size.x - 40


func get_side_setting_key(matter_type: String, block_type: String, side_setting: String) -> String:
	var matter_type_next_category: String
	if matter_type in settings_lookup.matter_types:
		matter_type_next_category = settings_lookup.matter_types[matter_type].next_category
	else:
		matter_type_next_category = settings_lookup[settings_lookup.matter_types[settings_lookup.matter_types.keys()[0]].next_category]
	var block_type_next_category: String
	if block_type in settings_lookup[matter_type_next_category]:
		block_type_next_category = settings_lookup[matter_type_next_category][block_type].next_category
	else:
		block_type_next_category = settings_lookup[matter_type_next_category][settings_lookup[matter_type_next_category].keys()[0]].next_category
	var side_setting_key: String
	if side_setting in settings_lookup[block_type_next_category]:
		side_setting_key = settings_lookup[block_type_next_category][side_setting].key
	else:
		side_setting_key = settings_lookup[block_type_next_category][settings_lookup[block_type_next_category].keys()[0]].key
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
	var current_sides = side_settings_menu.sides_dictionary[matter_type.side_setting_category]
	var current_sides_keys = current_sides.keys()
	for child in sides_settings.get_children():
		child.queue_free()
	for side in current_sides.size():
		var side_category = block_type.side_category
		var current_side_category = matter_type.side_categories.get(side_category, matter_type.side_categories[matter_type.side_categories.keys()[0]])
		if current_sides[current_sides_keys[side]].setting not in current_side_category:
			current_sides[current_sides_keys[side]].setting = current_side_category[current_side_category.keys()[0]].setting
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
		sides_settings_seperator.size.y = 130.0 + (side_control.position.y + side_control.size.y)
