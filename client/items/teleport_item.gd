extends Item
class_name TeleportItem

@onready var poof_effect = preload("res://item_effects/poof_effect.tscn")


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_teleport")

# basic teleporting works but there is no detection-
# to stop you from teleporting into a wall.
func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		var layer = Game.get_target_block_layer_node()
		var spawn = layer.get_node("Projectiles")
		var poof1 = poof_effect.instantiate()
		poof1.spawnpos = _character.item_manager.global_position
		poof1.spawnrot = _character.global_rotation
		spawn.add_child(poof1)
		if _character.movement.facing > 0:
			_character.position.x += 512
		else:
			_character.position.x -= 512
		var poof2 = poof_effect.instantiate()
		poof2.spawnpos = _character.item_manager.global_position
		poof2.spawnrot = _character.global_rotation
		spawn.add_child(poof2)
		Jukebox.play_sound("teleport")
		_character.item_manager.uses -= 1
