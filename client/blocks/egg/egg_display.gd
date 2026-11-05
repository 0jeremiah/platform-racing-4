extends Node2D

@onready var foot_back_color = $FootBack/Color
@onready var egg_color = $Egg/EggColor
@onready var egg_spots = $Egg/EggSpots
@onready var egg_texture = $Egg/EggTexture
@onready var foot_front_color = $FootFront/Color
@onready var animations: AnimationPlayer = $Animations


func _ready():
	foot_back_color.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	foot_front_color.self_modulate = foot_back_color.self_modulate


func play(anim: String) -> void:
	animations.play(anim)


func set_egg_texture(block_id: String, color_1: String, color_2: String):
	var block_has_textures = BlockManager.block_has_textures(block_id)
	egg_color.visible = false
	egg_spots.visible = false
	egg_texture.texture = BlockManager.get_block_texture(block_id)
	if block_has_textures.has_egg_color_texture:
		egg_color.texture = BlockManager.get_block_egg_color_texture(block_id)
		egg_color.self_modulate = Color(color_1)
		egg_color.visible = true
	if block_has_textures.has_egg_spots_texture:
		egg_spots.texture = BlockManager.get_block_egg_spots_texture(block_id)
		egg_spots.self_modulate = Color(color_2)
		egg_spots.visible = true
