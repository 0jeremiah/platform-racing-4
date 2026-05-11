extends Node
## Movement-related tile behaviors (push, freeze, etc.)


## Push the node in a specified direction
func arrow(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	print("behaviors/arrow")
	if node is not PhysicsBody2D:
		return

	var direction := Vector2(params.get("direction", {"x": 0.0, "y": 0.0}).x, params.get("direction", {"x": 0.0, "y": 0.0}).y)
	var horizontal_force: float = params.get("horizontal_force", 1250.0)
	var vertical_force: float = params.get("vertical_force", 1100.0)
	#var push_force_stand_pressed: float = params.get("push_force_stand_pressed", 3200.0)
	#var push_force_stand_idle: float = params.get("push_force_stand_idle", 1250.0)
	#var push_force_bump: float = params.get("push_force_bump", 1250.0)
	#var phantom_push_force_bump: float = params.get("phantom_push_force_bump", 400.0)
	#var phantom_push_force_bump_decay: float = params.get("phantom_push_force_bump_decay", 0.85)

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
	
	var push_velocity: Vector2
	# player is perpendicular, running across or sliding up/down
	#if abs(cross) > 0.5:
		#push_velocity += rotated_push_dir * push_force
#
	# player is standing or bumping on the block
	#else:
		#if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0.1:
			#if node is CharacterBody2D and node.is_on_floor():
				#if Input.is_action_pressed("jump"):
					#push_velocity += rotated_push_dir * push_force# * push_force_stand_pressed
				#else:
					#push_velocity += rotated_push_dir * push_force# * push_force_stand_idle
			#else:
				#if !Input.is_action_pressed("down"):
					#push_velocity += rotated_push_dir * push_force# * push_force_bump
					#if "movement" in node:
						#node.movement.phantom_velocity = rotated_push_dir * phantom_push_force_bump
						#node.movement.phantom_velocity_decay = phantom_push_force_bump_decay
		#else:
			#push_velocity += rotated_push_dir * push_force
	
	push_velocity = rotated_push_dir * push_force
	
	if node is RigidBody2D:
		var rigid_body := node as RigidBody2D
		rigid_body.linear_velocity += push_velocity
	elif "velocity" in node:
		node.velocity += push_velocity

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


## Bounce the node back
func bounce(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
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


func change_size(node: Node2D, _tile_map_layer: TileMapLayer, _coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "movement" not in node:
		return
	
	var exact = params.get("exact", false)
	var multiplier = params.get("multiplier", 1.0)
	if exact:
		node.movement.size = clamp(multiplier, 0.5, 2.0)
	else:
		node.movement.size = clamp(node.movement.size * multiplier, 0.5, 2.0)
	Jukebox.play_sound("star")


func change_stats(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "stats" not in node:
		return
	
	if block.is_active(tile_map_layer, coords):
		var amount = params.get("amount", 5)
		node.stats.change_stats(amount)
		if block.settings.stat_supply - 1 <= 0:
			block.settings.stat_supply = 0
			block.deactivate(tile_map_layer, coords)
		else:
			block.settings.stat_supply -= 1
		if amount != 0:
			if amount > 0:
				Jukebox.play_sound("bumphappy")
			else:
				Jukebox.play_sound("bumpsad")


func custom_stats(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "stats" not in node:
		return
	
	if block.is_active(tile_map_layer, coords):
		var reset = params.get("reset", false)
		var speed = params.get("speed", 50)
		var accel = params.get("accel", 50)
		var jump = params.get("jump", 50)
		var skill = params.get("skill", 50)
		node.stats.set_stats(speed, accel, jump, skill, reset)
		if block.settings.stat_supply - 1 <= 0:
			block.settings.stat_supply = 0
			block.deactivate(tile_map_layer, coords)
		else:
			block.settings.stat_supply -= 1
		Jukebox.play_sound("star")


func crumble(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, block: ConfigurableBlock, params: Dictionary, normal: Vector2 = Vector2.ZERO):
	if !(node is RigidBody2D) and !(node is CharacterBody2D):
		return
	# oh shit, math
	# we want the velocity of the player, but only the % of the velocity that is moving towards the block
	# this is vector projection
	var direction = normal
	var dot = null
	if node is CharacterBody2D:
		dot = node.movement.last_velocity.dot(direction)
	else:
		dot = node.linear_velocity.dot(direction)
	var projection = (dot / direction.length_squared()) * direction
	var magnitude_towards = projection.length()
	var damage = (magnitude_towards * params.get("damage_ratio", 0.03)) - params.get("armor", 10.0)
	var pieces = 1
	if damage > 0:
		block.settings.health -= damage
		if block.settings.health <= 0:
			TileEffects.shatter(tile_map_layer, coords, 10)
			Jukebox.play_sound("shatterblock")
		else:
			while damage > 0:
				damage -= 9
				pieces += 1
			TileEffects.crumble(tile_map_layer, coords, pieces)


func finish(node: Node2D, _tile_map_layer: TileMapLayer, _coords: Vector2i, _block: ConfigurableBlock, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" not in node:
		return

	if !node.movement.finished:
		node.movement.finished = true
		Jukebox.play_sound("victory")


# Gives the player invincibility (and increases their hp if they are in a deathmatch).
func heart(node: Node2D, _tile_map_layer: TileMapLayer, _coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "invincibility" in node:
		node.invincibility.activate()


# Explode the block and push away the body
func hurt(body: PhysicsBody2D, _tile_map_layer: TileMapLayer, coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	print("behaviors/hurt")
	var push_strength: float = params.get("push_strength", 5000.0)
	var hitstun_duration: float = params.get("hitstun_duration", 2.5)

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

	# Apply hitstun
	if body.movement.has_method("hitstun"):
		body.movement.hitstun(hitstun_duration)


# Make the node slide (ice behavior)
func ice(node: Node2D, _tile_map_layer: TileMapLayer, _coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" in node and "on_ice" in node.movement:
		node.movement.on_ice = true


func item(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "item_manager" not in node:
		return

	# grant an item if block is active and item_pool is not empty
	if block.is_active(tile_map_layer, coords):
		var item_pool = params.get("item_array", Items.get_default_item_ids())
		if !item_pool.is_empty():
			var item_id = randi_range(item_pool[0], item_pool[item_pool.size() - 1])
			node.item_manager.set_item_id(item_id)

		# decrease the block's item_supply if infinite_items is false
		if !block.settings.infinite_items:
			# deactivate this tile if the block's item_supply runs out
			if block.settings.item_supply - 1 <= 0:
				block.settings.item_supply = 0
				block.deactivate(tile_map_layer, coords)
			else:
				block.settings.item_supply -= 1

		Jukebox.play_sound("star")


# Explode the block and push away the body
func mine(body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" not in body:
		return
	print("behaviors/explode")
	var push_strength: float = params.get("push_strength", 5000.0)
	var hitstun_duration: float = params.get("hitstun_duration", 2.5)

	# Shatter the tile
	TileEffects.shatter(tile_map_layer, coords, 10)
	Jukebox.play_sound("explosion")

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
	if body.movement.has_method("hitstun"):
		body.movement.hitstun(hitstun_duration)


# Pushes the block depending on where the body pushed it
func push(body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i, _block: ConfigurableBlock, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	print("behaviors/push")
	var tile_position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half).rotated(tile_map_layer.rotation)
	var direction = tile_position - body.position
	var source_id = tile_map_layer.get_cell_source_id(coords)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	
	# force direction into 1 move
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			direction.x = 1
			direction.y = 0
		else:
			direction.x = -1
			direction.y = 0
	else:
		if direction.y > 0:
			direction.x = 0
			direction.y = 1
		else:
			direction.x = 0
			direction.y = -1
	
	# move over other move blocks, creates the illusion that they all move over one
	var target_coords = coords + Vector2i(direction)
	var existing_source_id = null
	var existing_atlas_coords = null
	while true:
		existing_source_id = tile_map_layer.get_cell_source_id(target_coords)
		existing_atlas_coords = tile_map_layer.get_cell_atlas_coords(target_coords)
		if existing_source_id == source_id and existing_atlas_coords == atlas_coords:
			target_coords = target_coords + Vector2i(direction)
		else:
			break
	
	# prevent moving through other blocks
	existing_atlas_coords = tile_map_layer.get_cell_atlas_coords(target_coords)
	if existing_atlas_coords != Vector2i(-1, -1):
		return
	
	# move!
	tile_map_layer.set_cell(coords, -1)
	tile_map_layer.set_cell(target_coords, 0, atlas_coords)


# Rotates the node
func rotate(body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i, block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	print("behaviors/rotate")

	if "gravity" not in body:
		return
		
	if block.cooldown(tile_map_layer, coords, 1):
		return

	var rotations = params.get("rotations", 1)
	var rotation_speed = params.get("rotation_speed", 0.025)
	
	body.gravity.rotation_speed = rotation_speed
	if rotations != 0:
		if rotations > 0:
			body.gravity.target_rotation += (PI / 2) * params.get("rotations", 1)
			if abs(body.gravity.target_rotation - PI) < 0.001:
				body.gravity.target_rotation = PI - 0.00001
			elif body.gravity.target_rotation > PI:
				body.gravity.target_rotation -= PI * 2
				body.gravity.rotation -= PI * 2
		else:
			body.gravity.target_rotation -= (PI / 2) * params.get("rotations", 1)
			if abs(body.gravity.target_rotation + PI) < 0.001:
				body.gravity.target_rotation = -PI + 0.00001
			elif body.gravity.target_rotation < -PI:
				body.gravity.target_rotation += PI * 2
				body.gravity.rotation += PI * 2


# Rotates the node
func safety(body: PhysicsBody2D, _tile_map_layer: TileMapLayer, _coords: Vector2i, _block: ConfigurableBlock, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	print("behaviors/safety")
	
	if body is not PhysicsBody2D or "tile_interaction" not in body:
		return

	body.position.x = body.tile_interaction.last_safe_position.x
	body.position.y = body.tile_interaction.last_safe_position.y
	
	if body is RigidBody2D:
		var rigid_body := body as RigidBody2D
		rigid_body.linear_velocity += Vector2(0, 0)
	elif "velocity" in body:
		body.velocity += Vector2(0, 0)

	if (body.tile_interaction.last_safe_layer != null and (body.tile_interaction.last_safe_layer.players != body.get_parent())):
		body.get_parent().remove_child(body)
		body.tile_interaction.last_safe_layer.players.add_child(body)
		body.tile_interaction.set_depth(body, body.tile_interaction.last_safe_layer.depth)


# Shatters the block
func shatter(_node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, _block: ConfigurableBlock, _params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	TileEffects.shatter(tile_map_layer, coords, 10)
	Jukebox.play_sound("shatterblock")


# Enables stick-block related variables in node
func stick(node: Node2D, _tile_map_layer: TileMapLayer, _coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "movement" not in node:
		return
	node.movement.on_sticky_block = true
	node.movement.speed_stickiness = params.get("speed_stickiness", 2.5)
	node.movement.jump_stickiness = params.get("jump_stickiness", 8.0)


# Makes the block vanish for a bit, then makes it reappear
#func vanish(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, _block: ConfigurableBlock, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	#var source_id = tile_map_layer.get_cell_source_id(coords)
	#var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	#
	#if atlas_coords == Vector2i(-1, -1):
		#return
	#
	#if tile_map_layer.get_cell_alternative_tile(coords) == 1:
		#return
	#
	#if vanish_effects.has(coords):
		#vanish_effects.get(coords).vanish_again()
		#return
	#
	#tile_map_layer.set_cell(coords, 0, atlas_coords, 1)
	#
	#var tile_atlas = tile_map_layer.tile_set.get_source(0).texture
	#var vanish_effect = VANISH_EFFECT.instantiate()
	#
	#tile_map_layer.add_child(vanish_effect)
	#
	#vanish_effect.init(self, tile_atlas, atlas_coords, tile_map_layer, coords)
	#vanish_effect.position = coords * Settings.tile_size
	#
	#add_to_vanish_dict(coords, vanish_effect)
