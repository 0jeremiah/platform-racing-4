class_name ConfigurableBlockSettings
## Settings for ConfigurableBlock, contains main settings and properties

const SOLID := "solid"
const LIQUID := "liquid"
const GAS := "gas"

const ACTIVE := "active"
const IMPERVIOUS := "impervious"
const MOVE := "move"
const CHANGE := "change"
const EGG := "egg"

var _config: Dictionary
var _behaviors: Dictionary
var matter_type := SOLID
var block_type := ACTIVE

var can_change: bool = false
var change_pattern: Array = []
var can_move: bool = false
var move_tick: float = 2.5
var can_give_items: bool = false
var item_array = Items.default_items
var can_finish: bool = false


func init(config: Dictionary) -> void:
	print("Block::init ", config)
	_config = config
	_behaviors = _config.get("behaviors", {})
	matter_type = _config.get("matter_type", ConfigurableBlockSettings.SOLID)
