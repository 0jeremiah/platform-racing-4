extends Control

signal arrow_options_changed

@onready var force_box = $ForceBox
@onready var direction_x_box = $DirectionXBox
@onready var direction_y_box = $DirectionYBox

var force: float = 111.0
var direction: Vector2 = Vector2(0.0, -1.0)


func _ready() -> void:
	force_box.init("float", "111.0", -9999999.9, 99999999.9)
	force_box.return_line.connect(_change_force)
	direction_x_box.init("float", "0.0", -9999999.9, 99999999.9)
	direction_x_box.return_line.connect(_change_direction_x)
	direction_y_box.init("float", "-1.0", -9999999.9, 99999999.9)
	direction_y_box.return_line.connect(_change_direction_y)


func _change_force(new_force: float):
	force = new_force
	emit_signal("arrow_options_changed", {"force": force, "direction": direction})


func set_force(new_force: float):
	force_box._update_text(str(new_force))
	force = new_force


func _change_direction_x(new_direction_x: float):
	direction = Vector2(new_direction_x, direction.y)
	emit_signal("arrow_options_changed", {"force": force, "direction": direction})


func set_direction_x(new_direction_x: float):
	direction_x_box._update_text(str(new_direction_x))
	direction = Vector2(new_direction_x, direction.y)


func _change_direction_y(new_direction_y: float):
	direction = Vector2(direction.x, new_direction_y)
	emit_signal("arrow_options_changed", {"force": force, "direction": direction})


func set_direction_y(new_direction_y: float):
	direction_y_box._update_text(str(new_direction_y))
	direction = Vector2(direction.x, new_direction_y)
