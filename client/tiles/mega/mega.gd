extends Tile
class_name Mega


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(grow)
	is_safe = true


func grow(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if player.movement.size < 1:
		player.movement.size = 1
	else:
		player.movement.size = 2
