extends Node2D
class_name BlockLayers

const ART_LAYER = preload("res://layers/artlayer.tscn")
@onready var art_layers = $ArtLayers
var art_target_layer: String = ""


func clear() -> void:
	for layer in art_layers.get_children():
		layer.queue_free()


func set_target_art_layer(layer_name: String) -> void:
	art_target_layer = layer_name


func get_target_art_layer() -> String:
	if art_layers.get_child_count() == 0:
		art_target_layer = ""
		return art_target_layer
	if art_target_layer == "" || !art_layers.get_node(art_target_layer):
		art_target_layer = art_layers.get_child(0).name
	return art_target_layer


func add_art_layer(name: String) -> ArtLayer:
	var layer = ART_LAYER.instantiate()
	layer.name = name
	layer.layer = 10
	art_layers.add_child(layer)
	return layer


func remove_art_layer(name: String) -> void:
	var layer = art_layers.get_node(name)
	if layer:
		art_layers.remove_child(layer)
		layer.queue_free()
