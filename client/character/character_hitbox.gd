extends CollisionShape2D
## Controls the character's collision shape.
## Adjusts between high and low profiles based on character state.

var block_size: Vector2 = Vector2(Settings.tile_size)
var high = (block_size.y * 2) - (block_size.y / 2)
var low = block_size.y - (block_size.y / 2)
var hitbox_size: Vector2 = Vector2(block_size.x / 2, block_size.y)
var debug_hitbox_size: Vector2 = Vector2(0.0, 0.0)
var mode: String = "high"


func _ready():
	go_high()


func run(character: Character) -> void:
	if character.is_on_floor():
		go_low()
	elif character.lightbreak.is_active():
		go_low()
	elif character.velocity.rotated(-character.rotation).y >= -0.01:
		go_low()
	elif character.movement.is_crouching:
		go_low()
	else:
		go_high()
	
	# disable collision if we're stuck in a wall
	#if character.tile_interaction.is_in_solid(character):
		#disabled = true
	if character.lightbreak.type == LightTile.MOON and character.lightbreak.is_active():
		disabled = true
	else:
		disabled = false
	
	# position hitbox
	shape.size = Vector2(hitbox_size.x * character.movement.size, hitbox_size.y * character.movement.size)
	debug_hitbox_size = shape.size
	position.y = round(-shape.size.y / 2.0)


func go_high() -> void:
	mode = "high"
	hitbox_size.y = high


func go_low() -> void:
	mode = "low"
	hitbox_size.y = low
