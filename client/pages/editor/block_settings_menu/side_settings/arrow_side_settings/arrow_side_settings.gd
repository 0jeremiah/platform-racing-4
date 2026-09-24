extends BlockSideSetting

signal arrow_side_settings_changed

@onready var horizontal_force_box = $HorizontalForceBox
@onready var vertical_force_box = $VerticalForceBox
@onready var direction_x_box = $DirectionXBox
@onready var direction_y_box = $DirectionYBox

var horizontal_force: float = 125.0
var vertical_force: float = 110.0
var direction: Vector2 = Vector2(0.0, -1.0)


func _ready() -> void:
	horizontal_force_box.init("float", "125.0", -9999999.9, 99999999.9)
	horizontal_force_box.return_line.connect(_change_horizontal_force)
	vertical_force_box.init("float", "110.0", -9999999.9, 99999999.9)
	vertical_force_box.return_line.connect(_change_vertical_force)
	direction_x_box.init("float", "0.0", -9999999.9, 99999999.9)
	direction_x_box.return_line.connect(_change_direction_x)
	direction_y_box.init("float", "-1.0", -9999999.9, 99999999.9)
	direction_y_box.return_line.connect(_change_direction_y)
	connect_node(self, "arrow_side_settings_changed")


func _change_horizontal_force(new_horizontal_force: float):
	horizontal_force = new_horizontal_force
	emit_signal("arrow_side_settings_changed", {"horizontal_force": horizontal_force, "vertical_force": vertical_force, "direction": {"x": direction.x, "y": direction.y}})


func _change_vertical_force(new_vertical_force: float):
	vertical_force = new_vertical_force
	emit_signal("arrow_side_settings_changed", {"horizontal_force": horizontal_force, "vertical_force": vertical_force, "direction": {"x": direction.x, "y": direction.y}})


func _change_direction_x(new_direction_x: float):
	direction = Vector2(new_direction_x, direction.y)
	emit_signal("arrow_side_settings_changed", {"horizontal_force": horizontal_force, "vertical_force": vertical_force, "direction": {"x": direction.x, "y": direction.y}})


func _change_direction_y(new_direction_y: float):
	direction = Vector2(direction.x, new_direction_y)
	emit_signal("arrow_side_settings_changed", {"horizontal_force": horizontal_force, "vertical_force": vertical_force, "direction": {"x": direction.x, "y": direction.y}})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("horizontal_force"):
		horizontal_force = clamp(new_side_settings.horizontal_force, -9999999.9, 99999999.9)
		horizontal_force_box._update_text(str(horizontal_force))
	if new_side_settings.has("vertical_force"):
		vertical_force = clamp(new_side_settings.vertical_force, -9999999.9, 99999999.9)
		vertical_force_box._update_text(str(vertical_force))
	if new_side_settings.has("direction"):
		direction = Vector2(clamp(new_side_settings.direction.x, -9999999.9, 99999999.9), clamp(new_side_settings.direction.y, -9999999.9, 99999999.9))
		direction_x_box._update_text(str(direction.x))
		direction_y_box._update_text(str(direction.y))
	side_settings = {"horizontal_force": horizontal_force, "vertical_force": vertical_force, "direction": {"x": direction.x, "y": direction.y}}
