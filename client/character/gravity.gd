class_name Gravity
## Handles gravity and character rotation.
## Manages rotation transitions and applies appropriate gravity forces.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var gravity_rotated: Vector2 = Vector2(gravity)
var base_up_direction: Vector2 = Vector2(0, -1)
var rotation: float = 0
var target_rotation: float = 0
var rotation_speed: float = 0.025
var rotation_sync: bool = true


func run(character: Character, delta: float, gravity_multiplier: float = 1.0) -> void:
	# Rotate
	var current_gravity = gravity * gravity_multiplier
	if character.movement.swimming:
		var safe_gravity_x = 0.0 if gravity_multiplier == 0.0 else current_gravity.x / 2
		var safe_gravity_y = 0.0 if gravity_multiplier == 0.0 else current_gravity.y / 2
		current_gravity = Vector2(safe_gravity_x, safe_gravity_y)
	var current_gravity_rotated = current_gravity.rotated(rotation)
	rotation_sync = true
	if rotation != target_rotation:
		rotation_sync = false
		var rotation_dist = clamp(rotation - target_rotation, -rotation_speed, rotation_speed)
		if abs(rotation_dist) < rotation_speed:
			rotation = target_rotation
			target_rotation = rotation # deal with rotation switching from negative to positive
		else:
			rotation -= rotation_dist
	
	# Apply to character
	character.rotation = rotation
	character.up_direction = base_up_direction.rotated(rotation)
	if rotation_sync:
		character.movement.current_velocity += current_gravity_rotated * delta


func not_rotating() -> bool:
	return rotation_sync
