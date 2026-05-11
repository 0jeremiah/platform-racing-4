extends Node2D

@onready var back = $UI/Container/Back
@onready var minimap: Minimap = $UI/Container/Minimap
@onready var game_timer: GameTimer = $UI/Container/GameTimer
@onready var stats_display: StatsDisplay = $UI/Container/StatsDisplay
@onready var stats_panel = $UI/Container/StatsPanel
@onready var debug_display = $UI/Container/DebugDisplay
@onready var update_stats_timer = $UI/Container/UpdateStatsPanelTimer
@onready var level_manager: LevelManager = $LevelManager

var show_debug_info: bool = true
var current_player_layer: String = ""
var used_rects: Dictionary = {}


func _ready():
	back.connect("pressed", _on_back_pressed)
	Game.game = self


func _on_back_pressed():
	var saved_camera_position = Vector2(0, 0)
	var player_manager: PlayerManager = get_node("PlayerManager")
	var character = player_manager.get_character()
	if character:
		saved_camera_position = character.position
	Main.set_scene(Main.LEVEL_EDITOR, {"saved_camera_position": saved_camera_position})


func init(data: Dictionary):
	var penciler: Node2D = get_node("Penciler")
	var bg: Node2D = get_node("BG")
	var editor_events: EditorEvents = get_node("EditorEvents")
	
	penciler.init(level_manager.level_layers, editor_events, null)
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
	
	var player_manager: PlayerManager = get_node("PlayerManager")
	var start_option = Start.get_next_start_option(level_manager.level_layers)
	if start_option:
		var character = player_manager.spawn_player(level_manager.level_layers)
	
	minimap.init(self)
	game_timer.init(self)
	stats_display.init(self)
	debug_display.init(player_manager.get_character())
	game_timer.set_timer(level.properties.get("time", 120))
	game_timer.start_timer()
	level_manager.calc_used_rect()
	update_stats_timer.connect("timeout", update_stats)
	update_stats_timer.start()
	
	if show_debug_info:
		debug_display.activate()
	else:
		debug_display.deactivate()

func update_stats():
	var player_manager: PlayerManager = get_node("PlayerManager")
	var player = player_manager.get_character()
	var player_stats = player.stats.get_total()
	var editor_stats = stats_panel.get_total()
	var stats_changed: bool = stats_panel.did_stats_changed()
	if stats_changed:
		player.stats.set_stats(editor_stats[0], editor_stats[1], editor_stats[2], editor_stats[3])
		stats_panel.set_stats(editor_stats[0], editor_stats[1], editor_stats[2], editor_stats[3])
	else:
		stats_panel.set_stats(player_stats[0], player_stats[1], player_stats[2], player_stats[3])


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


func clear_used_rects() -> void:
	used_rects.clear()


func _exit_tree():
	level_manager.clear()
