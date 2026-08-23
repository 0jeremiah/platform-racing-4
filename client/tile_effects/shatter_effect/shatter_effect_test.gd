extends Node2D

var ShatterEffect = preload("res://tile_effects/shatter_effect/shatter_effect.tscn")
var tileatlas = preload("res://tiles/tileatlas.png")
@onready var timer = $Timer


func _ready():
	test()
	timer.connect("timeout", test)


func test():
	BlockManager.load_default_block_configs()
	var effect = ShatterEffect.instantiate()
	effect.add_pieces("5", 4)
	effect.position = Vector2(200, 200)
	add_child(effect)
