extends Node2D
class_name BlackHoleItem

@onready var hole = load("res://item_effects/black_hole.tscn")


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_black_hole")


func activate_item(_character: Character):
	if _character and !_character.item_manager.using:
		_character.item_manager.using = true
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_black_hole")
		spawn_hole(_character)
		_character.item_manager.uses -= 1


func spawn_hole(_character: Character):
	var blackhole = hole.instantiate()
	var layer = Game.get_target_map_layer_node()
	var spawn = layer.get_node("Projectiles")
	spawn.add_child.call_deferred(blackhole)
	blackhole.dir = 0
	blackhole.spawnpos = global_position
	blackhole.spawnrot = 0
	blackhole.scale.x = _character.movement.facing
	Jukebox.play_sound("blackhole")
