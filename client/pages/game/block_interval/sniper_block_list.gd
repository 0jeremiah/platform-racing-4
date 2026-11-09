extends BlockList
class_name SniperBlockList

var play_laser_sound: bool = false

func _init(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	super(tile_map_layer, coords)


func execute_snipe() -> void:
	if initialized:
		for block in block_array:
			shoot_from_block(block.tile_map_layer, block.coords)
		if play_laser_sound:
			Jukebox.play_sound("laser")


func shoot_from_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings != null and block_info.node != null:
		if block_info.settings.top.type == ConfigurableBlockSideSettings.SNIPER or block_info.settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
			tile_map_layer.shoot_laser(block_info.node.position, deg_to_rad(270.0), false, block_info.node)
			play_laser_sound = true
		if block_info.settings.bottom.type == ConfigurableBlockSideSettings.SNIPER or block_info.settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
			tile_map_layer.shoot_laser(block_info.node.position, deg_to_rad(90.0), false, block_info.node)
			play_laser_sound = true
		if block_info.settings.left.type == ConfigurableBlockSideSettings.SNIPER or block_info.settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
			tile_map_layer.shoot_laser(block_info.node.position, deg_to_rad(180.0), false, block_info.node)
			play_laser_sound = true
		if block_info.settings.right.type == ConfigurableBlockSideSettings.SNIPER or block_info.settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
			tile_map_layer.shoot_laser(block_info.node.position, 0.0, false, block_info.node)
			play_laser_sound = true


func init_list(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	super(tile_map_layer, coords)
