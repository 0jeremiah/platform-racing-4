extends Node
## Movement-related tile behaviors (push, freeze, etc.)

## Push the node in a specified direction
func push_direction(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	if "velocity" not in node:
		return

	var direction := Vector2(params.get("direction_x", 0), params.get("direction_y", 0))
	var horizontal_force: float = params.get("horizontal_force", 125.0)
	var vertical_force: float = params.get("vertical_force", 110.0)
	var push_force_stand_pressed: float = params.get("push_force_stand_pressed", 3200.0)
	var push_force_stand_idle: float = params.get("push_force_stand_idle", 1250.0)
	var push_force_bump: float = params.get("push_force_bump", 1250.0)
	var phantom_push_force_bump: float = params.get("phantom_push_force_bump", 400.0)
	var phantom_push_force_bump_decay: float = params.get("phantom_push_force_bump_decay", 0.85)

	var rotated_push_dir := direction.rotated(tile_map_layer.global_rotation)
	var target_global_position := tile_map_layer.to_global((coords * 128) + Vector2i(64, 64))
	var player_global_position := node.to_global(Vector2(0, -100))
	var player_dir := (player_global_position - target_global_position).normalized()
	var cross := rotated_push_dir.cross(player_dir)

	var push_force: float
	# changes "push_force" depending on whether player is on the horizontal or vertical side
	if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0.1:
		push_force = vertical_force
	else:
		push_force = horizontal_force

	# player is perpendicular, running across or sliding up/down
	if abs(cross) > 0.5:
		node.velocity += rotated_push_dir * push_force

	# player is standing or bumping on the block
	else:
		if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0.1:
			if node.is_on_floor():
				if Input.is_action_pressed("jump"):
					node.velocity += rotated_push_dir * push_force_stand_pressed
				else:
					node.velocity += rotated_push_dir * push_force_stand_idle
			else:
				if !Input.is_action_pressed("down"):
					node.velocity += rotated_push_dir * push_force_bump
					if "movement" in node:
						node.movement.phantom_velocity = rotated_push_dir * phantom_push_force_bump
						node.movement.phantom_velocity_decay = phantom_push_force_bump_decay
		else:
			node.velocity += rotated_push_dir * push_force

	# add effect
	if params.get("show_effect", true):
		var ArrowActivateEffect: PackedScene = preload("res://tile_effects/arrow_activate_effect/arrow_activate_effect.tscn")
		var effect_name := str(coords.x) + "-" + str(coords.y) + "-arrow"
		if tile_map_layer.has_node(effect_name):
			var existing_effect := tile_map_layer.get_node(effect_name)
			existing_effect.get_node("AnimationPlayer").seek(0)
			return
		var effect := ArrowActivateEffect.instantiate()
		effect.position = (coords * Settings.tile_size) + Settings.tile_size_half
		effect.rotation = direction.rotated(-PI / 2).angle()
		effect.name = effect_name
		tile_map_layer.add_child(effect)


## Make the node slide (ice behavior)
func freeze(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	if "movement" in node:
		node.movement.on_ice = true


## Explode the block and push away the body
func explode(body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	print("behaviors/explode")
	var push_strength: float = params.get("push_strength", 5000.0)
	var hitstun_duration: float = params.get("hitstun_duration", 2.5)

	# Shatter the tile
	TileEffects.shatter(tile_map_layer, coords, 10)

	# Push the body away
	var block_position: Vector2 = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	var direction: Vector2 = body.position - block_position
	var push_velocity: Vector2 = direction.normalized() * push_strength

	# Apply velocity based on body type
	if body is RigidBody2D:
		var rigid_body := body as RigidBody2D
		rigid_body.linear_velocity += push_velocity
	elif "velocity" in body:
		body.velocity += push_velocity

	# Add explosion effect
	var EXPLODE_EFFECT: PackedScene = preload("res://tiles/mine/explode_effect.tscn")
	var effect := EXPLODE_EFFECT.instantiate()
	effect.position = block_position
	tile_map_layer.add_child(effect)

	# Apply hitstun
	if body.has_method("hitstun"):
		body.hitstun(hitstun_duration)


## Bounce the node back
func bounce(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	var bounciness: float = params.get("bounciness", 0.1)
	var speed_limit: float = params.get("speed_limit", 12500.0)

	if "movement" not in node or "tile_interaction" not in node:
		return

	var tile_position_local := (coords * Settings.tile_size) + Settings.tile_size_half
	var tile_position_global := tile_map_layer.to_global(tile_position_local)

	if _is_moving_towards(node.position, node.movement.previous_velocity, tile_position_global):
		# bounce, invert velocity
		node.velocity = node.movement.previous_velocity.bounce(node.tile_interaction.last_collision.get_normal())

		# add extra velocity
		node.velocity = node.velocity * (Vector2(1, 1) + (Vector2(bounciness, bounciness) * node.tile_interaction.last_collision.get_normal().abs()))

		# need a speed limit to keep bouncing back and forth from getting out of hand
		node.velocity = node.velocity.limit_length(speed_limit)


## Helper function to determine if a body is moving towards a block
func _is_moving_towards(body_pos: Vector2, body_velocity: Vector2, block_pos: Vector2) -> bool:
	var direction_to_block := block_pos - body_pos
	var dot_product := body_velocity.dot(direction_to_block)
	return dot_product > 0
