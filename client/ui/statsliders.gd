extends Control

@onready var stats_remaining_label = $StatsRemainingLabel
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

var speed: int = 50
var accel: int = 50
var jump: int = 50
var skill: int = 50
var rank: int = 0
var stats_points: int = 200


func _ready() -> void:
	speed_box.init("int", str(speed), 0.0, 100.0)
	accel_box.init("int", str(accel), 0.0, 100.0)
	jump_box.init("int", str(jump), 0.0, 100.0)
	skill_box.init("int", str(skill), 0.0, 100.0)
	speed_dec_button.pressed.connect(_set_speed.bind(-1, true))
	speed_inc_button.pressed.connect(_set_speed.bind(1, true))
	speed_slider.value_changed.connect(_set_speed.bind())
	speed_box.return_line.connect(_set_speed.bind())
	accel_dec_button.pressed.connect(_set_accel.bind(-1, true))
	accel_inc_button.pressed.connect(_set_accel.bind(1, true))
	accel_slider.value_changed.connect(_set_accel.bind())
	accel_box.return_line.connect(_set_accel.bind())
	jump_dec_button.pressed.connect(_set_jump.bind(-1, true))
	jump_inc_button.pressed.connect(_set_jump.bind(1, true))
	jump_slider.value_changed.connect(_set_jump.bind())
	jump_box.return_line.connect(_set_jump.bind())
	skill_dec_button.pressed.connect(_set_skill.bind(-1, true))
	skill_inc_button.pressed.connect(_set_skill.bind(1, true))
	skill_slider.value_changed.connect(_set_skill.bind())
	skill_box.return_line.connect(_set_skill.bind())
	stats_points = clamp(200 + (10 * rank), 200, 400)


func get_points_left():
	return stats_points - speed - accel - jump - skill


func _set_speed(new_speed: int, inc_or_dec: bool = false) -> void:
	if inc_or_dec and speed + new_speed + accel + jump + skill <= stats_points:
		speed = clamp(speed + new_speed, 0, 100)
	elif !inc_or_dec and new_speed + accel + jump + skill <= stats_points:
		speed = clamp(new_speed, 0, 100)
	elif !inc_or_dec:
		speed = clamp(speed + get_points_left(), 0, 100)
	speed_box._update_text(str(speed))
	speed_slider.value = float(speed)
	stats_remaining_label.text = "Points Remaining: " + str(get_points_left())


func _set_accel(new_accel: int, inc_or_dec: bool = false) -> void:
	if inc_or_dec and speed + accel + new_accel + jump + skill <= stats_points:
		accel = clamp(accel + new_accel, 0, 100)
	elif !inc_or_dec and speed + new_accel + jump + skill <= stats_points:
		accel = clamp(new_accel, 0, 100)
	elif !inc_or_dec:
		accel = clamp(accel + get_points_left(), 0, 100)
	accel_box._update_text(str(accel))
	accel_slider.value = float(accel)
	stats_remaining_label.text = "Points Remaining: " + str(get_points_left())


func _set_jump(new_jump: int, inc_or_dec: bool = false) -> void:
	if inc_or_dec and speed + accel + jump + new_jump + skill <= stats_points:
		jump = clamp(jump + new_jump, 0, 100)
	elif !inc_or_dec and speed + accel + new_jump + skill <= stats_points:
		jump = clamp(new_jump, 0, 100)
	elif !inc_or_dec:
		jump = clamp(jump + get_points_left(), 0, 100)
	jump_box._update_text(str(jump))
	jump_slider.value = float(jump)
	stats_remaining_label.text = "Points Remaining: " + str(get_points_left())


func _set_skill(new_skill: int, inc_or_dec: bool = false) -> void:
	if inc_or_dec and speed + accel + jump + skill + new_skill <= stats_points:
		skill = clamp(skill + new_skill, 0, 100)
	elif !inc_or_dec and speed + accel + jump + new_skill <= stats_points:
		skill = clamp(new_skill, 0, 100)
	elif !inc_or_dec:
		skill = clamp(skill + get_points_left(), 0, 100)
	skill_box._update_text(str(skill))
	skill_slider.value = float(skill)
	stats_remaining_label.text = "Points Remaining: " + str(get_points_left())
