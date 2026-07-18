extends Node2D
class_name LevelLayers

signal layers_changed

@onready var map_layers = $MapLayers
@onready var art_layers = $ArtLayers

const MAP_LAYER = preload("res://layers/maplayer.tscn")
const ART_LAYER = preload("res://layers/artlayer.tscn")

var all_start_options = []
var all_finish_blocks = []
var start_i = 0
var map_target_layer: String = ""
var art_target_layer: String = ""


func clear() -> void:
	for layer in map_layers.get_children():
		layer.free()
	for layer in art_layers.get_children():
		layer.free()
	all_start_options = []
	start_i = 0
	emit_signal("layers_changed")


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


func add_map_layer(layer_name: String) -> MapLayer:
	var layer = MAP_LAYER.instantiate()
	layer.name = layer_name
	layer.set_layer_name(layer_name)
	map_layers.add_child(layer)
	return layer


func add_art_layer(layer_name: String) -> ArtLayer:
	var layer = ART_LAYER.instantiate()
	layer.name = layer_name
	layer.set_layer_name(layer_name)
	art_layers.add_child(layer)
	return layer


func remove_map_layer(layer_name: String) -> void:
	var layer = map_layers.get_node(layer_name)
	if layer:
		if map_layers.get_child_count() - 1 > 0:
			if layer.get_index() > 0:
				set_target_map_layer(map_layers.get_child(layer.get_index() - 1).name)
			else:
				set_target_map_layer(map_layers.get_child(0).name)
		layer.free()
		if map_layers.get_child_count() == 0:
			set_target_map_layer(add_map_layer("Layer 1").name)


func remove_art_layer(layer_name: String) -> void:
	var layer = art_layers.get_node(layer_name)
	if layer:
		if art_layers.get_child_count() - 1 > 0:
			if layer.get_index() > 0:
				set_target_art_layer(art_layers.get_child(layer.get_index() - 1).name)
			else:
				set_target_art_layer(art_layers.get_child(0).name)
		layer.free()
		if art_layers.get_child_count() == 0:
			set_target_art_layer(add_art_layer("Layer 1").name)


func calc_used_rect() -> void:
	for layer in map_layers.get_children():
		var tile_map_layer = layer.tile_map_layer
		var map_used_rect = tile_map_layer.get_used_rect()
		if Game.game:
			Game.game.set_used_rect(layer.name, map_used_rect)


func get_total_used_rect_in_z_axis(z_axis: int) -> Rect2i:
	var total_used_vector4 = Vector4i(0, 0, 0, 0)
	var compat_used_rects = []
	for layer in map_layers.get_children():
		if layer.z_axis == z_axis:
			compat_used_rects.append(layer.tile_map_layer.get_used_rect())
	if !compat_used_rects.is_empty():
		total_used_vector4 = Vector4i(compat_used_rects[0].position.x, compat_used_rects[0].position.y, compat_used_rects[0].position.x + compat_used_rects[0].size.x, compat_used_rects[0].position.y + compat_used_rects[0].size.y)
		for used_rect in compat_used_rects:
			if used_rect.position.x < total_used_vector4.x:
				total_used_vector4.x = used_rect.position.x
			if used_rect.position.y < total_used_vector4.y:
				total_used_vector4.y = used_rect.position.y
		for used_rect in compat_used_rects:
			if used_rect.position.x + used_rect.size.x > total_used_vector4.z:
				total_used_vector4.z = used_rect.position.x + used_rect.size.x
			if used_rect.position.y + used_rect.size.y > total_used_vector4.w:
				total_used_vector4.w = used_rect.position.y + used_rect.size.y
	return Rect2i(total_used_vector4.x, total_used_vector4.y, abs(total_used_vector4.x - total_used_vector4.z), abs(total_used_vector4.y - total_used_vector4.w))


func get_all_start_options():
	all_start_options = []
	for level_layer in map_layers.get_children():
		var layer_start_options = level_layer.tile_map_layer.get_start_positions()
		all_start_options.append_array(layer_start_options)


func get_all_finish_blocks():
	all_finish_blocks = []
	for level_layer in map_layers.get_children():
		var layer_start_options = level_layer.tile_map_layer.get_finish_blocks()
		all_finish_blocks.append_array(layer_start_options)


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
			"map_layer_name": get_target_map_layer(),
			"coords": Vector2i(0, 0),
			"tile_map_layer": null,
		}


func spawn_eggs():
	for level_layer in map_layers.get_children():
		level_layer.tile_map_layer.spawn_eggs()


func _layers_loaded():
	emit_signal("layers_changed")
