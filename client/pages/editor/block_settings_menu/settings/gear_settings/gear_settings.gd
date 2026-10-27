extends BlockSetting

signal gear_settings_changed

@onready var gear_rotation_box = $GearRotationBox
@onready var gear_tick_seconds_box = $GearTickSecondsBox
@onready var gear_tock_seconds_box = $GearTockSecondsBox
@onready var gear_inertia_box = $GearInertiaBox
@onready var gear_auto_rotation_check_box = $GearAutoRotationCheckBox

var gear_rotation: float = ConfigurableBlockSettings.default_block_properties.gear_rotation
var gear_tick_seconds: float = ConfigurableBlockSettings.default_block_properties.gear_tick_seconds
var gear_tock_seconds: float = ConfigurableBlockSettings.default_block_properties.gear_tock_seconds
var gear_inertia: float = ConfigurableBlockSettings.default_block_properties.gear_inertia
var gear_auto_rotation: bool = ConfigurableBlockSettings.default_block_properties.gear_auto_rotation


func _ready() -> void:
	gear_rotation_box.init("float", str(gear_rotation), -360.0, 360.0)
	gear_rotation_box.return_line.connect(_change_gear_rotation)
	gear_tick_seconds_box.init("float", str(gear_tick_seconds), 0.0, 99999999.9)
	gear_tick_seconds_box.return_line.connect(_change_gear_tick_seconds)
	gear_tock_seconds_box.init("float", str(gear_tock_seconds), 0.0, 99999999.9)
	gear_tock_seconds_box.return_line.connect(_change_gear_tock_seconds)
	gear_inertia_box.init("float", str(gear_inertia), 0.0, 99999999.9)
	gear_inertia_box.return_line.connect(_change_gear_inertia)
	gear_auto_rotation_check_box.pressed.connect(_toggle_gear_auto_rotation)
	connect_node(self, "gear_settings_changed")


func send_signal():
	emit_signal("gear_settings_changed", {"gear_rotation": gear_rotation, "gear_tick_seconds": gear_tick_seconds, "gear_tock_seconds": gear_tock_seconds, "gear_inertia": gear_inertia, "gear_auto_rotation": gear_auto_rotation})


func _change_gear_rotation(new_gear_rotation: float):
	gear_rotation = new_gear_rotation
	send_signal()


func _change_gear_tick_seconds(new_gear_tick_seconds: float):
	gear_tick_seconds = new_gear_tick_seconds
	send_signal()


func _change_gear_tock_seconds(new_gear_tock_seconds: float):
	gear_tock_seconds = new_gear_tock_seconds
	send_signal()


func _change_gear_inertia(new_gear_inertia: float):
	gear_inertia = new_gear_inertia
	send_signal()


func _toggle_gear_auto_rotation():
	gear_auto_rotation = gear_auto_rotation_check_box.button_pressed
	send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("gear_rotation"):
		gear_rotation = clamp(new_settings.gear_rotation, -360.0, 360.0)
		gear_rotation_box._update_text(str(gear_rotation))
	if new_settings.has("gear_tick_seconds"):
		gear_tick_seconds = clamp(new_settings.gear_tick_seconds, 0.0, 99999999.9)
		gear_tick_seconds_box._update_text(str(gear_tick_seconds))
	if new_settings.has("gear_tock_seconds"):
		gear_tock_seconds = clamp(new_settings.gear_tock_seconds, 0.0, 99999999.9)
		gear_tock_seconds_box._update_text(str(gear_tock_seconds))
	if new_settings.has("gear_inertia"):
		gear_inertia = clamp(new_settings.gear_inertia, 0.0, 99999999.9)
		gear_inertia_box._update_text(str(gear_inertia))
	if new_settings.has("gear_auto_rotation"):
		gear_auto_rotation = new_settings.gear_auto_rotation
		gear_auto_rotation_check_box.set_pressed_no_signal(gear_auto_rotation)
