extends Control

signal vanish_options_changed

@onready var duration_box = $DurationBox
@onready var cooldown_box = $CooldownBox

var animation_duration: float = 0.3
var cooldown: float = 2.0


func _ready() -> void:
	duration_box.init("float", "0.3", 0.0, 99999999.9)
	duration_box.return_line.connect(_change_animation_duration)
	cooldown_box.init("float", "2.0", 0.0, 99999999.9)
	cooldown_box.return_line.connect(_change_cooldown)


func _change_animation_duration(new_animation_duration: float):
	animation_duration = new_animation_duration
	emit_signal("vanish_options_changed", {"animation_duration": animation_duration, "cooldown": cooldown})


func set_animation_duration(new_animation_duration: float):
	duration_box._update_text(str(new_animation_duration))
	animation_duration = new_animation_duration


func _change_cooldown(new_cooldown: float):
	cooldown = new_cooldown
	emit_signal("vanish_options_changed", {"animation_duration": animation_duration, "cooldown": cooldown})


func set_cooldown(new_cooldown: float):
	cooldown_box._update_text(str(new_cooldown))
	cooldown = new_cooldown
