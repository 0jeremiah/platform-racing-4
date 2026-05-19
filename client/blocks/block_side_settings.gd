class_name ConfigurableBlockSideSettings
## Settings for the sides in ConfigurableBlock, contains side settings and parameters

static var ACTIVE = "active"
static var INACTIVE = "inactive"

static var APPEAR = "appear"
static var ARROW = "arrow"
static var ATTACH = "attach"
static var BOUNCE = "bounce"
static var CHANGE_SIZE = "change_size"
static var CHANGE_STATS = "change_stats"
static var CUSTOM_STATS = "custom_stats"
static var CRUMBLE = "crumble"
static var FINISH = "finish"
static var HEART = "heart"
static var HURT = "hurt"
static var ICE = "ice"
static var ITEM = "item"
static var MINE = "mine"
static var PRESENCE_SWITCH = "presence_switch"
static var PUSH = "push"
static var ROTATE = "rotate"
static var TIME = "time"
static var SAFETY = "safety"
static var SHATTER = "shatter"
static var SNIPER = "sniper"
static var STICKY = "sticky"
static var TELEPORT = "teleport"
static var VANISH = "vanish"

static var WATER = "water"

static var START_POSITION = "start_position"
static var SUN = "sun"
static var MOON = "moon"
static var FIREFLY = "firefly"

var params: Dictionary = {}
var type = ACTIVE


func get_type() -> Dictionary:
	return {"type": type, "params": params}


func set_type(side_dictionary: Dictionary) -> void:
	if side_dictionary.has("type"):
		type = side_dictionary.type
		if side_dictionary.has("params"):
			params = side_dictionary.params
	else:
		push_warning("side_dictionary is either blank or doesn't have 'type' in it.")
