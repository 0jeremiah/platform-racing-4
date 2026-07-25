extends ProjectileEffect

@onready var laser_bullet_area = $LaserBulletArea
var hit_strength: int = 1


func _ready() -> void:
	set_projectile_area(laser_bullet_area)


func hit_player(_character: Character) -> void:
	_character.velocity += Vector2(-50, 0.1)
	_character.movement.hitstun(2.5, 20)
	Jukebox.play_sound("laserhit")
	queue_free()


func hit_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, events: Array, normal: Vector2 = Vector2.ZERO) -> void:
	pass
