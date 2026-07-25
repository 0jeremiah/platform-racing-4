extends CharacterBody2D

var walk_velocity = 200
var run_velocity = 1200
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var attack_cooldown: float = 4.444
var attack_timer: float = 0.0
var laser_bullet = preload("res://item_effects/laser_bullet.tscn")
var sword_slash = preload("res://item_effects/sword_slash.tscn")
@onready var egg_display = $EggDisplay
@onready var sight_area = $SightArea


func _ready():
	egg_display.scale.x = 1 - (2 * randi_range(0, 1))
	velocity.x = walk_velocity * egg_display.scale.x
	sight_area.scale.x = egg_display.scale.x
	egg_display.play("walk")


func _process(delta: float):
	move_and_slide()
	if is_on_wall():
		egg_display.scale.x *= -1
		velocity.x = walk_velocity * egg_display.scale.x
		sight_area.scale.x = egg_display.scale.x
	velocity += gravity * delta
	if attack_timer > 0:
		if attack_timer - delta > 0:
			attack_timer -= delta
		else:
			attack_timer = 0
	else:
		detect_players()


func detect_players():
	var collision: Array = sight_area.get_overlapping_bodies()
	for body in collision:
		if body is Character:
			print("we touched a player!")


func set_depth(depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	collision_layer = solid_layer
	collision_mask = solid_layer
	sight_area.collision_layer = collision_layer
	sight_area.collision_mask = collision_mask
