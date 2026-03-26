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


func _ready() -> void:
	item_options.item_list_updated.connect(_update_item_list)


func _update_item_list(new_item_settins: Array):
	item_settings = new_item_settins
