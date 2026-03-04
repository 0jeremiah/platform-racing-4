extends Sprite2D

var stamp_id = ""
var stamp_position: Vector2 = Vector2(0, 0)
var stamp_scale: Vector2 = Vector2(0, 0)
var stamp_rotation: int = 0
var size_multiplier: float = 2


func set_stamp_properties(stamp_dictionary: Dictionary):
	if stamp_dictionary.has("id"):
		set_stamp_id(stamp_dictionary.id)
	if stamp_dictionary.has("position"):
		set_stamp_position(Vector2(stamp_dictionary.position.x, stamp_dictionary.position.y))
	if stamp_dictionary.has("scale"):
		set_stamp_scale(Vector2(stamp_dictionary.scale.x, stamp_dictionary.scale.y))
	if stamp_dictionary.has("rotation"):
		set_stamp_rotation(stamp_dictionary.rotation)


func set_stamp_id(new_stamp_id: String):
	stamp_id = new_stamp_id
	var stamps = Stamps.new()
	stamps.get_stamp(self, stamp_id)


func set_stamp_position(new_stamp_position: Vector2):
	stamp_position = new_stamp_position
	position = stamp_position


func set_stamp_scale(new_stamp_scale: Vector2):
	stamp_scale = new_stamp_scale
	scale = stamp_scale * size_multiplier


func set_stamp_rotation(new_stamp_rotation: int):
	stamp_rotation = new_stamp_rotation
	rotation_degrees = stamp_rotation
