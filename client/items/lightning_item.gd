extends Item
class_name LightningItem

func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_lightning")


func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_lightning")
		_character.item_manager.uses -= 1
		Jukebox.play_sound("zap")
