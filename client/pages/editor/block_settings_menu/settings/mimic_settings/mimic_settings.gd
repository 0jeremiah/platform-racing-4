extends BlockSetting

signal mimic_settings_changed

@onready var mimic_can_run_check_box = $MimicCanRunCheckBox
@onready var mimic_can_jump_check_box = $MimicCanJumpCheckBox
@onready var mimic_can_disguise_check_box = $MimicCanDisguiseCheckBox
@onready var mimic_randomize_color1_check_box = $MimicRandomizeColor1CheckBox
@onready var mimic_randomize_color2_check_box = $MimicRandomizeColor2CheckBox
@onready var mimic_walk_velocity_box = $MimicWalkVelocityBox
@onready var mimic_run_velocity_box = $MimicRunVelocityBox
@onready var mimic_jump_velocity_box = $MimicJumpVelocityBox
@onready var mimic_gravity_x_box = $MimicGravityXBox
@onready var mimic_gravity_y_box = $MimicGravityYBox
@onready var mimic_color1_button = $MimicColor1Button
@onready var mimic_color2_button = $MimicColor2Button

var mimic_walk_velocity: float = ConfigurableBlockSettings.default_block_properties.mimic_walk_velocity
var mimic_run_velocity: float = ConfigurableBlockSettings.default_block_properties.mimic_run_velocity
var mimic_jump_velocity: float = ConfigurableBlockSettings.default_block_properties.mimic_jump_velocity
var mimic_gravity: Vector2 = Vector2(ConfigurableBlockSettings.default_block_properties.mimic_gravity.x, ConfigurableBlockSettings.default_block_properties.mimic_gravity.y)
var mimic_can_run: bool = ConfigurableBlockSettings.default_block_properties.mimic_can_run
var mimic_can_jump: bool = ConfigurableBlockSettings.default_block_properties.mimic_can_jump
var mimic_can_disguise: bool = ConfigurableBlockSettings.default_block_properties.mimic_can_disguise
var mimic_color1: Color = Color(ConfigurableBlockSettings.default_block_properties.mimic_color1)
var mimic_color2: Color = Color(ConfigurableBlockSettings.default_block_properties.mimic_color2)
var mimic_randomize_color1: bool = ConfigurableBlockSettings.default_block_properties.mimic_randomize_color1
var mimic_randomize_color2: bool = ConfigurableBlockSettings.default_block_properties.mimic_randomize_color2


func _ready() -> void:
	mimic_walk_velocity_box.init("float", str(mimic_walk_velocity), -9999999.9, 99999999.9)
	mimic_walk_velocity_box.return_line.connect(_update_mimic_walk_velocity)
	mimic_run_velocity_box.init("float", str(mimic_run_velocity), -9999999.9, 99999999.9)
	mimic_run_velocity_box.return_line.connect(_update_mimic_run_velocity)
	mimic_jump_velocity_box.init("float", str(mimic_jump_velocity), -9999999.9, 0.00000001)
	mimic_jump_velocity_box.return_line.connect(_update_mimic_jump_velocity)
	mimic_gravity_x_box.init("float", str(mimic_gravity.x), -9999999.9, 99999999.9)
	mimic_gravity_x_box.return_line.connect(_update_mimic_gravity_x)
	mimic_gravity_y_box.init("float", str(mimic_gravity.y), -9999999.9, 99999999.9)
	mimic_gravity_y_box.return_line.connect(_update_mimic_gravity_y)
	mimic_can_run_check_box.pressed.connect(_toggle_mimic_can_run)
	mimic_can_jump_check_box.pressed.connect(_toggle_mimic_can_jump)
	mimic_can_disguise_check_box.pressed.connect(_toggle_mimic_can_disguise)
	mimic_color1_button.set_color_button_scale(Vector2(0.625, 0.625))
	mimic_color1_button.set_color(mimic_color1)
	mimic_color1_button.colorbutton_color_changed.connect(_change_mimic_color1)
	mimic_color2_button.set_color_button_scale(Vector2(0.625, 0.625))
	mimic_color2_button.set_color(mimic_color2)
	mimic_color2_button.colorbutton_color_changed.connect(_change_mimic_color2)
	mimic_randomize_color1_check_box.pressed.connect(_toggle_mimic_randomize_color1)
	mimic_randomize_color2_check_box.pressed.connect(_toggle_mimic_randomize_color2)
	connect_node(self, "mimic_settings_changed")


