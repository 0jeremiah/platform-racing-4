extends BlockSetting

signal stat_settings_changed

@onready var infinite_stats_check_box = $InfiniteStatsCheckBox
@onready var stat_supply_box = $StatSupplyBox

var infinite_stats: bool = ConfigurableBlockSettings.default_block_properties.infinite_stats
var stat_supply: int = ConfigurableBlockSettings.default_block_properties.stat_supply


func _ready() -> void:
	infinite_stats_check_box.pressed.connect(_toggle_infinite_stats)
	stat_supply_box.init("int", str(stat_supply), 0, 9999999)
	stat_supply_box.return_line.connect(_change_item_supply)
	connect_node(self, "stat_settings_changed")


func _toggle_infinite_stats():
	infinite_stats = infinite_stats_check_box.button_pressed
	emit_signal("stat_settings_changed", {"infinite_stats": infinite_stats, "stat_supply": stat_supply})


func _change_item_supply(new_stat_supply: int):
	stat_supply = new_stat_supply
	emit_signal("stat_settings_changed", {"infinite_stats": infinite_stats, "stat_supply": stat_supply})


func set_settings(new_settings: Dictionary):
	if new_settings.has("infinite_stats"):
		infinite_stats = new_settings.infinite_stats
		infinite_stats_check_box.set_pressed_no_signal(infinite_stats)
	if new_settings.has("stat_supply"):
		stat_supply = clamp(new_settings.stat_supply, 0, 9999999)
		stat_supply_box._update_text(str(stat_supply))
