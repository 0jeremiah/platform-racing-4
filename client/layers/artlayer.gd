extends Parallax2D
class_name ArtLayer

@onready var lines_viewpoint_container = $LinesViewpointContainer
@onready var lines_viewport = $LinesViewpointContainer/LinesViewport
@onready var lines_container = $LinesViewpointContainer/LinesViewport/LinesContainer
@onready var lines = $LinesViewpointContainer/LinesViewport/LinesContainer/LinesHolder
@onready var stamps_container = $StampsContainer
@onready var stamps = $StampsContainer/Stamps
@onready var texts_container = $TextsContainer
@onready var texts = $TextsContainer/Texts

var z_axis: float = 10.0
var depth: float = 10.0
var art_rotation: int = 0
var alpha: float = 100
var anchor: Vector2 = Vector2(0, 0)
var layer_name: String = ""
var layer_z_index: int = 10
var block_effect_settings = {}
var main_camera = null


func _ready() -> void:
	z_as_relative = false


func _process(_delta):
	main_camera = get_viewport().get_camera_2d()
	if main_camera:
		var window_size = get_viewport().get_visible_rect().size
		lines_viewpoint_container.size = window_size
		lines_viewport.size = window_size
		lines_viewpoint_container.scale = (Vector2(1, 1) / get_layer_scale()) / main_camera.zoom
		lines_viewpoint_container.global_position = (main_camera.get_screen_center_position() - ((window_size / main_camera.zoom) / 2))
		lines_container.global_position = -(lines_viewpoint_container.global_position + (screen_offset * (get_layer_depth() - 1))) * main_camera.zoom
		lines_container.scale = (Vector2(1, 1) * get_layer_scale()) * main_camera.zoom


func set_z_axis(p_z_axis: float) -> void:
	z_axis = p_z_axis
	set_viewport_scale()


func get_layer_scale() -> float:
	return z_axis / 10.0


func set_depth(p_depth: float) -> void:
	depth = p_depth
	set_viewport_scale()


func get_layer_depth() -> float:
	return depth / 10.0


func set_anchor(p_anchor: Vector2) -> void:
	anchor = p_anchor
	set_viewport_scale()


func set_viewport_scale():
	scroll_scale = Vector2(get_layer_depth(), get_layer_depth())
	scale = Vector2(get_layer_scale(), get_layer_scale())
	lines_container.pivot_offset = anchor
	stamps_container.pivot_offset = anchor
	texts_container.pivot_offset = anchor
	z_index = layer_z_index


func set_art_rotation(new_rotation: int) -> void:
	art_rotation = new_rotation
	lines_container.rotation_degrees = art_rotation
	stamps_container.rotation_degrees = art_rotation
	texts_container.rotation_degrees = art_rotation


func set_art_alpha(new_alpha: int) -> void:
	alpha = float(new_alpha)
	lines.modulate = Color(1, 1, 1, (alpha / 100))
	stamps.modulate = Color(1, 1, 1, (alpha / 100))
	texts.modulate = Color(1, 1, 1, (alpha / 100))


func set_layer_name(new_layer_name: String) -> void:
	layer_name = new_layer_name


func set_block_effect_settings(new_block_effects_settings: Dictionary):
	block_effect_settings = new_block_effects_settings


func set_layer_z_index(p_z_index: int) -> void:
	layer_z_index = p_z_index
	set_viewport_scale()


func get_stamp_at_position(mouse_position: Vector2) -> Sprite2D:
	var stamps_array = stamps.get_children()
	stamps_array.reverse()
	for child in stamps_array:
		if Rect2(Vector2.ZERO, child.texture.get_size()).has_point(child.to_local(mouse_position)):
			return child
	return null


func get_text_at_position(mouse_position: Vector2) -> Node2D:
	var texts_array = texts.get_children()
	texts_array.reverse()
	for child in texts_array:
		if Rect2(Vector2.ZERO, child.text_box.size).has_point(child.to_local(mouse_position)):
			return child
	return null


func delete_stamp(stamp_name: String):
	if stamps.has_node(stamp_name):
		stamps.get_node(stamp_name).queue_free()


func delete_text(text_name: String):
	if texts.has_node(text_name):
		texts.get_node(text_name).queue_free()
