extends Node2D
class_name Tester

const HAT_EFFECT = preload("res://effects/hat/hat_effect.tscn")

@onready var back = $UI/Container/Back
@onready var minimap: Minimap = $UI/Container/Minimap
@onready var game_timer: GameTimer = $UI/Container/GameTimer
@onready var stats_display: StatsDisplay = $UI/Container/StatsDisplay
@onready var hp_display: HPDisplay = $UI/Container/HPDisplay
@onready var stats_panel = $UI/Container/StatsPanel
@onready var debug_display = $UI/Container/DebugDisplay
@onready var level_manager: LevelManager = $LevelManager
@onready var player_manager: PlayerManager = $PlayerManager

var show_debug_info: bool = true
var current_player_layer: String = ""
var run_update_stats_timer: bool = false
var update_stats_timer: float = 0.25
var used_rects: Dictionary = {}


func _ready():
	back.connect("pressed", _on_back_pressed)
	Game.game = self


func _process(delta: float) -> void:
	if run_update_stats_timer:
		if update_stats_timer - delta > 0.0:
			update_stats_timer -= delta
		else:
			update_stats()
			update_stats_timer = 0.25


func _on_back_pressed():
	var saved_camera_position = Vector2(0, 0)
	var character = player_manager.get_character()
	if character:
		saved_camera_position = character.position
	Main.set_scene(Main.LEVEL_EDITOR, {"saved_camera_position": saved_camera_position})


func init(data: Dictionary):
	var penciler: Node2D = get_node("Penciler")
	var bg: Node2D = get_node("BG")
	var editor_events: EditorEvents = get_node("EditorEvents")
	
	penciler.init(level_manager.level_layers, editor_events)
	editor_events.connect_to([level_manager.level_decoder])
	
	var level
	if data.get("level"):
		level = data.get("level")
	else:
		var file = FileAccess.open("res://test_data/test_level.json", FileAccess.READ)
		var content = file.get_as_text()
		level = JSON.parse_string(content)

	level_manager.decode_level(level)
	#level_manager.activate_node()
	
	bg.set_bg(level.properties.get("background", "field"), level.properties.get("fadeColor", "FFFFFF"))
	
	print(level.properties.get("music", ""))
	Jukebox.play_song(level.properties.get("music", ""))
	
	level_manager.init_level()
	level_manager.block_interval_manager.start()
	player_manager.spawn_local_player()
	
	minimap.init(self)
	stats_display.init(self)
	if level_manager.level_type == level_manager.deathmatch:
		hp_display.init(self)
		hp_display.visible = true
	debug_display.init(player_manager.get_character())
	game_timer.set_timer(level.properties.get("time", 120))
	game_timer.start_timer()
	run_update_stats_timer = true
	if show_debug_info:
		debug_display.activate()
	else:
		debug_display.deactivate()

func update_stats():
	var player = player_manager.get_character()
	var player_stats = player.stats.get_total()
	var editor_stats = stats_panel.get_total()
	var stats_changed: bool = stats_panel.did_stats_changed()
	if stats_changed:
		player.stats.set_stats(editor_stats[0], editor_stats[1], editor_stats[2], editor_stats[3])
		stats_panel.set_stats(editor_stats[0], editor_stats[1], editor_stats[2], editor_stats[3])
	else:
		stats_panel.set_stats(player_stats[0], player_stats[1], player_stats[2], player_stats[3])


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
	Main.set_scene(Main.LEVEL_EDITOR)


func set_current_player_layer(layer_name: String) -> void:
	current_player_layer = layer_name


func get_current_player_layer() -> String:
	return current_player_layer


func set_used_rect(layer_name: String, rect: Rect2i) -> void:
	used_rects[layer_name] = rect


func get_used_rect(layer_name: String) -> Rect2i:
	return used_rects.get(layer_name, Rect2i())


func get_total_used_rect_in_z_axis(z_axis: int) -> Rect2i:
	return level_manager.level_layers.get_total_used_rect_in_z_axis(z_axis)


func clear_used_rects() -> void:
	used_rects.clear()


func _exit_tree():
	level_manager.clear()


func reset_level():
	pass
