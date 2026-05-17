class_name MovementController
## Controls character movement, including walking, jumping, and swimming.
## Handles physics, frozen status, and damage hitstun.

var up_pressed: bool = false
var down_pressed: bool = false
var left_pressed: bool = false
var right_pressed: bool = false
var space_pressed: bool = false
var jump_timer: float = 0
var facing: int = 1
var jumped: bool = false
var can_move: bool = true
var can_jump: bool = true
var is_crouching: bool = false
var previous_velocity: Vector2 = Vector2(0, 0)
var last_velocity: Vector2 = Vector2(0, 0)
var size: float = 1
var last_collision_normal: Vector2 = Vector2(0, 0)
var attempting_bump: bool = false
var last_bumped_block: Dictionary = {}
var swimming: bool = false
var phantom_velocity: Vector2 = Vector2(0, 0)
var phantom_velocity_decay: float = 0.25
var accel: float = 0.0
var speedburst_boost: float = 1.0
var on_ice: bool = false
var ice_friction: float = 0.0
var frozen: bool = false
var frozen_timer: float = 0.0
var frozen_display_node = null
var hurt: bool = false
var hitstun_timer: float = 0.0
var hitstun_duration: float = 0.0
var shielded: bool = false
var invincible: bool = false
var invincibility_timer: float = 0.0
var on_sticky_block: bool = false
var speed_stickiness: float = 2.5
var jump_stickiness: float = 8
var is_wall_sliding: bool = false
var wall_sliding_dir: int = 0
var can_wall_jump: bool = true
var last_wall_jump_dir: int = 0
var wall_slide_friction_timer: float = 0.25
var finished: bool = false


func _init(ice_node = null):
	frozen_display_node = ice_node


