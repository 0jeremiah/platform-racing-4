class_name DamageBehaviors
## Damage-related tile behaviors (explode, hurt, kill, etc.)

## Explode and damage the node
static func explode(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	var push_strength: float = params.get("push_strength", 5000.0)
	var hitstun_duration: float = params.get("hitstun_duration", 2.5)

	if "invincibility" in node and node.invincibility.is_active():
		return

	# Shatter the tile
	TileEffects.shatter(tile_map_layer, coords)

	# Push the player away
	var direction := node.position - (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map_layer.rotation)
	var push_velocity := direction.normalized() * push_strength
	node.velocity += push_velocity

	# Add explosion effect
	var EXPLODE_EFFECT: PackedScene = preload("res://tiles/mine/explode_effect.tscn")
	var effect := EXPLODE_EFFECT.instantiate()
	effect.position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	tile_map_layer.add_child(effect)

	# Apply hitstun
	if node.has_method("hitstun"):
		node.hitstun(hitstun_duration)
