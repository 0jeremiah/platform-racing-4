extends Node

var solid_block_behaviours: SolidBlockBehaviors = SolidBlockBehaviors.new()
var non_solid_block_behaviours: NonSolidBlockBehaviors = NonSolidBlockBehaviors.new()
## Movement-related tile behaviors (push, freeze, etc.)


# Calls a solid block behaviour
func call_solid_block_behaviour(block_behaviour: String, node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, normal: Vector2 = Vector2.ZERO):
	if solid_block_behaviours.has_method(block_behaviour):
		solid_block_behaviours.call(block_behaviour, node, tile_map_layer, coords, params, normal)


# Calls a solid block behaviour
func call_non_solid_block_behaviour(block_behaviour: String, node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, normal: Vector2 = Vector2.ZERO):
	if non_solid_block_behaviours.has_method(block_behaviour):
		non_solid_block_behaviours.call(block_behaviour, node, tile_map_layer, coords, params, normal)
