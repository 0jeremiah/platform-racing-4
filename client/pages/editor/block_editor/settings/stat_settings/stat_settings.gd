extends BlockSetting

signal stat_settings_changed

@onready var infinite_check_box = $InfiniteCheckBox
@onready var stat_supply_box = $StatSupplyBox

var infinite: bool = false
var stat_supply: int = 1


func _ready() -> void:
	infinite_check_box.pressed.connect(_toggle_infinite)
	stat_supply_box.init("int", "1", 0, 9999999)
	stat_supply_box.return_line.connect(_change_item_supply)
	connect_node(self, "stat_settings_changed")


func _toggle_infinite():
	infinite = infinite_check_box.button_pressed
	emit_signal("stat_settings_changed", {"infinite": infinite, "stat_supply": stat_supply})


func _change_item_supply(new_stat_supply: int):
	stat_supply = new_stat_supply
	emit_signal("stat_settings_changed", {"infinite": infinite, "stat_supply": stat_supply})


func set_settings(new_settings: Dictionary):
	if new_settings.has("infinite"):
		infinite = new_settings.infinite
	if new_settings.has("stat_supply"):
		stat_supply = clamp(new_settings.stat_supply, 0, 9999999)
		stat_supply_box._update_text(str(stat_supply))
