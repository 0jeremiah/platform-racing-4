extends BlockList
class_name SniperBlockList

var play_laser_sound: bool = false

func _init(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	super(tile_map_layer, coords)


func execute_snipe() -> void:
	if initialized:
		for block in block_array:
			var block_info = block.tile_map_layer.get_block(block.coords)
			if block_info.node != null:
				play_laser_sound = block_info.node.shoot_laser()
		if play_laser_sound:
			Jukebox.play_sound("laser")


func init_list(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	super(tile_map_layer, coords)
