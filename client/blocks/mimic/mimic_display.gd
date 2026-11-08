extends Node2D

@onready var foot_back_color = $FootBack/Color
@onready var mimic_color1 = $Mimic/MimicColor1
@onready var mimic_color2 = $Mimic/MimicColor2
@onready var mimic_texture = $Mimic/MimicTexture
@onready var foot_front_color = $FootFront/Color
@onready var animations: AnimationPlayer = $Animations


func _ready():
	foot_back_color.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	foot_front_color.self_modulate = foot_back_color.self_modulate


func play(anim: String) -> void:
	animations.play(anim)


func set_mimic_texture(block_id: String, color_1: String, color_2: String):
	var block_has_textures = BlockManager.block_has_textures(block_id)
	mimic_color1.visible = false
	mimic_color2.visible = false
	mimic_texture.texture = BlockManager.get_block_texture(block_id)
	if block_has_textures.has_mimic_color1_texture:
		mimic_color1.texture = BlockManager.get_block_mimic_color1_texture(block_id)
		mimic_color1.self_modulate = Color(color_1)
		mimic_color1.visible = true
	if block_has_textures.has_mimic_color2_texture:
		mimic_color2.texture = BlockManager.get_block_mimic_color2_texture(block_id)
		mimic_color2.self_modulate = Color(color_2)
		mimic_color2.visible = true
