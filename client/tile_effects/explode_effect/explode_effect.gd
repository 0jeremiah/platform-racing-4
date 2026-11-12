extends Node2D

@onready var animations: AnimationPlayer = $Animations

func _ready():
	animations.animation_finished.connect(_finished)
	animations.play("explode")


func _finished(_anim_name: String):
	queue_free()
