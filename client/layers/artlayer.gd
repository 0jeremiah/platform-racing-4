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

var z_axis: int = 10
var depth: int = 10
var art_scale: float = 1.0
var art_rotation: int = 0
var alpha: float = 100
var anchor: Vector2 = Vector2(0, 0)
var layer_name: String = ""
var block_effect_settings = {}
var main_camera = null


func _process(_delta):
	main_camera = get_viewport().get_camera_2d()
	if main_camera:
		var window_size = get_viewport().get_visible_rect().size
		lines_viewpoint_container.size = window_size
		lines_viewport.size = window_size
		lines_viewpoint_container.scale = Vector2(1, 1) / main_camera.zoom
		lines_viewpoint_container.global_position = (main_camera.global_position - ((window_size / main_camera.zoom) / 2))
		lines_container.global_position = -lines_viewpoint_container.global_position * main_camera.zoom
		lines_container.scale = Vector2(1, 1) * main_camera.zoom


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	set_viewport_scale()


func get_layer_scale() -> float:
	return float(z_axis) / 10.0


func set_depth(p_depth: int) -> void:
	depth = p_depth
	set_viewport_scale()


func get_layer_depth() -> float:
	return float(depth) / 10.0


func set_anchor(p_anchor: Vector2) -> void:
	anchor = p_anchor
	set_viewport_scale()


func set_viewport_scale():
	scroll_scale = Vector2(float(depth) / 10, float(depth) / 10)
	scale = Vector2(float(z_axis) / 10, float(z_axis) / 10)
	lines_container.pivot_offset = anchor
	stamps_container.pivot_offset = anchor
	texts_container.pivot_offset = anchor
	z_index = depth - 10


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


func set_block_effect_settings(new_block_effects_settings: Dictionary):
	block_effect_settings = new_block_effects_settings


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
		if Rect2(Vector2.ZERO, child.text_box.size * child.text_scale).has_point(child.to_local(mouse_position)):
			return child
	return null


func get_stamp_draw_packed_vector2_array_for_debug(stamp: Sprite2D) -> PackedVector2Array:
	var vector4 = Vector4(0, 0, stamp.texture.get_size().x * stamp.scale.x, stamp.texture.get_size().y * stamp.scale.y)
	var packed_vector2_array = PackedVector2Array([Vector2(vector4.x, vector4.y), Vector2(vector4.z, vector4.y), Vector2(vector4.z, vector4.w), Vector2(vector4.x, vector4.w)])
	#var matrix = Rect2(abs(vector4.x) / vector4.x, abs(vector4.y) / vector4.y, abs(vector4.z) / vector4.z, abs(vector4.w) / vector4.w)
	#var rotated_matrix = Transform2D.IDENTITY.rotated(deg_to_rad(stamp.rotation_degrees)) * Rect2(abs(matrix.position.x), abs(matrix.position.y), abs(matrix.size.x), abs(matrix.size.y))
	#rotated_matrix = Vector4(rotated_matrix.position.x * matrix.position.x, rotated_matrix.position.y * matrix.position.y, rotated_matrix.size.x * matrix.size.x, rotated_matrix.size.y * matrix.size.y)
	var rotated_packed_vector2_array = PackedVector2Array()
	for vector2 in packed_vector2_array:
		rotated_packed_vector2_array.append(vector2.rotated(deg_to_rad(stamp.rotation_degrees)) + Vector2(stamp.position.x, stamp.position.y))
	return rotated_packed_vector2_array
	