func process(delta: float, character: Character, stats: Stats, gravity: Gravity, super_jump: SuperJump) -> Vector2:
	var velocity = character.velocity
	
	if !attempting_bump:
		last_bumped_block = {}
	attempting_bump = false
	
	# Process freezing effect
	var traction = GameConfig.get_value("player_movement", "player_traction")
	if frozen and frozen_timer >= 0:
		frozen_timer -= delta
		if frozen_display_node:
			frozen_display_node.visible = true
			frozen_display_node.modulate.a = ((1 / (3.0 / stats.get_skill_bonus())) * frozen_timer)
			frozen_display_node.scale.y = ((0.65 / (3.0 / stats.get_skill_bonus())) * frozen_timer)
			character.display.modulate = Color(1.0 - (frozen_display_node.modulate.a / 2), 1.0, 1.0)
		traction = GameConfig.get_value("player_movement", "player_traction") / 10.0
	else:
		if frozen_display_node:
			frozen_display_node.visible = false
		frozen = false
	
	# Process hitstun
	if hurt:
		if hitstun_timer - delta > 0:
			hitstun_timer -= delta
		else:
			hitstun_timer = 0
			hurt = false
	
	# Process invincibility
	if invincible:
		if invincibility_timer - delta > 0:
			invincibility_timer -= delta
		else:
			invincibility_timer = 0
			invincible = false
	
	# Handle input for movement
	up_pressed = false
	down_pressed = false
	left_pressed = false
	right_pressed = false
	space_pressed = false
	var horizontal_axis: float = Input.get_axis("left", "right")
	var vertical_axis: float = Input.get_axis("down", "up")
	if horizontal_axis != 0:
		if horizontal_axis < 0:
			left_pressed = true
		else:
			right_pressed = true
	if vertical_axis != 0:
		if vertical_axis < 0:
			down_pressed = true
		else:
			up_pressed = true
	if !hurt and horizontal_axis < 0:
		facing = -1
	elif !hurt and horizontal_axis > 0:
		facing = 1
		
	# Checks if player is rotating
	var not_rotating: bool = gravity.not_rotating(delta)

	# Handle regular jump
	if not hurt and can_jump and Input.is_action_pressed("jump"):
		if is_crouching:
			character._bump_tile_covering_high_area()
		elif character.is_on_floor() and velocity.rotated(-character.rotation).y > GameConfig.get_value("player_movement", "player_jump_velocity") * GameConfig.get_value("player_movement", "player_jump_velocity_multiplier"):
			jumped = true
			jump_timer = GameConfig.get_value("player_movement", "player_coyote_jump_time")
			Jukebox.play_sound("jump")
	
	# Reset wall sliding if on floor or swimming
	if character.is_on_floor() or swimming:
		is_wall_sliding = false
		wall_sliding_dir = 0
		can_wall_jump = true  # Reset wall jump after touching the ground
		last_wall_jump_dir = 0
		wall_slide_friction_timer = GameConfig.get_value("player_movement", "player_wall_slide_friction_decay_time")
	
	# Check for wall sliding
	if not_rotating and not character.is_on_floor() and not swimming and on_sticky_block:
		# Check for wall sliding on right walls
		if character.is_on_wall() and character.get_wall_normal().rotated(-character.rotation).x < -0.7 and last_wall_jump_dir != 1:
			if horizontal_axis > 0 or (horizontal_axis == 0 and Input.is_action_pressed("left")) or wall_sliding_dir == 1:  # Pressing against the wall
				is_wall_sliding = true
				wall_sliding_dir = 1
				if last_wall_jump_dir != 1:  # Only allow wall jump if last jump wasn't from same side
					can_wall_jump = true
			else:
				is_wall_sliding = false
				wall_sliding_dir = 0
		
		# Check for wall sliding on left walls
		elif character.is_on_wall() and character.get_wall_normal().rotated(-character.rotation).x > 0.7 and last_wall_jump_dir != -1:
			if horizontal_axis < 0 or (horizontal_axis == 0 and Input.is_action_pressed("right")) or wall_sliding_dir == -1:  # Pressing against the wall
				is_wall_sliding = true
				wall_sliding_dir = -1
				if last_wall_jump_dir != -1:  # Only allow wall jump if last jump wasn't from same side
					can_wall_jump = true
			else:
				is_wall_sliding = false
				wall_sliding_dir = 0
		else:
			is_wall_sliding = false
			wall_sliding_dir = 0
	
	# Check for wall jump with opposite direction input
	if not hurt and can_jump and is_wall_sliding and can_wall_jump:
		var opposite_direction_pressed = (wall_sliding_dir > 0 and Input.is_action_pressed("left")) or (wall_sliding_dir < 0 and Input.is_action_pressed("right"))
		
		# Wall jump if jump button is pressed OR if opposite direction is pressed
		if Input.is_action_just_pressed("jump") or opposite_direction_pressed:
			# Wall jump! Apply force in opposite direction of wall
			velocity.y = (GameConfig.get_value("player_movement", "player_wall_jump_vertical_force") * stats.get_jump_bonus()) * stats.get_skill_bonus()
			velocity.x = (GameConfig.get_value("player_movement", "player_wall_jump_horizontal_force") * -wall_sliding_dir * stats.get_skill_bonus()) * stats.get_jump_bonus()
			velocity = velocity.rotated(character.rotation)
			can_wall_jump = false
			last_wall_jump_dir = wall_sliding_dir
			jumped = true
			jump_timer = 0
			wall_slide_friction_timer = GameConfig.get_value("player_movement", "player_wall_slide_friction_decay_time")

	# Handle jump strength/velocity increment for regular jumps
	if not_rotating and jumped:
		var current_jump_velocity = GameConfig.get_value("player_movement", "player_jump_velocity")
		if on_sticky_block:
			current_jump_velocity = GameConfig.get_value("player_movement", "player_jump_velocity") / jump_stickiness
		velocity += Vector2(0, current_jump_velocity).rotated(character.rotation) * stats.get_jump_bonus() * (jump_timer / GameConfig.get_value("player_movement", "player_coyote_jump_time"))
		jump_timer -= 1
		if jump_timer <= 0:
			jumped = false
			jump_timer = 0
			
	# Caps velocity to reasonable limits
	velocity = _cap_velocity(velocity)
			
	# Airborne behavior
	if not_rotating and not character.is_on_floor():
		# Apply wall slide friction
		if is_wall_sliding and velocity.rotated(-character.rotation).y > 0:
			wall_slide_friction_timer -= delta
			if wall_slide_friction_timer > 0:
				var friction_factor = wall_slide_friction_timer / GameConfig.get_value("player_movement", "player_wall_slide_friction_decay_time")
				velocity.y *= 1 - (GameConfig.get_value("player_movement", "player_wall_slide_friction") * friction_factor)
			
		# Cancel jump early by not pressing jump
		if jumped and not Input.is_action_pressed("jump"):
			jumped = false
		# Fastfall; if down pressed while not on floor, fall faster. also cancels wall slide
		if !hurt and Input.is_action_pressed("down"):
			if swimming:
				velocity += Vector2(0, (GameConfig.get_value("player_movement", "player_fast_fall_velocity") / 2)).rotated(character.rotation)
			else:
				velocity += Vector2(0, GameConfig.get_value("player_movement", "player_fast_fall_velocity")).rotated(character.rotation)
			is_wall_sliding = false
			wall_sliding_dir = 0
		# Swimming up
		if !hurt and swimming and Input.is_action_pressed("up"):
			velocity += Vector2(0, -GameConfig.get_value("player_movement", "player_speed") * GameConfig.get_value("player_movement", "player_swim_up_velocity_multiplier")).rotated(character.rotation) * delta
		# Extra jump is gone after releasing jump button
		if not jumped:
			jump_timer = 0
	
	# Horizontal movement
	if not_rotating:
		if hurt or super_jump.is_locking():
			horizontal_axis = 0
		if !hurt and is_crouching:
			horizontal_axis = horizontal_axis / 2
		
		var current_speed = GameConfig.get_value("player_movement", "player_speed")
		if on_sticky_block:
			current_speed = GameConfig.get_value("player_movement", "player_speed") / speed_stickiness
		on_sticky_block = false
		
		var target_velocity = Vector2(horizontal_axis * (current_speed * speedburst_boost) * stats.get_speed_bonus(), 
			velocity.rotated(-character.rotation).y).rotated(character.rotation)
		
		accel = (0.05 + ((1.45 / 100) * stats.get_exact_accel())) * speedburst_boost
		if on_ice:
			accel *= ice_friction
		on_ice = false
		ice_friction = 0.0
		
		if horizontal_axis != 0:
			if target_velocity.length() > velocity.length():
				traction *= accel
			velocity = velocity.move_toward(target_velocity, delta * traction)
		else:
			velocity = velocity.move_toward(target_velocity, delta * traction * accel)
	
	# Add friction
	var friction = GameConfig.get_value("player_movement", "player_friction")
	if swimming:
		friction = GameConfig.get_value("player_movement", "player_swimming_friction")
	velocity = velocity * (1 - (friction * delta))
	
	# Save for next frame
	previous_velocity = velocity
	last_velocity = velocity
	
	return velocity


