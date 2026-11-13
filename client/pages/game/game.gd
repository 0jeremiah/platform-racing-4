extends Node2D
class_name Game

static var pr2_level_id = null
static var local_pr2_level = null
static var game: Node2D

const HAT_EFFECT = preload("res://effects/hat/hat_effect.tscn")

@onready var bg = $BG
@onready var game_ui = $GameUI
@onready var back_button = $GameUI/Container/BackButton
@onready var minimap: Minimap = $GameUI/Container/Minimap
@onready var game_timer: GameTimer = $GameUI/Container/GameTimer
@onready var stats_display: StatsDisplay = $GameUI/Container/StatsDisplay
@onready var hp_display: HPDisplay = $GameUI/Container/HPDisplay
@onready var level_manager: LevelManager = $LevelManager
@onready var player_manager: PlayerManager = $PlayerManager

var used_rects: Dictionary = {}
var current_player_layer: String = ""


func _ready():
	back_button.connect("pressed", _on_back_pressed)
	
	var penciler: Node2D = get_node("Penciler")
	var editor_events: EditorEvents = get_node("EditorEvents")
	
	editor_events.connect_to([level_manager.level_decoder])
	penciler.init(level_manager.level_layers, editor_events)
	load_level()
	Game.game = self


func load_level():
	if Game.local_pr2_level and Game.local_pr2_level is String:
		level_manager.decode_pr2_level(local_pr2_level)
		if !level_manager.error:
			_activate_game()
		else:
			Main.set_scene(Main.TITLE)
	elif !Game.pr2_level_id or Game.pr2_level_id == '0':
		_activate_game()
	else:
		print("Game: Loading level id: " + Game.pr2_level_id)
		var http_request = get_node("HTTPRequest")
		http_request.request_completed.connect(func(_result, _response_code, _headers, body):
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			if !response:
				return
			if response.get("error", ''):
				return
			
			level_manager.decode_level(response)
			_activate_game()
		)
		if Game.pr2_level_id:
			var error = http_request.request(ApiManager.get_base_url() + "/pr2/level/" + Game.pr2_level_id)
			if error != OK:
				push_error("An error occurred in the HTTP request.")


func show_level_ui(show_ui: bool):
	game_ui.visible = show_ui


func set_used_rect(layer_name: String, rect: Rect2i) -> void:
	used_rects[layer_name] = rect


func get_used_rect(layer_name: String) -> Rect2i:
	return used_rects.get(layer_name, Rect2i())


func get_total_used_rect_in_z_axis(z_axis: int) -> Rect2i:
	return level_manager.level_layers.get_total_used_rect_in_z_axis(z_axis)


func clear_used_rects() -> void:
	used_rects.clear()


func set_current_player_layer(layer_name: String) -> void:
	current_player_layer = layer_name


func get_current_player_layer() -> String:
	return current_player_layer


static func get_target_map_layer_node() -> Node:
	var target_layer_name: String = game.level_manager.level_layers.get_target_map_layer()
	return game.level_manager.level_layers.map_layers.get_node(target_layer_name)


func _activate_game() -> void:
	bg.set_bg(level_manager.background_id, level_manager.fade_color)
	level_manager.init_level()
	level_manager.block_interval_manager.start()
	player_manager.spawn_local_player()
	minimap.init(self)
	stats_display.init(self)
	if level_manager.level_type == level_manager.deathmatch:
		hp_display.init(self)
		hp_display.visible = true
	game_timer.set_timer(level_manager.time)
	game_timer.start_timer()


func local_lose_hat(character: Character) -> Dictionary:
	var hat_info = character.lose_hat()
	if CharacterManager._parts_lookup.hat.has(hat_info.id) and hat_info.id != "1":
		var map_layer = Game.get_target_map_layer_node()
		var hat = HAT_EFFECT.instantiate()
		hat.tile_map_layer = map_layer.tile_map_layer
		hat.hat_id = hat_info.id
		hat.hat_color = hat_info.color
		hat.hat_epic_color = hat_info.epic_color
		hat.hat_size = character.display.hat_holder.scale * character.movement.size
		hat.position = character.position + Vector2(character.display.hat_holder.position * character.movement.size).rotated(character.rotation)
		map_layer.effects.add_child(hat)
	return hat_info


func grab_hat(character: Character, hat_info: Dictionary) -> void:
	if CharacterManager._parts_lookup.hat.has(hat_info.id) and hat_info.id != "1":
		character.hat_array.append(hat_info)
		character.display.set_hat_array(character.hat_array)


func finish():
	Main.set_scene(Main.TITLE)


func _exit_tree():
	level_manager.clear()
	clear_used_rects()
	Game.game = null


func _on_back_pressed():
	Main.set_scene(Main.TITLE)


func reset_level():
	pass
