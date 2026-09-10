extends Node
class_name TileEffects

const SHATTER_EFFECT = preload("res://tile_effects/shatter_effect/shatter_effect.tscn")
const BUMP_EFFECT = preload("res://tile_effects/bump_effect/bump_effect.tscn")
const EXPLODE_EFFECT = preload("res://tile_effects/explode_effect/explode_effect.tscn")
const SPAWN_EFFECT = preload("res://tile_effects/spawn_effect/spawn_effect.tscn")
const VANISH_EFFECT = preload("res://tile_effects/vanish_effect/vanish_effect.tscn")
const COIN_EFFECT = preload("res://effects/coin/coin_effect.tscn")


static func shatter(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, pieces: int):
	var block_id = tile_map_layer.get_block(coords).id
	var coins = tile_map_layer.get_block(coords).settings.coin_value
	var spawn_location = BlockManager._blocks[block_id].get_center_position(tile_map_layer, coords)
	crumble(tile_map_layer, coords, pieces)
	tile_map_layer.delete_block(coords)
	if LevelManager.level_type == LevelManager.coin_fiend and coins > 0:
		for coin in coins:
			var coin_effect = COIN_EFFECT.instantiate()
			coin_effect.global_position = spawn_location
			tile_map_layer.map_layer.effects.add_child(coin_effect)


static func crumble(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, pieces: int):
	var block_id = tile_map_layer.get_block(coords).id
	if !block_id:
		return
	var shatter_effect = SHATTER_EFFECT.instantiate()
	shatter_effect.position = coords * Settings.tile_size
	shatter_effect.add_pieces(block_id, pieces)
	tile_map_layer.map_layer.effects.add_child(shatter_effect)


static func explode(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, pieces: int):
	var block_settings = tile_map_layer.get_block(coords).settings
	if !block_settings:
		return
	if block_settings.block_type != ConfigurableBlockSettings.IMPERVIOUS:
		shatter(tile_map_layer, coords, pieces)
	var explode_effect = EXPLODE_EFFECT.instantiate()
	explode_effect.position = coords * Settings.tile_size
	tile_map_layer.map_layer.effects.add_child(explode_effect)


static func bump(player: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	#var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	#if atlas_coords == Vector2i(-1, -1):
		#return
	#
	#var effect_name = str(coords.x) + "-" + str(coords.y) + "-bump"
	#if tile_map_layer.map_layer.effects.has_node(effect_name):
		#var effect = tile_map_layer.map_layer.effects.get_node(effect_name)
		#var animation_player = effect.get_node("AnimationPlayer") as AnimationPlayer
		#animation_player.seek(0.1)
		#return
	#
	#var alt_id: int = tile_map_layer.get_cell_alternative_tile(coords)
	#if alt_id == ConfigurableBlock.INVISIBLE_ALT_ID:
		#return
	#
	#var bump_effect = BUMP_EFFECT.instantiate()
	#bump_effect.name = effect_name
	#tile_map_layer.map_layer.effects.add_child(bump_effect)
	#bump_effect.position = coords * Settings.tile_size + Settings.tile_size_half
	#bump_effect.rotation = player.rotation - tile_map_layer.global_rotation
	#bump_effect.set_tile(tile_map_layer, coords, -bump_effect.rotation)
	#
	#if alt_id == ConfigurableBlock.DEACTIVATED_ALT_ID:
		#tile_map_layer.set_cell(coords, 0, atlas_coords, ConfigurableBlock.INVISIBLE_DEACTIVATED_ALT_ID)
	#else:
		#tile_map_layer.set_cell(coords, 0, atlas_coords, ConfigurableBlock.INVISIBLE_ALT_ID)
	pass


static func spawn(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, block_id: String):
	if block_id not in BlockManager._blocks:
		return
	var spawn_effect = SPAWN_EFFECT.instantiate()
	var spawn_location = BlockManager._blocks[block_id].get_center_position(tile_map_layer, coords)
	spawn_effect.position = spawn_location
	spawn_effect.init(tile_map_layer, coords, block_id)
	tile_map_layer.map_layer.effects.add_child(spawn_effect)


static func vanish(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, animation_duration: float, cooldown: float):
	#var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	#if atlas_coords == Vector2i(-1, -1):
		#return
	#var vanish_effect = VANISH_EFFECT.instantiate()
	#tile_map_layer.map_layer.effects.add_child(vanish_effect)
	#vanish_effect.init(tile_map_layer, coords, animation_duration, cooldown)
	#vanish_effect.position = coords * Settings.tile_size
	pass