func send_signal():
	emit_signal("mimic_settings_changed", {"mimic_walk_velocity": mimic_walk_velocity,
	"mimic_run_velocity": mimic_run_velocity, "mimic_jump_velocity": mimic_jump_velocity,
	"mimic_gravity": {"x": mimic_gravity.x, "y": mimic_gravity.y}, "mimic_can_run": mimic_can_run,
	"mimic_can_jump": mimic_can_jump, "mimic_can_disguise": mimic_can_disguise,
	"mimic_color1": mimic_color1.to_html(false), "mimic_color2": mimic_color2.to_html(false),
	"mimic_randomize_color1": mimic_randomize_color1, "mimic_randomize_color2": mimic_randomize_color2})


func _update_mimic_walk_velocity(new_mimic_walk_velocity: float):
	mimic_walk_velocity = new_mimic_walk_velocity
	send_signal()


func _update_mimic_run_velocity(new_mimic_run_velocity: float):
	mimic_run_velocity = new_mimic_run_velocity
	send_signal()


func _update_mimic_jump_velocity(new_mimic_jump_velocity: float):
	mimic_jump_velocity = new_mimic_jump_velocity
	send_signal()


func _update_mimic_gravity_x(new_mimic_gravity_x: float):
	mimic_gravity = Vector2(new_mimic_gravity_x, mimic_gravity.y)
	send_signal()


func _update_mimic_gravity_y(new_mimic_gravity_y: float):
	mimic_gravity = Vector2(mimic_gravity.x, new_mimic_gravity_y)
	send_signal()


func _toggle_mimic_can_run():
	mimic_can_run = mimic_can_run_check_box.button_pressed
	send_signal()


func _toggle_mimic_can_jump():
	mimic_can_jump = mimic_can_jump_check_box.button_pressed
	send_signal()


func _toggle_mimic_can_disguise():
	mimic_can_disguise = mimic_can_disguise_check_box.button_pressed
	send_signal()


func _change_mimic_color1(new_mimic_color1: Color):
	mimic_color1 = new_mimic_color1
	send_signal()


func _change_mimic_color2(new_mimic_color2: Color):
	mimic_color2 = new_mimic_color2
	send_signal()


func _toggle_mimic_randomize_color1():
	mimic_randomize_color1 = mimic_randomize_color1_check_box.button_pressed
	send_signal()


func _toggle_mimic_randomize_color2():
	mimic_randomize_color2 = mimic_randomize_color2_check_box.button_pressed
	send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("mimic_walk_velocity"):
		mimic_walk_velocity = clamp(new_settings.mimic_walk_velocity, -9999999.9, 99999999.9)
		mimic_walk_velocity_box._update_text(str(mimic_walk_velocity))
	if new_settings.has("mimic_run_velocity"):
		mimic_run_velocity = clamp(new_settings.mimic_run_velocity, -9999999.9, 99999999.9)
		mimic_run_velocity_box._update_text(str(mimic_run_velocity))
	if new_settings.has("mimic_jump_velocity"):
		mimic_jump_velocity = clamp(new_settings.mimic_jump_velocity, -9999999.9, 0.00000001)
		mimic_jump_velocity_box._update_text(str(mimic_jump_velocity))
	if new_settings.has("mimic_gravity"):
		mimic_gravity = Vector2(clamp(new_settings.mimic_gravity.x, -9999999.9, 99999999.9), clamp(new_settings.mimic_gravity.y, -9999999.9, 99999999.9))
		mimic_gravity_x_box._update_text(str(mimic_gravity.x))
		mimic_gravity_y_box._update_text(str(mimic_gravity.y))
	if new_settings.has("mimic_can_run"):
		mimic_can_run = new_settings.mimic_can_run
		mimic_can_run_check_box.set_pressed_no_signal(mimic_can_run)
	if new_settings.has("mimic_can_jump"):
		mimic_can_jump = new_settings.mimic_can_jump
		mimic_can_jump_check_box.set_pressed_no_signal(mimic_can_jump)
	if new_settings.has("mimic_can_disguise"):
		mimic_can_disguise = new_settings.mimic_can_disguise
		mimic_can_disguise_check_box.set_pressed_no_signal(mimic_can_disguise)
	if new_settings.has("mimic_color1"):
		mimic_color1 = Color(new_settings.mimic_color1)
		mimic_color1_button.set_color(mimic_color1)
	if new_settings.has("mimic_color2"):
		mimic_color2 = Color(new_settings.mimic_color2)
		mimic_color2_button.set_color(mimic_color2)
	if new_settings.has("mimic_randomize_color1"):
		mimic_randomize_color1 = new_settings.mimic_randomize_color1
		mimic_randomize_color1_check_box.set_pressed_no_signal(mimic_randomize_color1)
	if new_settings.has("mimic_randomize_color2"):
		mimic_randomize_color2 = new_settings.mimic_randomize_color2
		mimic_randomize_color2_check_box.set_pressed_no_signal(mimic_randomize_color2)
