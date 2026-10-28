extends Control
class_name RotationController

var rotation_velocity: float = 0.0
var tick_seconds: float = 4.0
var tock_seconds: float = 0.5
var elapsed_time: float = 0.0
var per_rotation: float = 90.0
var inertia: float = 0.93
var target_rotation_degrees: float = 0.0
var tick = 'tock'
var enabled = true
var enabled_temp = false # set to true to kick off only one rotation
var init_timer: float = 0.2


func _physics_process(delta: float):
	# rotate!
	elapsed_time += delta
	
	if (enabled || enabled_temp):
		if tick == 'tick' && elapsed_time > tock_seconds:
			elapsed_time = 0.0
			target_rotation_degrees += 0.0 if per_rotation == 0.0 else per_rotation + ((per_rotation / 20) * inertia)
			tick = 'tock'
		if tick == 'tock' && elapsed_time > tick_seconds:
			elapsed_time = 0.0
			tick = 'tick'
			target_rotation_degrees -= 0.0 if per_rotation == 0.0 else ((per_rotation / 20) * inertia)
	
	if enabled_temp && elapsed_time >= tick_seconds * 0.75:
		enabled_temp = false
		
	rotation_velocity += (target_rotation_degrees - rotation_degrees)
	rotation_velocity = rotation_velocity * inertia
	rotation_degrees += rotation_velocity * delta
	
	# this is needed to let the tile_map_layer know something has changed and it needs to update
	#for child in get_children():
		#child.rotation = 0
