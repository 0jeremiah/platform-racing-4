extends BlockSetting

signal egg_settings_changed

@onready var egg_can_run_check_box = $EggCanRunCheckBox
@onready var egg_can_jump_check_box = $EggCanJumpCheckBox
@onready var egg_can_disguise_check_box = $EggCanDisguiseCheckBox
@onready var egg_walk_velocity_box = $EggWalkVelocityBox
@onready var egg_run_velocity_box = $EggRunVelocityBox
@onready var egg_jump_velocity_box = $EggJumpVelocityBox
@onready var egg_gravity_x_box = $EggGravityXBox
@onready var egg_gravity_y_box = $EggGravityYBox

var egg_walk_velocity: float = ConfigurableBlockSettings.default_block_properties.egg_walk_velocity
var egg_run_velocity: float = ConfigurableBlockSettings.default_block_properties.egg_run_velocity
var egg_jump_velocity: float = ConfigurableBlockSettings.default_block_properties.egg_jump_velocity
var egg_gravity: Vector2 = Vector2(ConfigurableBlockSettings.default_block_properties.egg_gravity.x, ConfigurableBlockSettings.default_block_properties.egg_gravity.y)
var egg_can_run: bool = ConfigurableBlockSettings.default_block_properties.egg_can_run
var egg_can_jump: bool = ConfigurableBlockSettings.default_block_properties.egg_can_jump
var egg_can_disguise: bool = ConfigurableBlockSettings.default_block_properties.egg_can_disguise


func _ready() -> void:
	egg_walk_velocity_box.init("float", str(egg_walk_velocity), -9999999.9, 99999999.9)
	egg_walk_velocity_box.return_line.connect(_update_egg_walk_velocity)
	egg_run_velocity_box.init("float", str(egg_run_velocity), -9999999.9, 99999999.9)
	egg_run_velocity_box.return_line.connect(_update_egg_run_velocity)
	egg_jump_velocity_box.init("float", str(egg_jump_velocity), -9999999.9, 0.00000001)
	egg_jump_velocity_box.return_line.connect(_update_egg_jump_velocity)
	egg_gravity_x_box.init("float", str(egg_gravity.x), -9999999.9, 99999999.9)
	egg_gravity_x_box.return_line.connect(_update_egg_gravity_x)
	egg_gravity_y_box.init("float", str(egg_gravity.y), -9999999.9, 99999999.9)
	egg_gravity_y_box.return_line.connect(_update_egg_gravity_y)
	egg_can_run_check_box.pressed.connect(_toggle_egg_can_run)
	egg_can_jump_check_box.pressed.connect(_toggle_egg_can_jump)
	egg_can_disguise_check_box.pressed.connect(_toggle_egg_can_disguise)
	connect_node(self, "egg_settings_changed")


func send_signal():
	emit_signal("egg_settings_changed", {"egg_walk_velocity": egg_walk_velocity, "egg_run_velocity": egg_run_velocity,
	"egg_jump_velocity": egg_jump_velocity, "egg_gravity": {"x": egg_gravity.x, "y": egg_gravity.y},
	"egg_can_run": egg_can_run, "egg_can_jump": egg_can_jump, "egg_can_disguise": egg_can_disguise})


func _update_egg_walk_velocity(new_egg_walk_velocity: float):
	egg_walk_velocity = new_egg_walk_velocity
	send_signal()


func _update_egg_run_velocity(new_egg_run_velocity: float):
	egg_run_velocity = new_egg_run_velocity
	send_signal()


func _update_egg_jump_velocity(new_egg_jump_velocity: float):
	egg_jump_velocity = new_egg_jump_velocity
	send_signal()


func _update_egg_gravity_x(new_egg_gravity_x: float):
	egg_gravity = Vector2(new_egg_gravity_x, egg_gravity.y)
	send_signal()


func _update_egg_gravity_y(new_egg_gravity_y: float):
	egg_gravity = Vector2(egg_gravity.x, new_egg_gravity_y)
	send_signal()


func _toggle_egg_can_run():
	egg_can_run = egg_can_run_check_box.button_pressed
	send_signal()


func _toggle_egg_can_jump():
	egg_can_jump = egg_can_jump_check_box.button_pressed
	send_signal()


func _toggle_egg_can_disguise():
	egg_can_disguise = egg_can_disguise_check_box.button_pressed
	send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("egg_walk_velocity"):
		egg_walk_velocity = clamp(new_settings.egg_walk_velocity, -9999999.9, 99999999.9)
		egg_walk_velocity_box._update_text(str(egg_walk_velocity))
	if new_settings.has("egg_run_velocity"):
		egg_run_velocity = clamp(new_settings.egg_run_velocity, -9999999.9, 99999999.9)
		egg_run_velocity_box._update_text(str(egg_run_velocity))
	if new_settings.has("egg_jump_velocity"):
		egg_jump_velocity = clamp(new_settings.egg_jump_velocity, -9999999.9, 0.00000001)
		egg_jump_velocity_box._update_text(str(egg_jump_velocity))
	if new_settings.has("egg_gravity"):
		egg_gravity = Vector2(clamp(new_settings.egg_gravity.x, -9999999.9, 99999999.9), clamp(new_settings.egg_gravity.y, -9999999.9, 99999999.9))
		egg_gravity_x_box._update_text(str(egg_gravity.x))
		egg_gravity_y_box._update_text(str(egg_gravity.y))
	if new_settings.has("egg_can_run"):
		egg_can_run = new_settings.egg_can_run
		egg_can_run_check_box.set_pressed_no_signal(egg_can_run)
	if new_settings.has("egg_can_jump"):
		egg_can_jump = new_settings.egg_can_jump
		egg_can_jump_check_box.set_pressed_no_signal(egg_can_jump)
	if new_settings.has("egg_can_disguise"):
		egg_can_disguise = new_settings.egg_can_disguise
		egg_can_disguise_check_box.set_pressed_no_signal(egg_can_disguise)
