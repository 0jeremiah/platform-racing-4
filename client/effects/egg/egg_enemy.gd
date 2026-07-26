extends CharacterBody2D

var walk_velocity = 200
var run_velocity = 1200
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var attack_cooldown: float = 4.444
var attack_timer: float = 0.0
var laser_bullet = preload("res://item_effects/laser_bullet.tscn")
var sword_slash = preload("res://item_effects/sword_slash.tscn")
var ice_wave = preload("res://item_effects/ice_wave.tscn")
var tile_map_layer: ConfigurableTileMapLayer = null
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
			#print("we touched a player!")
			attack_timer = attack_cooldown
			attack()


func attack():
	if tile_map_layer:
		var spawn_position = Vector2(global_position.x, global_position.y - 50)
		var attack_id = randi_range(1, 3)
		if attack_id == 1:
			var spawn = tile_map_layer.map_layer.projectiles
			var bullet = laser_bullet.instantiate()
			bullet.global_position = spawn_position
			bullet.collision_layer = collision_layer
			bullet.collision_mask = collision_mask
			bullet.set_projectile(bullet, collision_layer, collision_mask, GameConfig.get_value("items-effects", "laser_bullet_lifetime"), Vector2(GameConfig.get_value("items-effects", "laser_bullet_speed"), 0.0).rotated(rotation), egg_display.scale.x == -1, self)
			spawn.add_child(bullet)
			Jukebox.play_sound("laser")
		elif attack_id == 2:
			var spawn = tile_map_layer.map_layer.projectiles
			var slash = sword_slash.instantiate()
			slash.global_position = spawn_position
			slash.collision_layer = collision_layer
			slash.collision_mask = collision_mask
			slash.set_projectile(slash, collision_layer, collision_mask, GameConfig.get_value("items-effects", "sword_slash_lifetime"), Vector2(GameConfig.get_value("items-effects", "sword_slash_speed"), 0.0).rotated(rotation), egg_display.scale.x == -1, self)
			spawn.add_child(slash)
			Jukebox.play_sound("swish")
		elif attack_id == 3:
			var spawn = tile_map_layer.map_layer.projectiles
			var ice_wave_amount = 3
			var ice_wave_rotation = 0.0
			var angle_increment = 0
			var angle = 0
			if ice_wave_amount > 1:
				angle_increment = 90.0 / (ice_wave_amount - 1)
				angle = ice_wave_rotation - (45.0 + angle_increment)
			for current_ice_wave in ice_wave_amount:
				angle += angle_increment
				var ice_wave_projectile = ice_wave.instantiate()
				ice_wave_projectile.global_position = spawn_position
				ice_wave_projectile.rotation_degrees = angle
				ice_wave_projectile.set_projectile(ice_wave_projectile, collision_layer, collision_mask, GameConfig.get_value("items-effects", "ice_wave_lifetime"), Vector2(GameConfig.get_value("items-effects", "ice_wave_speed"), 0.0).rotated(ice_wave_projectile.rotation).rotated(rotation), egg_display.scale.x == -1, self)
				spawn.add_child(ice_wave_projectile)
			Jukebox.play_sound("icewave")


func set_depth(depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	collision_layer = solid_layer
	collision_mask = solid_layer
	sight_area.collision_layer = collision_layer
	sight_area.collision_mask = collision_mask
