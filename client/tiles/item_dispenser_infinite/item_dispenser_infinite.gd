extends ItemDispenser
class_name ItemDispenserInfinite


func dispense_item(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	item_id = randi_range(1, 14)
	player.item_manager.set_item_id(item_id)
	Jukebox.play_sound("star")
