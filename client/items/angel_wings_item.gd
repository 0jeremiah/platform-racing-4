extends Node2D
class_name AngelWingsItem

@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()
var decrease_uses_timer: float = 0.0
var _delta: float = 0.0


func _ready() -> void:
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _process(delta: float) -> void:
	_delta = delta


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_angel_wings")


func process_item(_character: Character):
	if _character:
		if _character.item_manager.using:
			if _character.movement.current_velocity.y >= 0:
				_character.movement.current_velocity.y = 0
			if _character.movement.current_velocity.y >= -3000:
				_character.item_manager.force = Vector2(100, -60)
			else:
				_character.item_manager.force = Vector2(100, 0)
		else:
			_character.item_manager.force = Vector2(0, 0)
		if decrease_uses_timer > 0:
			decrease_uses_timer -= _delta
		elif _character.item_manager.using:
			_character.item_manager.uses -= 1
			_character.item_manager.using = false


func _play_idle_animation():
	animations.play("idle")


func activate_item(_character: Character):
	if _character and !_character.item_manager.using:
		_character.item_manager.using = true
		animations.stop()
		animations.play("flap")
		animation_timer = animations.get_current_animation_length()
		decrease_uses_timer = GameConfig.get_value("items-uses", "reload_angel_wings")
		Jukebox.play_sound("wingflap")


func _remove_item(_character: Character):
	_play_idle_animation()
