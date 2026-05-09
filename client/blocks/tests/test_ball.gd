extends RigidBody2D
## Test ball for physics testing
##
## A simple orange ball with collision detection for tiles

var last_collision_normal: Vector2 = Vector2(0, 0)

func _ready() -> void:
	# Create the ball sprite texture
	var sprite: Sprite2D = $Sprite2D
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.ORANGE)
	sprite.texture = ImageTexture.create_from_image(image)


func _process(_delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(linear_velocity, true)
	if !collision:
		return
		
	var tile_map_layer = collision.get_collider()
	if not (tile_map_layer is TileMapLayer):
		return

	var normal = collision.get_normal().rotated(-rotation)
	last_collision_normal = normal
