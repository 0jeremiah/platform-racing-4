extends RigidBody2D
class_name CoinEffect

@onready var coin_graphic = $CoinGraphic

var life = 8.333
var rotate_velocity = 0.0


func _ready() -> void:
	var solid_layer = Helpers.to_bitmask_32((10 * 2) - 1)
	collision_layer = solid_layer
	collision_mask = solid_layer
	linear_velocity.x = randf_range(-200.0, 200.0)
	linear_velocity.y = randf_range(-200.0, 0.0)
	rotate_velocity = linear_velocity.x / 10
	coin_graphic.rotation_degrees = randf_range(0.0, 360.0)
	body_shape_entered.connect(_touch_wall)


func _process(delta: float):
	coin_graphic.rotation_degrees += rotate_velocity
	if life - delta > 0:
		life -= delta
		if life < 3.030:
			modulate.a = life / 3.030
		else:
			modulate.a = 1
	else:
		life = 0
		queue_free()


func _touch_wall(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int):
	rotate_velocity = linear_velocity.x / 10


func _is_touching_player(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int):
	if body is Character:
		queue_free()
