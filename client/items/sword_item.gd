extends Item
class_name SwordItem

@onready var sword_slash = load("res://item_effects/sword_slash.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_sword")


func _play_idle_animation():
	animations.play("idle")


# no hitboxes/collison for sword slash yet.
func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		animations.stop()
		animations.play("swing")
		animation_timer.start(animations.get_current_animation_length())
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_sword")
		swing(_character)
		if _character.display.scale.x < 0:
			_character.movement.current_velocity.x -= 1000
		else:
			_character.movement.current_velocity.x += 1000
		_character.item_manager.uses -= 1


func swing(_character: Character):
	var layer = Game.get_target_map_layer_node()
	var spawn = layer.projectiles
	var slash = sword_slash.instantiate()
	slash.global_position = global_position
	slash.collision_layer = _character.collision_layer
	slash.collision_mask = _character.collision_mask
	slash.set_projectile(slash, _character.collision_layer, _character.collision_mask, GameConfig.get_value("items-effects", "sword_slash_lifetime"), Vector2(GameConfig.get_value("items-effects", "sword_slash_speed"), 0.0).rotated(_character.rotation), _character.movement.facing == -1, _character)
	spawn.add_child(slash)
	Jukebox.play_sound("swish")


func _remove_item(_character: Character):
	animation_timer.stop()
	_play_idle_animation()
