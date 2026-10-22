extends Node
class_name TileEffects

const SHATTER_EFFECT = preload("res://tile_effects/shatter_effect/shatter_effect.tscn")
const BUMP_EFFECT = preload("res://tile_effects/bump_effect/bump_effect.tscn")
const EXPLODE_EFFECT = preload("res://tile_effects/explode_effect/explode_effect.tscn")
const SPAWN_EFFECT = preload("res://tile_effects/spawn_effect/spawn_effect.tscn")
const VANISH_EFFECT = preload("res://tile_effects/vanish_effect/vanish_effect.tscn")
const COIN_EFFECT = preload("res://effects/coin/coin_effect.tscn")


static func shatter(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, pieces: int):
	#var block_id = tile_map_layer.get_block(coords).id
	var coins = tile_map_layer.get_block(coords).settings.coin_value
	var spawn_location = Vector2(Vector2i(coords * Settings.tile_size)).rotated(deg_to_rad(tile_map_layer.get_map_rotation()))
	crumble(tile_map_layer, coords, pieces)
	tile_map_layer.delete_block(coords)
	if Game.game and Game.game.level_manager.level_type == LevelManager.coin_fiend and coins > 0:
		for coin in coins:
			var coin_effect = COIN_EFFECT.instantiate()
			coin_effect.global_position = tile_map_layer.map_to_local(coords) + tile_map_layer.map_layer.position
			tile_map_layer.map_layer.effects.add_child(coin_effect)


static func crumble(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, pieces: int):
	var block_id = tile_map_layer.get_block(coords).id
	if !block_id:
		return
	var shatter_effect = SHATTER_EFFECT.instantiate()
	shatter_effect.position = Vector2(Vector2i(coords * Settings.tile_size)).rotated(deg_to_rad(tile_map_layer.get_map_rotation()))
	shatter_effect.rotation = tile_map_layer.map_layer.rotation
	shatter_effect.add_pieces(block_id, pieces)
	tile_map_layer.map_layer.effects.add_child(shatter_effect)


static func explode(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, pieces: int):
	var coins = tile_map_layer.get_block(coords).settings.coin_value
	var block_settings = tile_map_layer.get_block(coords).settings
	if !block_settings:
		return
	if block_settings.block_type != ConfigurableBlockSettings.IMPERVIOUS:
		shatter(tile_map_layer, coords, pieces)
	var explode_effect = EXPLODE_EFFECT.instantiate()
	explode_effect.position = Vector2(Vector2i(coords * Settings.tile_size)).rotated(deg_to_rad(tile_map_layer.get_map_rotation()))
	explode_effect.rotation = tile_map_layer.map_layer.rotation
	tile_map_layer.map_layer.effects.add_child(explode_effect)
	if Game.game and Game.game.level_manager.level_type == LevelManager.coin_fiend and coins > 0:
		for coin in coins:
			var coin_effect = COIN_EFFECT.instantiate()
			coin_effect.global_position = tile_map_layer.map_to_local(coords) + tile_map_layer.map_layer.position
			tile_map_layer.map_layer.effects.add_child(coin_effect)


static func spawn(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, block_id: String):
	if block_id not in BlockManager._blocks:
		return
	var spawn_effect = SPAWN_EFFECT.instantiate()
	#var spawn_location = BlockManager._blocks[block_id].get_center_position(tile_map_layer, coords)
	spawn_effect.position = Vector2(Vector2i(coords * Settings.tile_size)).rotated(deg_to_rad(tile_map_layer.get_map_rotation()))
	spawn_effect.rotation = tile_map_layer.map_layer.rotation
	spawn_effect.init(tile_map_layer, coords, block_id)
	tile_map_layer.map_layer.effects.add_child(spawn_effect)
