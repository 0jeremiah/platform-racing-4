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
	"teleport_throttle_ms": 1000.0
}

# only updated once when block settings are imported, so it can determined whenever it's settings has
# been edited through the block cursor in the editor or something like that via get_edited_settings()
var block_properties: Dictionary = {}
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


func export_settings() -> Dictionary:
	var settings = {
		"matter_type": matter_type,
		"block_type": block_type
	}
	
	if matter_type == SOLID:
		settings["top"] = top.get_type()
		settings["bottom"] = bottom.get_type()
		settings["left"] = left.get_type()
		settings["right"] = right.get_type()
		settings["bump"] = bump.get_type()
		settings["stand"] = stand.get_type()
		settings["any_side"] = any_side.get_type()
	elif matter_type == LIQUID or matter_type == GAS:
		settings["area"] = area.get_type()
	var extra_settings = get_settings()
	if !extra_settings.is_empty():
		settings.merge(extra_settings)
	# this was in pr3 to keep block settings from getting too big
	# dunno if this limitation will be needed, but added this code just in case
	
	#var encoded_settings = JSON.stringify(settings)
	#if encoded_settings.length() > 2000:
		#PopupManager.add_message_popup("Sorry, but the settings for this block are too large! It will not fit in the database :(.\nPlease lessen or remove any settings or side settings you think might be the offender(s) and try again.")
		#return {}
		
	return settings


func import_settings(new_settings: Dictionary) -> void:
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
		
		if new_settings.has("health"):
			health = new_settings.health
		if new_settings.has("stat_supply"):
			stat_supply = new_settings.stat_supply
		if new_settings.has("item_supply"):
			item_supply = new_settings.item_supply
		if new_settings.has("coin_value"):
			coin_value = new_settings.coin_value
		if new_settings.has("change_tick"):
			change_tick = new_settings.change_tick
		if new_settings.has("change_pattern"):
			change_pattern = new_settings.change_pattern
		if new_settings.has("move_tick"):
			move_tick = new_settings.move_tick
		if new_settings.has("move_pattern"):
			move_pattern = new_settings.move_pattern
		if new_settings.has("infinite_items"):
			infinite_items = new_settings.infinite_items
		if new_settings.has("item_supply"):
			item_supply = new_settings.item_supply
		if new_settings.has("infinite_stats"):
			infinite_stats = new_settings.infinite_stats
		if new_settings.has("stat_supply"):
			stat_supply = new_settings.stat_supply
		if new_settings.has("gear_rotation"):
			gear_rotation = new_settings.gear_rotation
		if new_settings.has("gear_tick"):
			gear_tick = new_settings.gear_tick
		if new_settings.has("gear_tock"):
			gear_tock = new_settings.gear_tock
		if new_settings.has("teleport_color"):
			teleport_color = new_settings.teleport_color
		if new_settings.has("teleport_throttle_ms"):
			teleport_throttle_ms = new_settings.teleport_throttle_ms
		
		var extra_settings = get_settings()
		if !extra_settings.is_empty():
			block_properties = extra_settings
	else:
		var missing_variables_string = ""
		for missing_variable in missing_variables:
			missing_variables_string = missing_variable + " ,"
		missing_variables_string.substr(0, missing_variables_string.length() - 2)
		push_warning("These variables for this block are missing: " + missing_variables_string + ".")


func get_settings() -> Dictionary:
	var settings = {}
	if health != default_block_properties.health:
		settings["health"] = health
	if coin_value != default_block_properties.coin_value:
		settings["coin_value"] = coin_value
	if stat_supply != default_block_properties.stat_supply:
		settings["stat_supply"] = stat_supply
	if change_tick != default_block_properties.change_tick:
		settings["change_tick"] = change_tick
	if change_pattern != default_block_properties.change_pattern:
		settings["change_pattern"] = change_pattern
	if move_tick != default_block_properties.move_tick:
		settings["move_tick"] = move_tick
	if move_pattern != default_block_properties.move_pattern:
		settings["move_pattern"] = move_pattern
	if has_side_type(ConfigurableBlockSideSettings.ITEM):
		settings["infinite_items"] = infinite_items
		settings["item_supply"] = item_supply
	if stat_supply != default_block_properties.stat_supply:
		settings["stat_supply"] = stat_supply
	if infinite_stats != default_block_properties.infinite_stats:
		settings["infinite_stats"] = infinite_stats
	if gear_rotation != default_block_properties.gear_rotation:
		settings["gear_rotation"] = gear_rotation
	if gear_tick != default_block_properties.gear_tick:
		settings["gear_tick"] = gear_tick
	if gear_tock != default_block_properties.gear_tock:
		settings["gear_tock"] = gear_tock
	if teleport_color != default_block_properties.teleport_color:
		settings["teleport_color"] = teleport_color
	if teleport_throttle_ms != default_block_properties.teleport_throttle_ms:
		settings["teleport_throttle_ms"] = teleport_throttle_ms
	return settings


func get_edited_settings() -> Dictionary:
	var settings = get_settings()
	var edited_settings = {}
	for setting in settings:
		if setting in block_properties and block_properties[setting] != settings[setting]:
			edited_settings[setting] = settings[setting]
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
