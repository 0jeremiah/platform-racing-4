extends Tile
class_name Sad

var decrement: int = default_stat_increment
var sad_atlas_coords: Vector2i = Vector2i(7, 32)


func init(new_amount: int = 5):
	matter_type = Tile.ACTIVE
	bump.push_back(sad)
	is_safe = true
	options.option = StatsOptions.new()
	options.option.set_amount(new_amount)
	set_stats()


func set_stats():
	if !options.data.is_empty():
		decrement = options.data[0]


func sad(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.change_stats(decrement)
		Jukebox.play_sound("bumpsad")
		deactivate(tile_map_layer, coords)
