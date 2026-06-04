extends Node2D
class_name LaserGunItem

@onready var projectile = load("res://item_effects/laser_bullet.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_laser_gun")


func _play_idle_animation():
	animations.play("idle")


func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		animations.stop()
		animations.play("shoot")
		animation_timer.start(animations.get_current_animation_length())
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_laser_gun")
		shoot(_character)
		if _character.movement.facing < 0:
			_character.movement.current_velocity.x += 750
		else:
			_character.movement.current_velocity.x -= 750
		_character.item_manager.uses -= 1


func shoot(_character: Character):
	var layer = Game.get_target_map_layer_node()
	var spawn = layer.projectiles
	var bullet = projectile.instantiate()
	bullet.global_position = global_position
	bullet.collision_layer = _character.collision_layer
	bullet.collision_mask = _character.collision_mask
	bullet.set_projectile(bullet, _character, GameConfig.get_value("items-effects", "laser_bullet_lifetime"), Vector2(GameConfig.get_value("items-effects", "laser_bullet_speed"), 0.0), Vector2(-50, 0.1))
	spawn.add_child(bullet)
	Jukebox.play_sound("laser")


func _remove_item(_character: Character):
	animation_timer.stop()
	_play_idle_animation()
