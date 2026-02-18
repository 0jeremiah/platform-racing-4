extends Item
class_name SpeedBurstItem

var speedburst_timer: float = 0.0
var _delta: float = 0.0


func _process(delta: float) -> void:
	_delta = delta


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_speed_burst")


func activate_item(_character: Character):
	if !_character.item_manager.using:
		speedburst_timer = GameConfig.get_value("items-effects", "speed_burst_duration")
		_character.movement.speedburst_boost = GameConfig.get_value("items-effects", "speed_burst_multiplier")
		_character.speed_particles.emitting = true
		_character.item_manager.using = true
		Jukebox.play_sound("speedup")


func process_item(_character: Character):
	if _character.item_manager.using:
		if speedburst_timer > 0:
			speedburst_timer -= _delta
		else:
			_character.item_manager.using = false
			_character.speed_particles.emitting = false
			_character.movement.speedburst_boost = 1.0
			_character.item_manager.uses -= 1
			Jukebox.play_sound("slowdown")


func _remove_item(_character: Character):
	_character.speed_particles.emitting = false
	_character.movement.speedburst_boost = 1.0
	if _character.item_manager.using:
		Jukebox.play_sound("slowdown")
