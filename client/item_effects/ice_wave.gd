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
	if projectile is CharacterBody2D:
		projectile.move_and_slide()
	if ice_wave_sprite:
		ice_wave_sprite.self_modulate = Color(1.0, 1.0, 1.0, randf_range((0.5 / 2.5) * life, (1.0 / 2.5) * life))


func hit_player(_character: Character) -> void:
	if !_character.movement.frozen:
		_character.movement.freeze(_character.stats.get_skill_bonus())


func hit_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _events: Array, _normal: Vector2 = Vector2.ZERO) -> void:
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings != null and block_info.node != null and block_info.settings.matter_type != ConfigurableBlockSettings.GAS and !block_info.node.frozen:
		block_info.node.freeze()
