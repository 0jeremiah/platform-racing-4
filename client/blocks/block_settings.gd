class_name ConfigurableBlockSettings
## Settings for ConfigurableBlock, contains main settings and properties

static var SOLID := "solid"
static var LIQUID := "liquid"
static var GAS := "gas"

static var ACTIVE := "active"
static var IMPERVIOUS := "impervious"
static var MOVE := "move"
static var CHANGE := "change"
static var GEAR := "gear"
static var EGG := "egg"

static var WATER := "water"

static var INACTIVE := "inactive"
static var START_POSITION := "start_position"
static var PRESENCE_SWITCH := "presence_switch"
static var LIGHTBREAKER := "lightbreaker"

# default block settings that can be accessed through ConfigurableBlockSettings
static var default_block_properties: Dictionary = {
	"health": 100.0,
	"coin_value": 3,
	"change_tick": 2.5,
	"change_pattern": ["101", "121", "124", "113"],
	"move_tick": 2.5,
	"move_pattern": "up, down, left, right",
	"randomize_move_pattern": false,
	"loop_move_pattern": true,
	"infinite_items": false,
	"item_supply": 1,
	"infinite_stats": false,
	"stat_supply": 1,
	"gear_rotation": 90.0,
	"gear_tick": 4000.0,
	"gear_tock": 500.0,
	"teleport_color": "FF7F50",
	"teleport_throttle_ms": 1000.0,
	"infinite_time": false,
	"time_supply": 1,
	"light_color": "FFFFFF"
}

var block_properties: Dictionary = {} # only updated once when block settings are imported, so it can be determined
# whenever it's settings has been edited through the block cursor in the editor or something like that via
# get_edited_settings()
var title: String = "block"
var comment: String = ""
var matter_type := SOLID
var block_type := ACTIVE
var top: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var bottom: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var left: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var right: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var bump: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var stand: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var any_side: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var area: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var health = default_block_properties.health
var coin_value = default_block_properties.coin_value
var change_tick = default_block_properties.change_tick
var change_pattern = default_block_properties.change_pattern
var move_tick = default_block_properties.move_tick
var move_pattern = default_block_properties.move_pattern
var randomize_move_pattern = default_block_properties.randomize_move_pattern
var loop_move_pattern = default_block_properties.loop_move_pattern
var infinite_items = default_block_properties.infinite_items
var item_supply = default_block_properties.item_supply
var infinite_stats = default_block_properties.infinite_stats
var stat_supply = default_block_properties.stat_supply
var gear_rotation = default_block_properties.gear_rotation
var gear_tick = default_block_properties.gear_tick
var gear_tock = default_block_properties.gear_tock
var teleport_color: String = default_block_properties.teleport_color
var teleport_throttle_ms: float = default_block_properties.teleport_throttle_ms
var infinite_time = default_block_properties.infinite_time
var time_supply = default_block_properties.time_supply
var light_color: String = default_block_properties.light_color
var can_give_items: bool = item_supply > 0
var can_give_stats: bool = stat_supply > 0
var can_finish: bool = true
var can_give_time: bool = time_supply > 0


func export_settings() -> Dictionary:
	var settings = {
		"matter_type": matter_type,
		"block_type": block_type
	}
	
	#if matter_type == SOLID:
		#settings["top"] = top.get_type()
		#settings["bottom"] = bottom.get_type()
		#settings["left"] = left.get_type()
		#settings["right"] = right.get_type()
		#settings["bump"] = bump.get_type()
		#settings["stand"] = stand.get_type()
		#settings["any_side"] = any_side.get_type()
	#elif matter_type == LIQUID or matter_type == GAS:
		#settings["area"] = area.get_type()
	var sides = get_sides()
	for side in sides:
		settings[side] = sides[side].get_type()
	for maybe_setting in default_block_properties:
		if maybe_setting in self and get(maybe_setting) != default_block_properties[maybe_setting]:
			settings[maybe_setting] = get(maybe_setting)
	if block_type != ConfigurableBlockSettings.CHANGE:
		settings.erase("change_tick")
		settings.erase("change_pattern")
	if block_type != ConfigurableBlockSettings.MOVE:
		settings.erase("move_tick")
		settings.erase("move_pattern")
		settings.erase("randomize_move_pattern")
		settings.erase("loop_move_pattern")
	if !has_side_type(ConfigurableBlockSideSettings.ITEM):
		settings.erase("infinite_items")
		settings.erase("item_supply")
	if !has_side_type(ConfigurableBlockSideSettings.CHANGE_STATS):
		settings.erase("infinite_stats")
		settings.erase("stat_supply")
	if block_type != ConfigurableBlockSettings.GEAR:
		settings.erase("gear_rotation")
		settings.erase("gear_tick")
		settings.erase("gear_tock")
	if !has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		settings.erase("teleport_color")
		settings.erase("teleport_throttle_ms")
	if !has_side_type(ConfigurableBlockSideSettings.TIME):
		settings.erase("infinite_time")
		settings.erase("time_supply")
	if block_type != ConfigurableBlockSettings.LIGHTBREAKER:
		settings.erase("light_color")
	# this was in pr3 to keep block settings from getting too big
	# dunno if this limitation will be needed, but added this code just in case
	
	#var encoded_settings = JSON.stringify(settings)
	#if encoded_settings.length() > 2000:
		#PopupManager.add_message_popup("Sorry, but the settings for this block are too large! It will not fit in the database :(.\nPlease lessen or remove any settings or side settings you think might be the offender(s) and try again.", Main.instance.current_scene)
		#return {}
		
	return settings


