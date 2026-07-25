extends Node2D

@onready var foot_back_color = $FootBack/Color
@onready var egg_color = $Egg/EggColor
@onready var egg_spots = $Egg/EggSpots
@onready var foot_front_color = $FootFront/Color
@onready var animations: AnimationPlayer = $Animations


func _ready():
	foot_back_color.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	egg_color.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	egg_spots.self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	foot_front_color.self_modulate = foot_back_color.self_modulate


func play(anim: String) -> void:
	animations.play(anim)
