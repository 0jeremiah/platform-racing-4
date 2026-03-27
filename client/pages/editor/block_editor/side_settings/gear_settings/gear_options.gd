extends Control

signal gear_options_changed

@onready var gear_rotation_box = $GearRotationBox
@onready var tick_box = $TickBox
@onready var tock_box = $TockBox

var gear_rotation: float = 90.0
var tick: float = 4000.0
var tock: float = 500.0


func _ready() -> void:
	gear_rotation_box.init("float", "90.0", -360.0, 360.0)
	gear_rotation_box.return_line.connect(_change_gear_rotation)
	tick_box.init("float", "4000.0", 0.0, 99999999.9)
	tick_box.return_line.connect(_change_tick)
	tock_box.init("float", "500.0", 0.0, 99999999.9)
	tock_box.return_line.connect(_change_tock)


func _change_gear_rotation(new_gear_rotation: float):
	gear_rotation = new_gear_rotation
	emit_signal("gear_options_changed", {"rotation": gear_rotation, "tick": tick, "tock": tock})


func set_gear_rotation(new_gear_rotation: float):
	gear_rotation_box._update_text(str(new_gear_rotation))
	gear_rotation = clamp(new_gear_rotation, -360.0, 360.0)


func _change_tick(new_tick: float):
	tick = new_tick
	emit_signal("gear_options_changed", {"rotation": gear_rotation, "tick": tick, "tock": tock})


func set_tick(new_tick: float):
	tick_box._update_text(str(new_tick))
	tick = clamp(new_tick, 0.0, 99999999.9)


func _change_tock(new_tock: float):
	tock = new_tock
	emit_signal("gear_options_changed", {"rotation": gear_rotation, "tick": tick, "tock": tock})


func set_tock(new_tock: float):
	tock_box._update_text(str(new_tock))
	tock = clamp(tock, 0.0, 99999999.9)
