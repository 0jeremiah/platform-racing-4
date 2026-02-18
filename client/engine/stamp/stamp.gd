extends Node2D

@onready var stamp_texture = $StampTexture
@onready var stamp_area = $StampArea
@onready var stamp_hitbox = $StampArea/StampHitbox
var id = ""


func set_stamp(new_id: String, new_position: Vector2, new_size: Vector2, new_rotation: int):
	id = new_id
	var stamps = Stamps.new()
	stamps.get_stamp(stamp_texture, id)
	stamp_hitbox.shape.size = stamp_texture.texture.get_size()
	position = new_position
	stamp_texture.scale = new_size
	stamp_area.scale = new_size
	stamp_texture.rotation_degrees = new_rotation
	stamp_area.rotation_degrees = new_rotation
	
