extends BlockSideSetting

signal custom_stats_side_settings_changed

@onready var speed_dec_button = $SpeedSlider/SpeedDecButton
@onready var speed_inc_button = $SpeedSlider/SpeedIncButton
@onready var speed_slider = $SpeedSlider/SpeedSlider
@onready var speed_box = $SpeedSlider/SpeedBox
@onready var accel_dec_button = $AccelSlider/AccelDecButton
@onready var accel_inc_button = $AccelSlider/AccelIncButton
@onready var accel_slider = $AccelSlider/AccelSlider
@onready var accel_box = $AccelSlider/AccelBox
@onready var jump_dec_button = $JumpSlider/JumpDecButton
@onready var jump_inc_button = $JumpSlider/JumpIncButton
@onready var jump_slider = $JumpSlider/JumpSlider
@onready var jump_box = $JumpSlider/JumpBox
@onready var skill_dec_button = $SkillSlider/SkillDecButton
@onready var skill_inc_button = $SkillSlider/SkillIncButton
@onready var skill_slider = $SkillSlider/SkillSlider
@onready var skill_box = $SkillSlider/SkillBox
@onready var reset_check_box = $ResetCheckBox

var reset: bool = false
var speed: int = 50
var accel: int = 50
var jump: int = 50
var skill: int = 50


func _ready() -> void:
	speed_dec_button.pressed.connect(_change_speed.bind(-1, true))
	speed_inc_button.pressed.connect(_change_speed.bind(1, true))
	speed_slider.value_changed.connect(_change_speed)
	speed_box.init("int", "50", 0, 100)
	speed_box.return_line.connect(_change_speed)
	accel_dec_button.pressed.connect(_change_accel.bind(-1, true))
	accel_inc_button.pressed.connect(_change_accel.bind(1, true))
	accel_slider.value_changed.connect(_change_accel)
	accel_box.init("int", "50", 0, 100)
	accel_box.return_line.connect(_change_accel)
	jump_dec_button.pressed.connect(_change_jump.bind(-1, true))
	jump_inc_button.pressed.connect(_change_jump.bind(1, true))
	jump_slider.value_changed.connect(_change_jump)
	jump_box.init("int", "50", 0, 100)
	jump_box.return_line.connect(_change_jump)
	skill_dec_button.pressed.connect(_change_skill.bind(-1, true))
	skill_inc_button.pressed.connect(_change_skill.bind(1, true))
	skill_slider.value_changed.connect(_change_skill)
	skill_box.init("int", "50", 0, 100)
	skill_box.return_line.connect(_change_skill)
	reset_check_box.pressed.connect(_toggle_reset)
	connect_node(self, "custom_stats_side_settings_changed")


func _toggle_reset():
	reset = reset_check_box.button_pressed
	emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})


func _change_speed(new_speed: int, inc_or_dec: bool = false):
	if inc_or_dec and speed + new_speed > 0 and speed + new_speed < 100:
		speed += new_speed
		if speed_slider.value != speed:
			speed_slider.set_value_no_signal(speed)
		if int(speed_box.text) != speed:
			speed_box._update_text(str(speed))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})
	elif new_speed > 0 and new_speed < 100:
		speed = new_speed
		if speed_slider.value != speed:
			speed_slider.set_value_no_signal(speed)
		if int(speed_box.text) != speed:
			speed_box._update_text(str(speed))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})


func _change_accel(new_accel: int, inc_or_dec: bool = false):
	if inc_or_dec and accel + new_accel > 0 and accel + new_accel < 100:
		accel += new_accel
		if accel_slider.value != accel:
			accel_slider.set_value_no_signal(accel)
		if int(accel_box.text) != accel:
			accel_box._update_text(str(accel))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})
	elif new_accel > 0 and new_accel < 100:
		accel = new_accel
		if accel_slider.value != accel:
			accel_slider.set_value_no_signal(accel)
		if int(accel_box.text) != accel:
			accel_box._update_text(str(accel))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})


func _change_jump(new_jump: int, inc_or_dec: bool = false):
	if inc_or_dec and jump + new_jump > 0 and jump + jump < 100:
		jump += new_jump
		if jump_slider.value != jump:
			jump_slider.set_value_no_signal(jump)
		if int(jump_box.text) != jump:
			jump_box._update_text(str(jump))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})
	elif new_jump > 0 and new_jump < 100:
		jump = new_jump
		if jump_slider.value != jump:
			jump_slider.set_value_no_signal(jump)
		if int(jump_box.text) != jump:
			jump_box._update_text(str(jump))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})


func _change_skill(new_skill: int, inc_or_dec: bool = false):
	if inc_or_dec and skill + new_skill > 0 and skill + new_skill < 100:
		skill += new_skill
		if skill_slider.value != skill:
			skill_slider.set_value_no_signal(skill)
		if int(skill_box.text) != skill:
			skill_box._update_text(str(skill))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})
	elif new_skill > 0 and new_skill < 100:
		skill = new_skill
		if skill_slider.value != skill:
			skill_slider.set_value_no_signal(skill)
		if int(skill_box.text) != skill:
			skill_box._update_text(str(skill))
		emit_signal("custom_stats_side_settings_changed", {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("reset"):
		reset = new_side_settings.reset
	if new_side_settings.has("speed"):
		speed = clamp(new_side_settings.speed, 0, 100)
		speed_slider.set_value_no_signal(speed)
		speed_box._update_text(str(speed))
	if new_side_settings.has("accel"):
		accel = clamp(new_side_settings.accel, 0, 100)
		accel_slider.set_value_no_signal(accel)
		accel_box._update_text(str(accel))
	if new_side_settings.has("jump"):
		jump = clamp(new_side_settings.jump, 0, 100)
		jump_slider.set_value_no_signal(jump)
		jump_box._update_text(str(jump))
	if new_side_settings.has("skill"):
		skill = clamp(new_side_settings.skill, 0, 100)
		skill_slider.set_value_no_signal(skill)
		skill_box._update_text(str(skill))
	side_settings = {"reset": reset, "speed": speed, "accel": accel, "jump": jump, "skill": skill}
