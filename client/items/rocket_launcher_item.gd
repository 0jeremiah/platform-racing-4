extends Item
class_name RocketLauncherItem

var rocket = load("res://item_effects/rocket.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item(_character: Character) -> void:
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_rocket_launcher")


func _play_idle_animation():
	animations.play("idle")


# rocket collision not yet finished.
func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		animations.stop()
		animations.play("launch")
		animation_timer.start(animations.get_current_animation_length())
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_rocket_launcher")
		launch(_character)
		if _character.movement.facing > 0:
			_character.movement.current_velocity.x -= 2500
		else:
			_character.movement.current_velocity.x += 2500
		_character.item_manager.uses -= 1


func launch(_character: Character):
	var layer = Game.get_target_map_layer_node()
	var spawn = layer.projectiles
	var missle = rocket.instantiate()
	missle.global_position = global_position
	missle.collision_layer = _character.collision_layer
	missle.collision_mask = _character.collision_mask
	missle.set_projectile(missle, _character.collision_layer, _character.collision_mask, GameConfig.get_value("items-effects", "rocket_lifetime"), Vector2(GameConfig.get_value("items-effects", "rocket_speed"), 0.0).rotated(_character.rotation), _character.movement.facing == -1, _character)
	spawn.add_child(missle)
	Jukebox.play_sound("misslelauncher")


func _remove_item(_character: Character):
	animation_timer.stop()
	_play_idle_animation()
