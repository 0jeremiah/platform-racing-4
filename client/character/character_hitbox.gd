extends CollisionShape2D
## Controls the character's collision shape.
## Adjusts between high and low profiles based on character state.

const HIGH: float = 180.0
const LOW: float = 32.0

var hitbox_size: Vector2 = Vector2(1, 1)
var mode: String = "high"


func _ready():
	go_high()


func run(character: Character) -> void:
	hitbox_size = Vector2(character.movement.size, character.movement.size)
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
	if character.tile_interaction.is_in_solid(character):
		disabled = true
	elif character.lightbreak.type == LightTile.MOON and character.lightbreak.is_active():
		disabled = true
	else:
		disabled = false
	
	# position hitbox
	position.y = round(-shape.size.y / 2.0)


func go_high() -> void:
	mode = "high"
	shape.size.y = HIGH


func go_low() -> void:
	mode = "low"
	shape.size.y = LOW
