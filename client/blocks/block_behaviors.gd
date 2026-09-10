extends Node
## Movement-related tile behaviors (push, freeze, etc.)


## Push the node in a specified direction
func arrow(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if node is not PhysicsBody2D or "movement" not in node:
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
	if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0:
		push_force = vertical_force
	else:
		push_force = horizontal_force
	
	var push_velocity: Vector2
	# player is perpendicular, running across or sliding up/down
	if abs(cross) > 0.5:
		push_velocity = rotated_push_dir * push_force

	# player is standing or bumping on the block
	else:
		if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0.1:
			if node is CharacterBody2D and node.is_on_floor():
				if node.movement.up_pressed:
					push_velocity = (rotated_push_dir * push_force) * 25
				else:
					push_velocity = (rotated_push_dir * push_force) * 10
			else:
				if !node.movement.down_pressed:
					push_velocity = (rotated_push_dir * push_force) * 15
		else:
			push_velocity = rotated_push_dir * push_force
	
	if node is RigidBody2D:
		var rigid_body := node as RigidBody2D
		rigid_body.linear_velocity += push_velocity
	elif "movement" in node and "current_velocity" in node.movement:
		node.movement.current_velocity += push_velocity

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
func bounce(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" not in node or "tile_interaction" not in node:
		return
	var bounciness: float = params.get("bounciness", 0.1)
	var speed_limit: float = params.get("speed_limit", 12500.0)
	var tile_position_local := (coords * Settings.tile_size) + Settings.tile_size_half
	var tile_position_global := tile_map_layer.to_global(tile_position_local)
	if _is_moving_towards(node.position, node.movement.previous_velocity, tile_position_global):
		# bounce, invert velocity
		node.movement.current_velocity = node.movement.previous_velocity.bounce(node.tile_interaction.last_collision.get_normal())
		# add extra velocity
		node.movement.current_velocity = node.movement.current_velocity * (Vector2(1, 1) + (Vector2(bounciness, bounciness) * node.tile_interaction.last_collision.get_normal().abs()))
		# need a speed limit to keep bouncing back and forth from getting out of hand
		node.movement.current_velocity = node.movement.current_velocity.limit_length(speed_limit)
		node.velocity = node.movement.current_velocity * Vector2(node.tile_interaction.get_depth(), node.tile_interaction.get_depth())
		Jukebox.play_sound("sproing")


## Helper function to determine if a body is moving towards a block
func _is_moving_towards(body_pos: Vector2, body_velocity: Vector2, block_pos: Vector2) -> bool:
	var direction_to_block := block_pos - body_pos
	var dot_product := body_velocity.dot(direction_to_block)
	return dot_product > 0


func change_size(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "movement" not in node:
		return
	var exact = params.get("exact", false)
	var multiplier = params.get("multiplier", 1.0)
	if exact:
		node.movement.size = clamp(multiplier, 0.5, 2.0)
	else:
		node.movement.size = clamp(node.movement.size * multiplier, 0.5, 2.0)
	Jukebox.play_sound("star")


func change_stats(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "stats" not in node:
		return
	var settings = tile_map_layer.get_block(coords).settings
	if settings.can_give_stats:
		var amount = params.get("amount", 5)
		node.stats.change_stats(amount)
		if !settings.infinite_stats and settings.stat_supply - 1 <= 0:
			settings.stat_supply = 0
			settings.can_give_stats = false
			tile_map_layer.block_dict[tile_map_layer.get_block_dict_name(coords)].node.dull_out()
		elif !settings.infinite_stats:
			settings.stat_supply -= 1
		if amount != 0:
			if amount > 0:
				Jukebox.play_sound("bumphappy")
			else:
				Jukebox.play_sound("bumpsad")


func custom_stats(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "stats" not in node:
		return
	var settings = tile_map_layer.get_block(coords).settings
	if settings.can_give_stats:
		var reset = params.get("reset", false)
		var speed = params.get("speed", 50)
		var accel = params.get("accel", 50)
		var jump = params.get("jump", 50)
		var skill = params.get("skill", 50)
		node.stats.set_stats(speed, accel, jump, skill, reset)
		if !settings.infinite_stats and settings.stat_supply - 1 <= 0:
			settings.stat_supply = 0
			settings.can_give_stats = false
		elif !settings.infinite_stats:
			settings.stat_supply -= 1
		Jukebox.play_sound("star")


func crumble(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, normal: Vector2 = Vector2.ZERO):
	if !(node is RigidBody2D) and !(node is CharacterBody2D and "movement" in node):
		return
	var settings = tile_map_layer.get_block(coords).settings
	# oh shit, math
	# we want the velocity of the player, but only the % of the velocity that is moving towards the block
	# this is vector projection
	var direction = normal
	var dot = null
	if node is CharacterBody2D:
		dot = node.movement.previous_velocity.dot(direction)
	else:
		dot = node.linear_velocity.dot(direction)
	var projection = (dot / direction.length_squared()) * direction
	var magnitude_towards = projection.length()
	var damage = (magnitude_towards * params.get("damage_ratio", 0.03)) - params.get("armor", 10.0)
	var pieces = 1
	if damage > 0:
		settings.health -= damage
		if settings.health - damage <= 0:
			settings.health = 0
			TileEffects.shatter(tile_map_layer, coords, 10)
			Jukebox.play_sound("shatterblock")
		else:
			settings.health -= damage
			while damage > 0:
				damage -= 9
				pieces += 1
			TileEffects.crumble(tile_map_layer, coords, pieces)


func finish(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" not in node:
		return
	var settings = tile_map_layer.get_block(coords).settings
	var acceptable_level_types = [LevelManager.race, LevelManager.objective, LevelManager.roguelike]
	if LevelManager.level_type in acceptable_level_types and settings.can_finish and !node.movement.finished:
		settings.can_finish = false
		node.movement.maybe_finish(tile_map_layer, coords)
		Jukebox.play_sound("victory")


# Gives the player invincibility (and increases their hp if they are in a deathmatch).
func heart(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	var hp = params.get("hp", 20)
	var exact = params.get("exact", false)
	var invincibility = params.get("invincibility", true)
	if "movement" in node:
		if invincibility:
			node.movement.grant_invincibility(node)
		node.movement.give_hp(hp, exact)


# Explode the block and push away the body
func hurt(body: PhysicsBody2D, _tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	var push_strength: float = params.get("push_strength", 5000.0)
	var hitstun_duration: float = params.get("hitstun_duration", 2.5)
	var hp_sap: int = params.get("hp_sap", 20)

	# Push the body away
	var block_position: Vector2 = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	var direction: Vector2 = body.position - block_position
	var push_velocity: Vector2 = direction.normalized() * push_strength

	# Apply velocity based on body type
	if body is RigidBody2D:
		var rigid_body := body as RigidBody2D
		rigid_body.linear_velocity += push_velocity
	elif "movement" in body and "current_velocity" in body.movement:
		body.movement.current_velocity += push_velocity

	# Apply hitstun
	if "movement" in body and body.movement.has_method("hitstun"):
		body.movement.hitstun(hitstun_duration, hp_sap)


# Make the node slide (ice behavior)
func ice(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" in node and "on_ice" in node.movement:
		node.movement.on_ice = true
		node.movement.ice_friction = params.get("ice_friction", 0.2)


func item(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "item_manager" not in node:
		return
	var settings = tile_map_layer.get_block(coords).settings
	# grant an item if block is active and item_pool is not empty
	if settings.can_give_items:
		var item_array = params.get("item_array", Items.get_default_item_ids())
		var item_pool = []
		for item_id in item_array:
			if int(item_id) in LevelManager.items:
				item_pool.append(int(item_id))
		if !item_pool.is_empty():
			var item_id = item_pool[randi_range(0, item_pool.size() - 1)]
			node.item_manager.set_item_id(item_id)
		# decrease the block's item_supply if infinite_items is false and deactivate it if item_supply turns zero
		if !settings.infinite_items and settings.item_supply - 1 <= 0:
			settings.item_supply = 0
			settings.can_give_items = false
		elif !settings.infinite_items:
			settings.item_supply -= 1
		Jukebox.play_sound("star")


# Explode the block and push away the body
func mine(body: PhysicsBody2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	var push_strength: float = params.get("push_strength", 5000.0)
	var hitstun_duration: float = params.get("hitstun_duration", 2.5)
	var hp_sap: int = params.get("hp_sap", 20)
	# Shatter the tile if it's not impervious
	TileEffects.explode(tile_map_layer, coords, 10)
	Jukebox.play_sound("explosion")
	# Push the body away
	var block_position: Vector2 = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	var direction: Vector2 = body.position - block_position
	var push_velocity: Vector2 = direction.normalized() * push_strength
	# Apply velocity based on body type
	if body is RigidBody2D:
		var rigid_body := body as RigidBody2D
		rigid_body.linear_velocity += push_velocity
	elif "movement" in body and "current_velocity" in body.movement:
		body.movement.current_velocity += push_velocity
	# Apply hitstun
	if "movement" in body and body.movement.has_method("hitstun"):
		body.movement.hitstun(hitstun_duration, hp_sap)


# Pushes the block depending on where the body pushed it
func push(body: PhysicsBody2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	var tile_position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half).rotated(tile_map_layer.rotation)
	var direction = tile_position - body.position
	var block_id = tile_map_layer.get_block(coords).id
	var block_settings = tile_map_layer.get_block(coords).settings.get_edited_settings()
	
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
	var existing_block_id = ""
	while true:
		existing_block_id = tile_map_layer.get_block(target_coords).id
		if existing_block_id == block_id:
			target_coords = target_coords + Vector2i(direction)
		else:
			break
	
	# prevent moving through other blocks
	existing_block_id = tile_map_layer.get_block(target_coords).id
	if existing_block_id != "":
		return
	
	# move!
	tile_map_layer.delete_block(coords)
	tile_map_layer.add_block(target_coords, block_id, ConfigurableBlock.VISIBLE_ALT_ID, block_settings)


# Rotates the node
func rotate(body: PhysicsBody2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "gravity" not in body:
		return
		
	if !body.gravity.not_rotating():
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
func safety(body: PhysicsBody2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if body is not PhysicsBody2D or "tile_interaction" not in body:
		return

	body.position.x = body.tile_interaction.last_safe_position.x
	body.position.y = body.tile_interaction.last_safe_position.y
	
	if body is RigidBody2D:
		var rigid_body := body as RigidBody2D
		rigid_body.linear_velocity = Vector2(0, 0)
	elif "movement" in body and "current_velocity" in body.movement:
		body.movement.current_velocity = Vector2(0, 0)

	if (body.tile_interaction.last_safe_layer != null and (body.tile_interaction.last_safe_layer.players != body.get_parent())):
		body.get_parent().remove_child(body)
		body.tile_interaction.last_safe_layer.players.add_child(body)
		body.tile_interaction.set_depth(body.tile_interaction.last_safe_layer.z_axis)


# Shatters the block
func shatter(_node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	TileEffects.shatter(tile_map_layer, coords, 10)
	Jukebox.play_sound("shatterblock")


# Enables stick-block related variables in node
func stick(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "movement" not in node:
		return
	node.movement.on_sticky_block = true
	node.movement.speed_stickiness = params.get("speed_stickiness", 2.5)
	node.movement.jump_stickiness = params.get("jump_stickiness", 8.0)


# Teleports the player to the next teleport block it can find
func teleport(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if node is not Character:
		return
	var block_id = tile_map_layer.get_block(coords).id
	if !block_id or !Game.game:
		return
	var level_manager = Game.game.get_node("LevelManager")
	var map_layers = level_manager.level_layers.map_layers
	var teleport_positions = level_manager.level_layers.get_all_teleport_positions_at_block_id(block_id)
	#var is_throttled = is_teleport_throttled(str(player.name), layer_name, coords)
	#if is_throttled:
		#return
		
	var source_position = {
		"color": params.get("color", "FF7F50"),
		"tile_map_layer": tile_map_layer,
		"coords": coords,
		"map_layer_name": tile_map_layer.map_layer.name
	}
	var next_position = get_next_teleport_position(source_position, teleport_positions)
	var layer = map_layers.get_node(next_position.map_layer_name)
	var source_block_position = Vector2(coords * Settings.tile_size + Settings.tile_size_half).rotated(tile_map_layer.global_rotation)
	var next_block_position = Vector2(next_position.coords * Settings.tile_size + Settings.tile_size_half).rotated(next_position.tile_map_layer.global_rotation)
	var dist = (node.position - source_block_position).rotated(next_position.tile_map_layer.global_rotation)
	
	tile_map_layer.map_layer.players.remove_child(node)
	layer.players.add_child(node)
	node.position = next_block_position + dist
	node.tile_interaction.set_depth(layer.z_axis)
	#throttle_teleport(str(player.name), next_position.layer_name, next_position.coords)
	
	Game.game.set_current_player_layer(next_position.map_layer_name)


func get_next_teleport_position(source_position: Dictionary, positions: Array) -> Dictionary:
	# find start index
	var i = 0
	while i < len(positions):
		var position = positions[i]
		if source_position.color == position.color && source_position.coords == position.coords && source_position.map_layer_name == position.map_layer_name:
			break
		i += 1
	
	# find next teleport block with the same color
	var j = 1
	var k
	while j < len(positions) + 1:
		k = (i + j) % len(positions)
		var position = positions[k]
		if source_position.color == position.color:
			break
		j += 1
	
	# return the next match
	return positions[k]


# Teleports the player to the next teleport block it can find
func time(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "increase_time" not in node:
		return
	var settings = tile_map_layer.get_block(coords).settings
	if settings.can_give_time:
		node.emit_signal("increase_time", params.get("seconds", 10.0))
		if !settings.infinite_time and settings.time_supply - 1 <= 0:
			settings.time_supply = 0
			settings.can_give_time = false
		elif !settings.infinite_time:
			settings.time_supply -= 1
		Jukebox.play_sound("ticktock")


# Makes the block vanish for a bit, then makes it reappear
func vanish(_node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	var block_id = tile_map_layer.get_block(coords).id
	if block_id:
		#TileEffects.vanish(tile_map_layer, coords, params.get("animation_duration", 0.3), params.get("cooldown", 2.0))
		pass
