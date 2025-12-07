class_name PhysicsBehaviors
## Physics-related tile behaviors (bounce, gravity, etc.)

## Bounce the node back
static func bounce(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
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
static func _is_moving_towards(body_pos: Vector2, body_velocity: Vector2, block_pos: Vector2) -> bool:
	var direction_to_block := block_pos - body_pos
	var dot_product := body_velocity.dot(direction_to_block)
	return dot_product > 0
