extends Item
class_name SwordItem

@onready var swordslash = load("res://item_effects/sword_slash.tscn")
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
		slash(_character)
		if _character.display.scale.x < 0:
			_character.velocity.x -= 1000
		else:
			_character.velocity.x += 1000
		_character.item_manager.uses -= 1


func slash(_character: Character):
	var layer = Game.get_target_block_layer_node()
	var spawn = layer.get_node("Projectiles")
	var slash = swordslash.instantiate()
	slash.dir = 0
	slash.spawnpos = _character.item_manager.global_position
	slash.spawnrot = 0
	slash.scale.x = _character.movement.facing
	spawn.add_child.call_deferred(slash)


func _remove_item(_character: Character):
	animation_timer.stop()
	_play_idle_animation()
