extends Node2D

var ShatterEffect = preload("res://tile_effects/shatter_effect/shatter_effect.tscn")
@onready var timer = $Timer


func _ready():
	test()
	timer.connect("timeout", test)


func test():
	var effect = ShatterEffect.instantiate()
	effect.add_pieces("5", 4)
	effect.position = Vector2(200, 200)
	add_child(effect)
