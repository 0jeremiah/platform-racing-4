extends Node
class_name NonSolidBlockBehaviors
## Tile behaviors for non-solid blocks (water, lightbreak, etc.)


# activates the node's lightbreak if they have it
func lightbreaker(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "lightbreak" not in node or "movement" not in node:
		return
	# avoid drawing the player into the same light again too soon
	if node.lightbreak.src_tile == coords:
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	# draw the player into the center of the light
	var global_pos = tile_map_layer.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
	var game_pos = node.get_parent().to_local(global_pos)
	var dist = game_pos - node.position
	var target_velocity = dist * 3
	node.movement.current_velocity = target_velocity
	node.light.color = block_info.settings.light_color
	node.lightbreak.direction = Vector2.ZERO
	node.lightbreak.windup += node.get_physics_process_delta_time() * 2
	node.movement.is_crouching = true
	
	# get into the lightbreak faster if you release dir keys and hit the direction you want
	if node.control_vector.length() == 0:
		node.lightbreak.input_primed = true
	if node.control_vector.length() != 0 and node.lightbreak.input_primed:
		start_lightbreak(node, coords, params.get("lightbreak_type", "firefly"))
		return
	
	# at the light timeout, either go in the direction that is being pressed or drop out
	if node.lightbreak.windup >= 1:
		if node.control_vector.length() != 0:
			start_lightbreak(node, coords, params.get("lightbreak_type", "firefly"))
		else:
			node.lightbreak.end_lightbreak()
			node.lightbreak.src_tile = coords


func start_lightbreak(node: Node2D, coords: Vector2i, lightbreak_type: String) -> void:
	node.lightbreak.direction = Vector2(node.control_vector)
	node.lightbreak.src_tile = coords
	node.lightbreak.input_primed = false
	node.lightbreak.windup = 0.1
	node.lightbreak.type = lightbreak_type


# Makes the node swim
func water(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "movement" in node:
		node.movement.swimming = true
		#node.movement.liquid_friction = params.get("liquid_friction", 2.0)
