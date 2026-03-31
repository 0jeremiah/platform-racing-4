extends SideOption

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
	connect_node(self, "gear_options_changed")


func _change_gear_rotation(new_gear_rotation: float):
	gear_rotation = new_gear_rotation
	emit_signal("gear_options_changed", {"rotation": gear_rotation, "tick": tick, "tock": tock})


func _change_tick(new_tick: float):
	tick = new_tick
	emit_signal("gear_options_changed", {"rotation": gear_rotation, "tick": tick, "tock": tock})


func _change_tock(new_tock: float):
	tock = new_tock
	emit_signal("gear_options_changed", {"rotation": gear_rotation, "tick": tick, "tock": tock})


func set_options(new_options: Dictionary):
	if new_options.has("rotation"):
		gear_rotation = clamp(new_options.rotation, -360.0, 360.0)
		gear_rotation_box._update_text(str(rotation))
	if new_options.has("tick"):
		tick = clamp(new_options.tick, 0.0, 99999999.9)
		tick_box._update_text(str(tick))
	if new_options.has("tock"):
		tock = clamp(new_options.tock, 0.0, 99999999.9)
		tock_box._update_text(str(tock))
	options = {"rotation": gear_rotation, "tick": tick, "tock": tock}
