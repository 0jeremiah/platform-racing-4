extends ParallaxBackground
class_name ArtLayer

@onready var stamps = $Stamps
@onready var lines = $Lines
@onready var texts = $Texts

var z_axis: int = 10
var depth: int = 10
var art_scale: float = 1.0
var art_rotation: int = 0
var alpha: float = 100
var layer_name: String = ""


#func _process(delta):
	#var camera: Camera2D = get_viewport().get_camera_2d()
	#if camera:
		#parent.position = camera.get_screen_center_position()
		#parent.scale = Vector2.ONE / camera.zoom


func init(tiles: Tiles) -> void:
	set_z_axis(z_axis)
	set_depth(depth)
	set_art_rotation(art_rotation)
	set_art_alpha(alpha)


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	set_viewport_scale()


func set_depth(p_depth: int) -> void:
	depth = p_depth
	layer = depth
	set_viewport_scale()


func set_viewport_scale():
	scroll_base_scale = Vector2(float(depth) / 10, float(depth) / 10)
	follow_viewport_scale = z_axis / 10


func set_art_rotation(new_rotation: int) -> void:
	art_rotation = new_rotation
	stamps.rotation_degrees = art_rotation
	lines.rotation_degrees = art_rotation
	texts.rotation_degrees = art_rotation


func set_art_alpha(new_alpha: int) -> void:
	alpha = float(new_alpha)
	stamps.modulate = Color(1, 1, 1, (alpha / 100))
	lines.modulate = Color(1, 1, 1, (alpha / 100))
	texts.modulate = Color(1, 1, 1, (alpha / 100))


func get_stamp_at_position(mouse_position: Vector2) -> Sprite2D:
	var stamps_array = stamps.get_children()
	stamps_array.reverse()
	var selected_stamp = null
	for child in stamps_array:
		var stamp_rect = get_click_area(Rect2(child.position.x - ((child.texture.get_size().x / 2) * child.stamp_scale.x), child.position.y - ((child.texture.get_size().y / 2) * child.stamp_scale.y), child.position.x + ((child.texture.get_size().x / 2) * child.stamp_scale.x), child.position.y + ((child.texture.get_size().y / 2) * child.stamp_scale.y)), float(child.stamp_rotation), child.stamp_scale)
		if mouse_position.x >= stamp_rect.position.x and mouse_position.y >= stamp_rect.position.y and mouse_position.x <= stamp_rect.size.x and mouse_position.y <= stamp_rect.size.y:
			selected_stamp = child
			break
	return selected_stamp


func get_text_at_position(mouse_position: Vector2) -> Control:
	var texts_array = texts.get_children()
	texts_array.reverse()
	var selected_text = null
	for child in texts_array:
		var text_rect = get_click_area(Rect2(child.position.x, child.position.y, child.position.x + child.size.x, child.position.y + child.size.y), float(child.text_rotation), child.text_scale)
		if mouse_position.x >= text_rect.position.x and mouse_position.y >= text_rect.position.y and mouse_position.x <= text_rect.size.x and mouse_position.y <= text_rect.size.y:
			selected_text = child
			break
	return selected_text


func get_click_area(new_rect: Rect2, new_rotation: float = 0.0, new_scale: Vector2 = Vector2(1, 1)) -> Rect2:
	var rect = Rect2(new_rect.position.x, new_rect.position.y, new_rect.size.x, new_rect.size.y)
	var matrix = Rect2(abs(rect.position.x) / rect.position.x, abs(rect.position.y) / rect.position.y, abs(rect.size.x) / rect.size.x, abs(rect.size.y) / rect.size.y)
	var rotated_matrix = Transform2D.IDENTITY.rotated(deg_to_rad(new_rotation)) * Rect2(abs(matrix.position.x), abs(matrix.position.y), abs(matrix.size.x), abs(matrix.size.y))
	rotated_matrix = Rect2(rotated_matrix.position.x * matrix.position.x, rotated_matrix.position.y * matrix.position.y, rotated_matrix.size.x * matrix.size.x, rotated_matrix.size.y * matrix.size.y)
	var rotated_rect = Transform2D.IDENTITY.rotated(deg_to_rad(new_rotation)) * Rect2(abs(rect.position.x), abs(rect.position.y), abs(rect.size.x), abs(rect.size.y))
	rotated_rect = Rect2(rotated_rect.position.x * matrix.position.x, rotated_rect.position.y * matrix.position.y, rotated_rect.size.x * matrix.size.x, rotated_rect.size.y * matrix.size.y)
	return rotated_rect
