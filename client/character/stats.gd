class_name Stats
## Manages character stats and provides bonus calculations.
## Stats include jump, speed, acceleration, and skill attributes.

var start_speed: int = 50
var start_accel: int = 50
var start_jump: int = 50
var start_skill: int = 50
var jump: int = start_speed
var speed: int = start_accel
var accel: int = start_jump
var skill: int = start_skill
var force: int = 0


func get_jump_bonus() -> float:
	return 1 + (jump / 50.0)


func get_speed_bonus() -> float:
	return 1 + (speed / 50.0)


func get_accel_bonus() -> float:
	return 1 + (accel / 50.0)


func get_skill_bonus() -> float:
	return 1 + (skill / 50.0)


func get_exact_jump() -> float:
	return jump


func get_exact_speed() -> float:
	return speed


func get_exact_accel() -> float:
	return accel


func get_exact_skill() -> float:
	return skill


func set_force(num: float) -> void:
	force = num


func apply_force() -> float:
	return force


func change_stats(num: int) -> void:
	speed = clamp(speed + num, 0, 100)
	accel = clamp(accel + num, 0, 100)
	jump = clamp(jump + num, 0, 100)
	skill = clamp(skill + num, 0, 100)


func set_stats(newspeed: int, newaccel: int, newjump: int, newskill: int, reset: bool = false) -> void:
	if reset:
		speed = clamp(start_speed, 0, 100)
		accel = clamp(start_accel, 0, 100)
		jump = clamp(start_jump, 0, 100)
		skill = clamp(start_skill, 0, 100)
	else:
		speed = clamp(newspeed, 0, 100)
		accel = clamp(newaccel, 0, 100)
		jump = clamp(newjump, 0, 100)
		skill = clamp(newskill, 0, 100)


func get_total() -> Array:
	return [speed, accel, jump, skill]
