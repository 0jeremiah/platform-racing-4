extends RealEffect
class_name CoinEffect

@onready var coin_graphic = $CoinGraphic
@onready var coin_area = $CoinArea

var life = 8.333
var rotate_velocity = 0.0


func _ready() -> void:
	effect = self
	collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.solid_layer_id)
	collision_mask = BlockManager._tile_set.get_physics_layer_collision_mask(BlockManager.solid_layer_id)
	var character = Game.game.player_manager.get_character() if Game.game else null
	if character:
		add_collision_exception_with(character)
	set_effect_area(coin_area)
	effect.linear_velocity.x = randf_range(-200.0, 200.0)
	effect.linear_velocity.y = randf_range(-200.0, 0.0)
	rotate_velocity = effect.linear_velocity.x / 10
	coin_graphic.rotation_degrees = randf_range(0.0, 360.0)
	effect.body_shape_entered.connect(_touch_wall)


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


func _touch_wall(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int):
	rotate_velocity = effect.linear_velocity.x / 10


func touch_local_player(character: Character):
	#character.movement.award_coin()
	queue_free()
