extends Node2D
class_name BlockLayers

signal layers_changed

@onready var art_layers = $ArtLayers

const ART_LAYER = preload("res://layers/artlayer.tscn")

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


func add_art_layer(layer_name: String) -> ArtLayer:
	var layer = ART_LAYER.instantiate()
	layer.name = layer_name
	art_layers.add_child(layer)
	emit_signal("layers_changed")
	return layer


func remove_art_layer(layer_namename: String) -> void:
	var layer = art_layers.get_node(layer_namename)
	if layer:
		art_layers.remove_child(layer)
		layer.queue_free()
		emit_signal("layers_changed")
