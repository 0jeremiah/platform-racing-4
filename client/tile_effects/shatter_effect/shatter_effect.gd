extends Node2D

var chunk_size = Vector2i(64, 64)
var chunk_linear_velocity = 300
var chunk_angular_velocity = 20


func add_pieces(block_id: String, pieces: int) -> void:
	for i in range(0, pieces):
		var randi = randi_range(0, 3)
		var offset = Vector2i(randi % 2, randi / 2) * chunk_size
		add_piece(block_id, offset, Settings.tile_size - Vector2i(Vector2(Settings.tile_size) * 0.5))


func add_piece(block_id: String, offset: Vector2i, dimensions: Vector2i):
	var sprite = Sprite2D.new()
	sprite.texture = BlockManager.get_block_texture(block_id)
	sprite.region_enabled = true
	sprite.region_rect = Rect2i(offset, dimensions)
	
	var chunk = RigidBody2D.new()
	chunk.gravity_scale = 0.25
	chunk.angular_velocity = randf_range(-chunk_angular_velocity, chunk_angular_velocity)
	chunk.linear_velocity = Vector2(randf_range(-chunk_linear_velocity, chunk_linear_velocity), randf_range(-chunk_linear_velocity, chunk_linear_velocity))
	chunk.position = Vector2(offset)
	chunk.add_child(sprite)
	
	add_child(chunk)
