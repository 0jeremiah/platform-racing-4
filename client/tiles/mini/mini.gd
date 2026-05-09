extends Tile
class_name Mini


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shrink)
	is_safe = true


func shrink(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if player.movement.size > 1:
		player.movement.size = 1
	else:
		player.movement.size = 0.5
