extends TileOptions
class_name CustomStatsOptions

var custom_speed: int = 50
var custom_accel: int = 50
var custom_jump: int = 50
var custom_skill: int = 50


func set_custom_stats(new_custom_stats: Array):
	custom_speed = new_custom_stats[0]
	custom_accel = new_custom_stats[1]
	custom_jump = new_custom_stats[2]
	custom_skill = new_custom_stats[3]
	data = [[new_custom_stats[0], new_custom_stats[1], new_custom_stats[2], new_custom_stats[3]]]
