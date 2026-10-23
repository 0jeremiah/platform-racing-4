extends Node
class_name PlayerManager

const CHARACTER = preload("res://character/character.tscn")

var character: CharacterBody2D
var player_array: Array = []


func get_character() -> CharacterBody2D:
	return character


func spawn_local_player() -> CharacterBody2D:
	var start_option = Game.game.level_manager.get_next_start_position()
	if !start_option:
		return null
	character = CHARACTER.instantiate()
	
	if Game.game:
		Game.game.set_current_player_layer(start_option.map_layer_name)
	
	var layer = Game.game.level_manager.level_layers.map_layers.get_node(start_option.map_layer_name)
	if !layer:
		return null
	var player_holder = layer.players
	character.position = Vector2((start_option.coords * Settings.tile_size) + Settings.tile_size_half).rotated(start_option.tile_map_layer.global_rotation if start_option.tile_map_layer else 0)
	character.active = true
	player_holder.add_child(character)
	character.tile_interaction.set_depth(layer.z_axis)
	character.movement.toggle_health(character, Game.game.level_manager.level_type == LevelManager.deathmatch)
	player_array.append(character)
	return character
