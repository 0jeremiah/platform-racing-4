extends CharacterBody2D
class_name EggEnemy

@onready var egg_display = $EggDisplay
@onready var attack_area = $AttackArea
@onready var reveal_area = $RevealArea
@onready var sense_jump_area = $SenseJumpArea

var walk_velocity = 200.0
var run_velocity = 1200.0
var jump_velocity = -1000.0
var gravity: Vector2 = Vector2(0.0, 2250.0)
var attack_cooldown: float = 4.444
var attack_timer: float = 0.0
var laser_bullet = preload("res://item_effects/laser_bullet.tscn")
var sword_slash = preload("res://item_effects/sword_slash.tscn")
var ice_wave = preload("res://item_effects/ice_wave.tscn")
var tile_map_layer: ConfigurableTileMapLayer = null
var can_run: bool = false
var can_jump: bool = false
var can_disguise: bool = false
var state: String = "walk"
var animation_timer: float = 0.0
var egg_depth: int = 10


func _ready() -> void:
	egg_display.scale.x = 1 - (2 * randi_range(0, 1))
	velocity.x = walk_velocity * egg_display.scale.x
	attack_area.scale.x = egg_display.scale.x
	var solid_layer = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.solid_layer_id)
	var vapor_layer = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.non_solid_layer_id)
	collision_layer = solid_layer
	collision_mask = solid_layer
	var areas = [attack_area, reveal_area, sense_jump_area]
	for area in areas:
		area.collision_layer = solid_layer
		area.collision_mask = solid_layer | vapor_layer
	egg_display.animations.animation_changed.connect(_on_animation_changed)
	if can_disguise:
		state = "disguise"
		animation_timer = randf_range(5.0, 20.0)
	else:
		if can_run:
			state = "run"
		else:
			state = "walk"


func _process(delta: float):
	check_out_of_bounds()
	if state == "walk":
		velocity.x = walk_velocity
	maybe_run_animations()
	if state != "walk" and state != "run" and state != "jump":
		attack_area.monitoring = false
	if state != "disguise":
		reveal_area.monitoring = false
	if state != "walk" and state != "run":
		sense_jump_area.monitoring = false
	if state == "disguise":
		reveal_area.monitoring = true
		if animation_timer > 0:
			if animation_timer - delta > 0:
				animation_timer -= delta
			else:
				egg_display.animations.clear_queue()
				egg_display.play("disguise_look")
				egg_display.animations.queue("disguise")
				animation_timer = 0
		detect_players()
	if state == "walk" or state == "run" or state == "jump":
		attack_area.monitoring = true
		if state != "jump":
			sense_jump_area.monitoring = true
		if state == "jump" and is_on_floor():
			if can_run:
				state = "run"
			else:
				state = "walk"
		if is_on_floor() and (state == "walk" or state == "run") and sense_jump_area.monitoring and need_to_jump():
			state = "jump"
			velocity.y = jump_velocity
		if attack_timer > 0:
			if attack_timer - delta > 0:
				attack_timer -= delta
			else:
				attack_timer = 0
		else:
			detect_players()
	if state == "walk":
		velocity.x = walk_velocity * egg_display.scale.x
	elif state == "run":
		velocity.x = run_velocity * egg_display.scale.x
	elif state == "disguise":
		velocity.x = 0
	move_and_slide()
	if is_on_wall():
		egg_display.scale.x *= -1
		velocity.x *= egg_display.scale.x
		attack_area.scale.x = egg_display.scale.x
	velocity += gravity * delta


func detect_players():
	if attack_area.monitoring:
		var attack_collisions: Array = attack_area.get_overlapping_bodies()
		for body in attack_collisions:
			if body == Game.game.player_manager.character:
				attack_timer = attack_cooldown
				attack()
				break
	if reveal_area.monitoring:
		var reveal_collisions: Array = reveal_area.get_overlapping_bodies()
		for body in reveal_collisions:
			if body == Game.game.player_manager.character:
				state = "reveal"
				break


func need_to_jump() -> bool:
	if !is_on_floor():
		return false
	var bodies = sense_jump_area.get_overlapping_bodies()
	var should_jump: bool = true
	for body in bodies:
		if body is BlockScene and body.settings.matter_type != ConfigurableBlockSettings.GAS:
			should_jump = false
			break
	return should_jump


func attack():
	if tile_map_layer:
		var spawn_position = Vector2(global_position.x, global_position.y - 50)
		var attack_id = randi_range(1, 3)
		if attack_id == 1:
			var spawn = tile_map_layer.map_layer.projectiles
			tile_map_layer.shoot_laser(spawn_position, rotation, egg_display.scale.x == -1, self)
		elif attack_id == 2:
			var spawn = tile_map_layer.map_layer.projectiles
			var slash = sword_slash.instantiate()
			slash.global_position = spawn_position
			slash.set_projectile(slash, GameConfig.get_value("items-effects", "sword_slash_lifetime"), Vector2(GameConfig.get_value("items-effects", "sword_slash_speed"), 0.0), egg_display.scale.x == -1, self)
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
				ice_wave_projectile.set_projectile(ice_wave_projectile, GameConfig.get_value("items-effects", "ice_wave_lifetime"), Vector2(GameConfig.get_value("items-effects", "ice_wave_speed"), 0.0), egg_display.scale.x == -1, self)
				spawn.add_child(ice_wave_projectile)
			Jukebox.play_sound("icewave")


func maybe_run_animations():
	var current_animation = str(egg_display.animations.get_current_animation())
	if state == "walk" and current_animation != "walk":
		egg_display.animations.clear_queue()
		egg_display.play("walk")
	elif state == "run" and current_animation != "run":
		egg_display.animations.clear_queue()
		egg_display.play("walk")
	elif state == "disguise" and (current_animation != "disguise" and current_animation != "disguise_look"):
		egg_display.animations.clear_queue()
		egg_display.animations.play("disguise")
	elif state == "reveal" and current_animation != "reveal":
		egg_display.animations.clear_queue()
		egg_display.play("reveal")
		if can_run:
			egg_display.animations.queue("run")
		else:
			egg_display.animations.queue("walk")
	elif state == "jump" and current_animation != "jump":
		egg_display.animations.clear_queue()
		egg_display.play("jump")
		egg_display.animations.queue("airborne")
	elif state == "squashed" and current_animation != "squash":
		egg_display.animations.clear_queue()
		egg_display.play("squash")
		egg_display.animations.queue("squash")


func _on_animation_changed(old_name: String, new_name: String):
	var previous_animation_name = str(old_name)
	var queued_animation_name = str(new_name)
	if state == "reveal":
		if can_run or queued_animation_name == "run":
			state = "run"
		else:
			state = "walk"
	if state == "disguise" or previous_animation_name == "disguise_look":
		animation_timer = randf_range(5.0, 20.0)
	elif state == "squashed":
		queue_free()


func set_egg_texture(block_id: String, color_1: String, color_2: String):
	egg_display.set_egg_texture(block_id, color_1, color_2)


func check_out_of_bounds() -> void:
	if not Game.game:
		return
	if Game.game.level_manager.level_layers.is_out_of_bounds(self):
		queue_free()
