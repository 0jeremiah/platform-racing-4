extends Control
class_name HPDisplay

@onready var hp_text = $HPText

var game
var player
var stats: Array


func init(game_scene):
	game = game_scene
	player = game_scene.get_node("PlayerManager").get_character()


func _process(_delta: float) -> void:
	if player:
		var current_hp = player.movement.life
		var max_hp = player.movement.max_life
		hp_text.text = str(current_hp) + " / " + str(max_hp) + " (" + str(snappedf(float(current_hp) / float(max_hp), 0.001) * 100) + "%)"
