extends ProjectileEffect

@onready var sword_area = $SwordArea
@onready var sword_hitbox = $SwordArea/SwordHitbox
@onready var animations: AnimationPlayer = $Animations
var sword_hitbox_range = Vector2(37.0, 65.0) # sword_hitbox's starting and final position in 'slash' animation;
# used for calcuating the strength of the sword hit velocity


func _ready():
	set_projectile_area(sword_area)
	animations.play("slash")


func hit_player(_character: Character) -> void:
	_character.movement.current_velocity += Vector2(-3500.0 * (1 + (abs(sword_hitbox_range.y - sword_hitbox.position.x) / abs(sword_hitbox_range.y - sword_hitbox_range.x))), -3300.0)
	_character.movement.hitstun(2.5, 20)


func hit_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, events: Array, normal: Vector2 = Vector2.ZERO) -> void:
	touch_block(tile_map_layer, coords, events, normal)