func _cap_velocity(velocity: Vector2) -> Vector2:
	if abs(velocity.x) > GameConfig.get_value("player_movement", "player_max_horizontal_velocity"):
		if velocity.x > 0:
			velocity.x = GameConfig.get_value("player_movement", "player_max_horizontal_velocity")
		else:
			velocity.x = GameConfig.get_value("player_movement", "player_max_horizontal_velocity") * -1
	if abs(velocity.y) > GameConfig.get_value("player_movement", "player_max_vertical_velocity"):
		if velocity.y > 0:
			velocity.y = GameConfig.get_value("player_movement", "player_max_vertical_velocity")
		else:
			velocity.y = GameConfig.get_value("player_movement", "player_max_vertical_velocity") * -1
	return velocity


func freeze(skill_bonus: float):
	frozen = true
	frozen_timer = GameConfig.get_value("player_movement", "player_frozen_duration") / skill_bonus


func hitstun(duration: float):
	if !(shielded or invincible) and !hurt:
		hitstun_duration = duration
		hitstun_timer = duration
		frozen_timer = 0
		frozen = false
		hurt = true
		if size >= 0.75 and size <= 1.25:
			Jukebox.play_sound("ouch")
		elif size < 0.75:
			Jukebox.play_sound("ouchcute")
		else:
			Jukebox.play_sound("ouchmanly")


func grant_invincibility(character: Character):
	var bonus = character.stats.get_skill_bonus()
	invincibility_timer = GameConfig.get_value("other_player_stats", "invincibility_duration") * bonus
	invincible = true
