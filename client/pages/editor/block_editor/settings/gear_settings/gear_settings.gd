extends BlockSetting

signal gear_settings_changed

@onready var gear_rotation_box = $GearRotationBox
@onready var gear_tick_box = $GearTickBox
@onready var gear_tock_box = $GearTockBox

var gear_rotation: float = 90.0
var gear_tick: float = 4000.0
var gear_tock: float = 500.0


func _ready() -> void:
	gear_rotation_box.init("float", "90.0", -360.0, 360.0)
	gear_rotation_box.return_line.connect(_change_gear_rotation)
	gear_tick_box.init("float", "4000.0", 0.0, 99999999.9)
	gear_tick_box.return_line.connect(_change_gear_tick)
	gear_tock_box.init("float", "500.0", 0.0, 99999999.9)
	gear_tock_box.return_line.connect(_change_gear_tock)
	connect_node(self, "gear_settings_changed")


func _change_gear_rotation(new_gear_rotation: float):
	gear_rotation = new_gear_rotation
	emit_signal("gear_settings_changed", {"gear_rotation": gear_rotation, "gear_tick": gear_tick, "gear_tock": gear_tock})


func _change_gear_tick(new_gear_tick: float):
	gear_tick = new_gear_tick
	emit_signal("gear_settings_changed", {"gear_rotation": gear_rotation, "gear_tick": gear_tick, "gear_tock": gear_tock})


func _change_gear_tock(new_gear_tock: float):
	gear_tock = new_gear_tock
	emit_signal("gear_settings_changed", {"gear_rotation": gear_rotation, "gear_tick": gear_tick, "gear_tock": gear_tock})


func set_settings(new_settings: Dictionary):
	if new_settings.has("gear_rotation"):
		gear_rotation = clamp(new_settings.gear_rotation, -360.0, 360.0)
		gear_rotation_box._update_text(str(gear_rotation))
	if new_settings.has("gear_tick"):
		gear_tick = clamp(new_settings.gear_tick, 0.0, 99999999.9)
		gear_tick_box._update_text(str(gear_tick))
	if new_settings.has("gear_tock"):
		gear_tock = clamp(new_settings.gear_tock, 0.0, 99999999.9)
		gear_tock_box._update_text(str(gear_tock))
