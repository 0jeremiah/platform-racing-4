extends Tile
class_name CustomStats

var custom_speed: int = default_custom_stats[0]
var custom_accel: int = default_custom_stats[1]
var custom_jump: int = default_custom_stats[2]
var custom_skill: int = default_custom_stats[3]
var custom_stats_atlas_coords: Vector2i = Vector2i(1, 33)


func init(new_custom_stats: Array = [50, 50, 50, 50]):
	matter_type = Tile.ACTIVE
	bump.push_back(set_stats)
	is_safe = true
	options.option = CustomStatsOptions.new()
	options.option.set_custom_stats(new_custom_stats)
	set_custom_stats()


func set_custom_stats():
	if !options.data.is_empty():
		custom_speed = options.data[0]
		custom_accel = options.data[1]
		custom_jump = options.data[2]
		custom_skill = options.data[3]


func set_stats(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.set_stats(custom_speed, custom_accel, custom_jump, custom_skill)
		deactivate(tile_map_layer, coords)
