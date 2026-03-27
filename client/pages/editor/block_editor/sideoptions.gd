extends Control

@onready var item_options = $ItemOptions
@onready var custom_stats_options = $CustomStatsOptions
@onready var stat_options = $StatOptions

var has_item_options: bool = false
var has_custom_stats_options: bool = false
var has_stat_options: bool = false
var item_settings: Array = []
var custom_stats_settings: Array = [50, 50, 50, 50]
var stat_increment: int = 5
var sides_properties: Dictionary = {
	"appear": {"animation_duration": 0.3, "cooldown": 2.0},
	"arrow": {"force": 110.0, "direction": Vector2(0.0, -1.0)},
	"bounce": {"bounciness": 0.1, "speed_limit": 12500.0},
	"crumble": {"health": 100, "armor": 10, "damage_ratio": 0.03},
	"custom_stats": {"reset": false, "speed": 50, "accel": 50, "jump": 50, "skill": 50},
	"enlarge": {"exact": false, "multiplier": 0.5},
	"mine": {"push_strength": 1000.0, "hitstun_duration": 2.5},
	"gear": {"rotation": 90.0, "tick": 4000.0, "tock": 500.0},
	"happy": {"amount": 5},
	"heart": {"hp": 1.0, "exact": false, "invincibility": false},
	"hurt": {"push_strength": 1000.0, "hitstun_duration": 2.5},
	"give_item": {"item_supply": 1, "infinite": false, "item_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]},
	"sad": {"amount": 5},
	"shrink": {"exact": false, "multiplier": 0.5},
	"vanish": {"animation_duration": 0.3, "cooldown": 2.0}
}


func _ready() -> void:
	item_options.item_options_changed.connect(_update_item_list)


func _update_item_list(new_item_options: Dictionary):
	item_settings = new_item_options.item_settings
