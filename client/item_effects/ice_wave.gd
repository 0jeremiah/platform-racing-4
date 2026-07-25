extends ProjectileEffect

@onready var ice_wave_sprite = $IceWaveSprite
@onready var ice_wave_area = $IceWaveArea


func _ready() -> void:
	set_projectile_area(ice_wave_area)


func _process(delta: float):
	if life - delta > 0:
		life -= delta
	else:
		queue_free()
	if ice_wave_sprite:
		ice_wave_sprite.self_modulate = Color(1.0, 1.0, 1.0, randf_range((0.5 / 2.5) * life, (1.0 / 2.5) * life))


func hit_player(_character: Character) -> void:
	if _character.movement.frozen:
		_character.movement.freeze(_character.stats.skill)


func hit_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, events: Array, normal: Vector2 = Vector2.ZERO) -> void:
	pass
