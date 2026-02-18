extends Tile
class_name Happy

var increment: int = default_stat_increment
var happy_atlas_coords: Vector2i = Vector2i(6, 32)


func init(new_amount: int = 5):
	matter_type = Tile.ACTIVE
	bump.push_back(happy)
	is_safe = true
	options.option = StatsOptions.new()
	options.option.set_amount(new_amount)
	set_stats()


func set_stats():
	if !options.data.is_empty():
		increment = options.data[0]


func happy(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.inc_all(increment)
		Jukebox.play_sound("bumphappy")
		deactivate(tile_map_layer, coords)
