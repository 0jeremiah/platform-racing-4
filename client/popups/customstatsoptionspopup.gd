extends Control

signal custom_stats_changed

@onready var speed_stat_label = $SpeedStatLabel
@onready var speed_stat_slider = $SpeedStatSlider
@onready var accel_stat_label = $AccelStatLabel
@onready var accel_stat_slider = $AccelStatSlider
@onready var jump_stat_label = $JumpStatLabel
@onready var jump_stat_slider = $JumpStatSlider
@onready var skill_stat_label = $SkillStatLabel
@onready var skill_stat_slider = $SkillStatSlider

var custom_speed: int = 50
var custom_accel: int = 50
var custom_jump: int = 50
var custom_skill: int = 50


func init(new_custom_speed: int, new_custom_accel: int, new_custom_jump: int, new_custom_skill: int):
	custom_speed = new_custom_speed
	custom_accel = new_custom_accel
	custom_jump = new_custom_jump
	custom_skill = new_custom_skill


func _ready() -> void:
	speed_stat_slider.connect("value_changed", set_custom_speed)
	accel_stat_slider.connect("value_changed", set_custom_accel)
	jump_stat_slider.connect("value_changed", set_custom_jump)
	skill_stat_slider.connect("value_changed", set_custom_skill)
	update_text()


func set_custom_stats(new_custom_stats: Array):
	custom_speed = new_custom_stats[0]
	custom_accel = new_custom_stats[1]
	custom_jump = new_custom_stats[2]
	custom_skill = new_custom_stats[3]
	emit_signal("custom_stats_changed", [custom_speed, custom_accel, custom_jump, custom_skill])
	update_text()


func set_custom_speed(new_custom_speed: int):
	custom_speed = new_custom_speed
	emit_signal("custom_stats_changed", [custom_speed, custom_accel, custom_jump, custom_skill])
	update_text()


func set_custom_accel(new_custom_accel: int):
	custom_accel = new_custom_accel
	emit_signal("custom_stats_changed", [custom_speed, custom_accel, custom_jump, custom_skill])
	update_text()


func set_custom_jump(new_custom_jump: int):
	custom_jump = new_custom_jump
	emit_signal("custom_stats_changed", [custom_speed, custom_accel, custom_jump, custom_skill])
	update_text()


func set_custom_skill(new_custom_skill: int):
	custom_skill = new_custom_skill
	emit_signal("custom_stats_changed", [custom_speed, custom_accel, custom_jump, custom_skill])
	update_text()


func update_text():
	speed_stat_label.text = str(custom_speed)
	accel_stat_label.text = str(custom_accel)
	jump_stat_label.text = str(custom_jump)
	skill_stat_label.text = str(custom_skill)
