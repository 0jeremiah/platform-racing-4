extends Node2D

@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations

var spawnpos: Vector2
var spawnrot: float

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	animtimer.connect("timeout", queue_free)
	animtimer.start()
	animations.play("poof")