func reset_settings():
	block_properties = {}
	for maybe_setting in default_block_properties:
		if maybe_setting in self:
			set(maybe_setting, default_block_properties[maybe_setting])
	can_give_items = item_supply > 0
	can_give_stats = stat_supply > 0
	can_finish = true
	can_give_time = time_supply > 0


func import_settings(new_settings: Dictionary) -> void:
	reset_settings()
	if new_settings.has("title"):
		title = new_settings.title
	if new_settings.has("comment"):
		comment = new_settings.comment
	var needed_variables = ["matter_type", "block_type"]
	if new_settings.has("matter_type") and new_settings.matter_type == SOLID:
		needed_variables.append_array(["top", "bottom", "left", "right", "bump", "stand", "any_side"])
	elif new_settings.has("matter_type") and (new_settings.matter_type == LIQUID or new_settings.matter_type == GAS):
		needed_variables.append_array(["area"])
	var missing_variables = []
	for needed_variable in needed_variables:
		if !new_settings.has(needed_variable):
			missing_variables.append(needed_variable)
	if missing_variables.is_empty():
		matter_type = new_settings.matter_type
		block_type = new_settings.block_type
		if new_settings.matter_type == SOLID:
			top.set_type(new_settings.top)
			bottom.set_type(new_settings.bottom)
			left.set_type(new_settings.left)
			right.set_type(new_settings.right)
			bump.set_type(new_settings.bump)
			stand.set_type(new_settings.stand)
			any_side.set_type(new_settings.any_side)
		if new_settings.matter_type == LIQUID or new_settings.matter_type == GAS:
			area.set_type(new_settings.area)
		var sides = get_sides()
		for side in sides:
			block_properties[side] = sides[side].get_type()

		for maybe_setting in default_block_properties:
			if maybe_setting in self and maybe_setting in new_settings:
				set(maybe_setting, new_settings[maybe_setting])
				block_properties[maybe_setting] = new_settings[maybe_setting]

		can_give_items = item_supply > 0
		can_give_stats = stat_supply > 0
		can_finish = true
		can_give_time = time_supply > 0
	else:
		var missing_variables_string = ""
		for missing_variable in missing_variables:
			missing_variables_string = missing_variable + " ,"
		missing_variables_string.substr(0, missing_variables_string.length() - 2)
		push_warning("These variables for this block are missing: " + missing_variables_string + ".")


func import_edited_settings(edited_settings: Dictionary):
	var sides = get_sides()
	for side in sides:
		if side in self and side in edited_settings:
			get(side).set_type(edited_settings[side])
	for maybe_setting in default_block_properties:
		if maybe_setting in self and maybe_setting in edited_settings:
			set(maybe_setting, edited_settings[maybe_setting])
	can_give_items = item_supply > 0
	can_give_stats = stat_supply > 0
	can_finish = true
	can_give_time = time_supply > 0


func get_settings() -> Dictionary:
	var settings = {}
	settings["title"] = title
	settings["comment"] = comment
	settings["matter_type"] = matter_type
	settings["block_type"] = block_type
	var sides = get_sides()
	for side in sides:
		if side in block_properties:
			settings[side] = block_properties[side]
	for maybe_setting in default_block_properties:
		if maybe_setting in block_properties:
			settings[maybe_setting] = block_properties[maybe_setting]
	if !has_side_type(ConfigurableBlockSideSettings.ITEM):
		settings.erase("infinite_items")
		settings.erase("item_supply")
	return settings


func get_edited_settings() -> Dictionary:
	var edited_settings = {}
	var sides = get_sides()
	for side in sides:
		if side in self and side in block_properties and sides[side].get_type() != block_properties[side]:
			edited_settings[side] = sides[side].get_type()
	for setting in default_block_properties:
		if setting in self and setting in block_properties and get(setting) != block_properties[setting]:
			edited_settings[setting] = get(setting)
	return edited_settings


func get_side_types() -> Array:
	if matter_type == SOLID:
		return [top.type, bottom.type, left.type, right.type, bump.type, stand.type, any_side.type]
	elif matter_type == LIQUID or matter_type == GAS:
		return [area.type]
	return []


func has_side_type(_side_type: String) -> bool:
	if get_side_types().has(_side_type):
		return true
	return false


func get_sides() -> Dictionary:
	if matter_type == SOLID:
		return {
			"top": top,
			"bottom": bottom,
			"left": left,
			"right": right,
			"bump": bump,
			"stand": stand,
			"any_side": any_side
		}
	elif matter_type == LIQUID or matter_type == GAS:
		return {
			"area": area
		}
	return {}
