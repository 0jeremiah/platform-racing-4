class_name MovementBehaviors
## Movement-related tile behaviors (push, freeze, etc.)

## Push the node in a specified direction
static func push_direction(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
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


## Push upward
static func push_up(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	var merged_params := params.duplicate()
	merged_params["direction_x"] = 0
	merged_params["direction_y"] = -1
	push_direction(node, tile_map_layer, coords, merged_params)


## Push downward
static func push_down(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	var merged_params := params.duplicate()
	merged_params["direction_x"] = 0
	merged_params["direction_y"] = 1
	push_direction(node, tile_map_layer, coords, merged_params)


## Push left
static func push_left(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	var merged_params := params.duplicate()
	merged_params["direction_x"] = -1
	merged_params["direction_y"] = 0
	push_direction(node, tile_map_layer, coords, merged_params)


## Push right
static func push_right(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	var merged_params := params.duplicate()
	merged_params["direction_x"] = 1
	merged_params["direction_y"] = 0
	push_direction(node, tile_map_layer, coords, merged_params)


## Make the node slide (ice behavior)
static func freeze(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	if "movement" in node:
		node.movement.on_ice = true
