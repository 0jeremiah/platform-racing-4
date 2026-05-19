extends Node2D
class_name LevelLayers

const MAP_LAYER = preload("res://layers/maplayer.tscn")
const ART_LAYER = preload("res://layers/artlayer.tscn")
@onready var map_layers = $MapLayers
@onready var art_layers = $ArtLayers
var all_start_options = []
var start_i = 0
var map_target_layer: String = ""
var art_target_layer: String = ""
var tile_config: Tiles
var default_blocks_config: Array



func init() -> void:
	for layer in map_layers.get_children():
		if layer is MapLayer:
			layer.init(default_blocks_config)


func clear() -> void:
	for layer in map_layers.get_children():
		layer.queue_free()
	for layer in art_layers.get_children():
		layer.queue_free()
	all_start_options = []
	start_i = 0


func set_target_map_layer(layer_name: String) -> void:
	map_target_layer = layer_name


func set_target_art_layer(layer_name: String) -> void:
	art_target_layer = layer_name


func get_target_map_layer() -> String:
	if map_layers.get_child_count() == 0:
		map_target_layer = ""
		return map_target_layer
	if map_target_layer == "" || !map_layers.get_node(map_target_layer):
		map_target_layer = map_layers.get_child(0).name
	return map_target_layer

func get_target_art_layer() -> String:
	if art_layers.get_child_count() == 0:
		art_target_layer = ""
		return art_target_layer
	if art_target_layer == "" || !art_layers.get_node(art_target_layer):
		art_target_layer = art_layers.get_child(0).name
	return art_target_layer


func add_map_layer(_name: String) -> MapLayer:
	var layer = MAP_LAYER.instantiate()
	layer.name = _name
	#layer.layer = 10
	map_layers.add_child(layer)
	layer.init()
	return layer

func add_art_layer(_name: String) -> ArtLayer:
	var layer = ART_LAYER.instantiate()
	layer.name = _name
	#layer.layer = 10
	art_layers.add_child(layer)
	return layer


func remove_map_layer(_name: String) -> void:
	var layer = map_layers.get_node(_name)
	if layer:
		map_layers.remove_child(layer)
		layer.queue_free()


func remove_art_layer(_name: String) -> void:
	var layer = art_layers.get_node(_name)
	if layer:
		art_layers.remove_child(layer)
		layer.queue_free()


func calc_used_rect() -> void:
	for layer in map_layers.get_children():
		var tile_map_layer = layer.tile_map_layer
		var map_used_rect = tile_map_layer.get_used_rect()
		if Game.game:
			Game.game.set_used_rect(layer.name, map_used_rect)


func get_all_start_options():
	for level_layer in map_layers.get_children():
		var layer_start_options = level_layer.tile_map_layer.get_start_positions()
		all_start_options.append_array(layer_start_options)


func get_all_teleport_positions_at_block_id(block_id: String):
	var all_teleport_positions = []
	for level_layer in map_layers.get_children():
		var teleport_positions = level_layer.tile_map_layer.get_teleport_positions_at_block_id(block_id)
		all_teleport_positions.append_array(teleport_positions)
	return all_teleport_positions


func get_next_start_option() -> Dictionary:
	all_start_options.reverse()
	print(all_start_options)
	if len(all_start_options) > 0:
		var start_option = all_start_options[start_i]
		start_i += 1
		if start_i >= len(all_start_options):
			start_i = 0
		return start_option
	else:
		return {
			"layer_name": get_target_map_layer(),
			"coords": Vector2i(0, 0),
			"tile_map_layer": null,
		}
