extends RigidBody2D
## Test ball for physics testing
##
## A simple orange ball with collision detection for tiles


func _ready() -> void:
	# Create the ball sprite texture
	var sprite: Sprite2D = $Sprite2D
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.ORANGE)
	sprite.texture = ImageTexture.create_from_image(image)
