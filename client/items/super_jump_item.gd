extends Item
class_name SuperJumpItem

func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_super_jump")


func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		_character.velocity.y -= 5000
		Jukebox.play_sound("superjump")
		_character.item_manager.uses -= 1
