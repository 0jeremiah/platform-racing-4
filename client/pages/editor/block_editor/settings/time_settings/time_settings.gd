extends BlockSetting

signal time_settings_changed

@onready var infinite_time_check_box = $InfiniteTimeCheckBox
@onready var time_supply_box = $TimeSupplyBox

var infinite_time: bool = ConfigurableBlockSettings.default_block_properties.infinite_time
var time_supply: float = ConfigurableBlockSettings.default_block_properties.time_supply


func _ready() -> void:
	infinite_time_check_box.pressed.connect(_toggle_infinite_time)
	time_supply_box.init("int", str(time_supply), 0.0, 99999999.9)
	time_supply_box.return_line.connect(_change_time_supply)
	connect_node(self, "time_settings_changed")


func _toggle_infinite_time():
	infinite_time = infinite_time_check_box.button_pressed
	emit_signal("time_settings_changed", {"infinite_time": infinite_time, "time_supply": time_supply})


func _change_time_supply(new_time_supply: int):
	time_supply = new_time_supply
	emit_signal("time_settings_changed", {"infinite_time": infinite_time, "time_supply": time_supply})


func set_settings(new_settings: Dictionary):
	if new_settings.has("infinite_time"):
		infinite_time = new_settings.infinite_time
		infinite_time_check_box.set_pressed_no_signal(infinite_time)
	if new_settings.has("time_supply"):
		time_supply = clamp(new_settings.time_supply, 0.0, 99999999.9)
		time_supply_box._update_text(str(time_supply))
