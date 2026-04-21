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
static var SUN := "sun"
static var MOON := "moon"
static var FIREFLY := "firefly"

var _config: Dictionary
var _behaviors: Dictionary
var matter_type := SOLID
var block_type := ACTIVE
var can_change: bool = false
var change_pattern: Array = []
var can_move: bool = false
var move_tick: float = 2.5
var move_string: String = ""
var can_give_items: bool = false
var infinite_items: bool = false
var item_supply: int = 1
var item_array = Items.default_items
#var can_finish: bool = false
var can_give_stats: bool = false
var stat_supply: int = 1
var can_rotate: bool = false
var gear_degrees: float = 90.0
var gear_tick: float = 4000.0
var gear_tock: float = 500.0
var default_change_pattern: Array = [101, 121, 124, 113]
var default_move_string: String = "up, down, left, right"
var health: float = 100.0
var coin_value: int = 3
var top: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var bottom: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var left: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var right: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var bump: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var stand: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var any_side: ConfigurableBlockSideSettings = ConfigurableBlockSideSettings.new()
var title: String = "first"
var comment: String = ""


func init(config: Dictionary) -> void:
	print("Block::init ", config)
	_config = config
	_behaviors = _config.get("behaviors", {})
	matter_type = _config.get("matter_type", ConfigurableBlockSettings.SOLID)
