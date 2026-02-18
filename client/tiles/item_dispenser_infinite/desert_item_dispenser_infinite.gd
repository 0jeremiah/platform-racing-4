extends ItemDispenser
class_name DesertItemDispenserInfinite


func dispense_item(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	item_id = randi_range(1, 14)
	player.item_manager.set_item_id(item_id)
