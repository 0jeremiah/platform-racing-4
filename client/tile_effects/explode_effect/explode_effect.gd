extends Node2D

@onready var animations: AnimationPlayer = $Animations

func _ready():
	animations.animation_finished.connect(queue_free)
	animations.play("explode")
