class_name ConfigurableBlockSideSettings

static var ACTIVE = "active"
static var INACTIVE = "inactive"
static var APPEAR = "appear"
static var ATTACH = "attach"
static var PUSH = "push"
static var BOUNCE = "bounce"
static var CRUMBLE = "crumble"
static var SAD = "sad"
static var ENLARGE = "enlarge"
static var MINE = "mine"
static var FINISH = "finish"
static var HEART = "heart"
static var ITEM = "item"
static var CUSTOM_STATS = "custom_stats"
static var TIME = "time"
static var HURT = "hurt"
static var ICE = "ice"
static var HAPPY = "happy"
static var ARROW_DOWN = "arrow_down"
static var ARROW_LEFT = "arrow_left"
static var ARROW_RIGHT = "arrow_right"
static var ARROW_UP = "arrow_up"
static var ROTATE_LEFT = "rotate_left"
static var ROTATE_RIGHT = "rotate_right"
static var SAFETY = "safety"
static var SHATTER = "shatter"
static var SHRINK = "shrink"
static var SNIPER = "sniper"
static var STICKY = "sticky"
static var TELEPORT = "teleport"
static var VANISH = "vanish"

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
		push_error("side_dictionary is either blank or doesn't have 'type' in it.")
