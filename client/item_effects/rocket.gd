extends ProjectileEffect

@onready var rocket_area = $RocketArea


func _ready() -> void:
	set_projectile_area(rocket_area)


func hit_player(_character: Character) -> void:
	_character.velocity += Vector2(-500.0, -100.0)
	_character.movement.hitstun(2.5, 20)


func hit_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, events: Array, normal: Vector2 = Vector2.ZERO) -> void:
	pass
	queue_free()
