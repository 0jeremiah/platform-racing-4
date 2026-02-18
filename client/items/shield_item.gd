extends Item
class_name ShieldItem

@onready var shield_sprite = $Shield
var shield_timer: float = 0.0
var _delta: float = 0.0


func _init_item(_character: Character) -> void:
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_shield")
	shield_sprite.visible = false


func _process(delta: float) -> void:
	_delta = delta

	
func activate_item(_character: Character):
	if !_character.item_manager.using:
		shield_timer = GameConfig.get_value("items-effects", "shield_duration")
		_character.movement.shielded = true
		shield_sprite.visible = true
		_character.item_manager.using = true
		Jukebox.play_sound("shield1")


func process_item(_character: Character):
	if _character.item_manager.using:
		if shield_timer > 0:
			shield_timer -= _delta
		else:
			shield_sprite.visible = false
			_character.movement.shielded = false
			_character.item_manager.uses -= 1


func _remove_item(_character: Character):
	shield_sprite.visible = false
	_character.movement.shielded = false
