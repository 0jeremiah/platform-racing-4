extends Node
class_name SolidBlockBehaviors
## Movement-related tile behaviors (push, freeze, etc.)


# Makes the block appear for a bit, then makes it vanish again
func appear(_node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	var block_info = tile_map_layer.get_block(coords)
	if block_info.node != null:
		block_info.node.appear(params.get("fade_duration", 0.3), params.get("fade_cooldown", 2.0), params.get("revert", true))


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
				# remove from last_bumped_block so we can keep bumping this block
				#var block_info = {
					#"tile_map_layer": tile_map_layer,
					#"coords": coords,
					#"block_id": tile_map_layer.get_block(coords).id
					#}
				#if "movement" in node and block_info == node.movement.last_bumped_block:
					#node.movement.last_bumped_block = {}
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
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	if block_info.settings.can_give_stats:
		var amount = params.get("amount", 5)
		node.stats.change_stats(amount)
		if !block_info.settings.infinite_stats and block_info.settings.stat_supply - 1 <= 0:
			block_info.settings.stat_supply = 0
			block_info.settings.can_give_stats = false
			if block_info.node != null:
				block_info.node.dull_out()
		elif !block_info.settings.infinite_stats:
			block_info.settings.stat_supply -= 1
		if amount != 0:
			if amount > 0:
				Jukebox.play_sound("bumphappy")
			else:
				Jukebox.play_sound("bumpsad")


func custom_stats(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "stats" not in node:
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	if block_info.settings.can_give_stats:
		var reset = params.get("reset", false)
		var speed = params.get("speed", 50)
		var accel = params.get("accel", 50)
		var jump = params.get("jump", 50)
		var skill = params.get("skill", 50)
		node.stats.set_stats(speed, accel, jump, skill, reset)
		if !block_info.settings.infinite_stats and block_info.settings.stat_supply - 1 <= 0:
			block_info.settings.stat_supply = 0
			block_info.settings.can_give_stats = false
			if block_info.node != null:
				block_info.node.dull_out()
		elif !block_info.settings.infinite_stats:
			block_info.settings.stat_supply -= 1
		Jukebox.play_sound("star")


func crumble(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, normal: Vector2 = Vector2.ZERO):
	if !(node is RigidBody2D) and !(node is CharacterBody2D and "movement" in node):
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
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
		block_info.settings.health -= damage
		if block_info.settings.health - damage <= 0:
			block_info.settings.health = 0
			TileEffects.shatter(tile_map_layer, coords, 10)
			Jukebox.play_sound("shatterblock")
		else:
			block_info.settings.health -= damage
			while damage > 0:
				damage -= 9
				pieces += 1
			TileEffects.crumble(tile_map_layer, coords, pieces)


func finish(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" not in node:
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	var acceptable_level_types = [LevelManager.race, LevelManager.objective, LevelManager.roguelike]
	if Game.game.level_manager.level_type in acceptable_level_types and block_info.settings.can_finish and !node.movement.finished:
		block_info.settings.can_finish = false
		node.movement.maybe_finish(tile_map_layer, coords)
		Jukebox.play_sound("victory")


# Gives the player invincibility (and increases their hp if they are in a deathmatch).
func heart(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	var hp = params.get("hp", 20)
	var exact = params.get("exact", false)
	var invincibility = params.get("invincibility", true)
	if "movement" in node:
		if invincibility:
			node.movement.grant_invincibility(node)
		node.movement.give_hp(hp, exact)
		var block_info = tile_map_layer.get_block(coords)
		if block_info.node != null:
			block_info.node.dull_out()


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
		body.movement.hitstun(body, hitstun_duration, hp_sap)


# Make the node slide (ice behavior)
func ice(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "movement" in node and "on_ice" in node.movement:
		node.movement.on_ice = true
		node.movement.ice_friction = params.get("ice_friction", 0.2)


func item(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "item_manager" not in node:
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	# grant an item if block is active and item_pool is not empty
	if block_info.settings.can_give_items:
		var item_array = params.get("item_array", Items.get_default_item_ids())
		var item_pool = []
		for item_id in item_array:
			if int(item_id) in Game.game.level_manager.items:
				item_pool.append(int(item_id))
		if !item_pool.is_empty():
			var item_id = item_pool[randi_range(0, item_pool.size() - 1)]
			node.item_manager.set_item_id(item_id)
		# decrease the block's item_supply if infinite_items is false and deactivate it if item_supply turns zero
		if !block_info.settings.infinite_items and block_info.settings.item_supply - 1 <= 0:
			block_info.settings.item_supply = 0
			block_info.settings.can_give_items = false
			if block_info.node != null:
				block_info.node.dull_out()
		elif !block_info.settings.infinite_items:
			block_info.settings.item_supply -= 1
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
		body.movement.hitstun(body, hitstun_duration, hp_sap)


# Pushes the block depending on where the body pushed it
func push(_body: PhysicsBody2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, normal: Vector2 = Vector2.ZERO) -> void:
	var block_info = tile_map_layer.get_block(coords)
	if block_info.id == "" or block_info.node == null:
		return
	if normal == Vector2.DOWN:
		block_info.node.move("top", false)
	elif normal == Vector2.UP:
		block_info.node.move("bottom", false)
	elif normal == Vector2.LEFT:
		block_info.node.move("right", false)
	elif normal == Vector2.RIGHT:
		block_info.node.move("left", false)


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
	node.movement.jump_stickiness = params.get("jump_stickiness", 10.0)


# Teleports the player to the next teleport block it can find
func teleport(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, normal: Vector2 = Vector2.ZERO):
	if node is not Character:
		return
	var block_info = tile_map_layer.get_block(coords)
	if !Game.game or block_info.id == "" or block_info.settings == null or block_info.node == null or block_info.node.teleport_throttle_timer > 0.0:
		return
	var level_manager = Game.game.level_manager
	var current_teleport_block = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
	var current_block_id = block_info.id
	var current_block_teleport_color = block_info.settings.teleport_color
	var next_teleport_block = {}
	var next_teleport_block_info = {"id": "", "settings": null, "node": null}
	var teleport_position = Vector2(current_teleport_block.coords * Settings.tile_size + Settings.tile_size_half) * (Vector2(Settings.tile_size) * normal)
	var target_tile_map_layer = tile_map_layer
	if level_manager.teleport_blocks.has(current_block_id) and level_manager.teleport_blocks[current_block_id].has(current_block_teleport_color):
		var current_teleport_block_index = level_manager.teleport_blocks[current_block_id][current_block_teleport_color].find(current_teleport_block)
		if current_teleport_block_index > -1:
			if current_teleport_block_index < level_manager.teleport_blocks[current_block_id][current_block_teleport_color].size() - 1:
				next_teleport_block = level_manager.teleport_blocks[current_block_id][current_block_teleport_color][current_teleport_block_index + 1]
			else:
				next_teleport_block = level_manager.teleport_blocks[current_block_id][current_block_teleport_color][0]
	if !next_teleport_block.is_empty():
		next_teleport_block_info = next_teleport_block.tile_map_layer.get_block(next_teleport_block.coords)
		target_tile_map_layer = next_teleport_block.tile_map_layer
	block_info.node.throttle_teleport()
	if next_teleport_block_info.node != null:
		next_teleport_block_info.node.throttle_teleport()
	if next_teleport_block:
		var next_block_position = Vector2(next_teleport_block.coords * Settings.tile_size + Settings.tile_size_half).rotated(next_teleport_block.tile_map_layer.global_rotation)
		teleport_position = next_block_position + (Vector2(Settings.tile_size) * normal)
	tile_map_layer.map_layer.players.remove_child(node)
	target_tile_map_layer.map_layer.players.add_child(node)
	node.position = teleport_position
	node.movement.current_velocity = Vector2(0.0, 0.0)
	node.tile_interaction.set_depth(target_tile_map_layer.map_layer.z_axis)
	Game.game.set_current_player_layer(target_tile_map_layer.map_layer.name)


# Gives the node extra seconds in the level
func time(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if !Game.game or Game.game.player_manager.get_character() != node:
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	if block_info.settings.can_give_time:
		Game.game.game_timer.inc_timer(params.get("seconds", 10.0))
		if !block_info.settings.infinite_time and block_info.settings.time_supply - 1 <= 0:
			block_info.settings.time_supply = 0
			block_info.settings.can_give_time = false
			if block_info.node != null:
				block_info.node.dull_out()
		elif !block_info.settings.infinite_time:
			block_info.settings.time_supply -= 1
		Jukebox.play_sound("ticktock")


# Makes the block vanish for a bit, then makes it reappear
func vanish(_node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	var block_info = tile_map_layer.get_block(coords)
	if block_info.node != null:
		block_info.node.vanish(params.get("fade_duration", 0.3), params.get("fade_cooldown", 2.0), params.get("revert", true))
