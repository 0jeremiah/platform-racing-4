extends Control

signal control_event

@onready var settings_tab_bar = $SettingsTabBar
@onready var general_settings = $GeneralSettings
@onready var item_settings = $ItemSettings
@onready var game_configuration = $GameConfiguration

var active: bool = false


func _ready() -> void:
	settings_tab_bar.tab_changed.connect(_set_settings_tab.bind())
	general_settings.music_changed.connect(_play_music)
	general_settings.control_event.connect(_on_control_event)
	item_settings.control_event.connect(_on_control_event)
	_set_settings_tab(0)


func _on_control_event(event: Dictionary) -> void:
	control_event.emit(event)


func deactivate():
	active = false
	Jukebox.stop_song(true)


func activate():
	active = true
	if settings_tab_bar.current_tab == 0:
		_play_music()


func _physics_process(_delta: float) -> void:
	if active:
		visible = true
	else:
		visible = false


func _set_settings_tab(new_tab: int):
	general_settings.visible = false
	item_settings.visible = false
	game_configuration.visible = false
	if new_tab == 0:
		general_settings.visible = true
		if active:
			_play_music()
	if new_tab == 1:
		item_settings.visible = true
		Jukebox.stop_song(true)
	if new_tab == 2:
		game_configuration.visible = true
		Jukebox.stop_song(true)


func _play_music() -> void:
	Jukebox.stop_song(true)
	if general_settings.music != "none":
		if general_settings.music == "random":
			Jukebox.play_song(general_settings.music_list[randi_range(2, general_settings.music_list.size() - 1)])
		else:
			Jukebox.play_song(general_settings.music)


func get_general_settings() -> Dictionary:
	var general_settings_info = {
		"music": general_settings.music,
		"level_type": general_settings.level_type,
		"time": general_settings.time,
		"gravity": general_settings.gravity,
		"password": general_settings.password,
		"sfchm_chance": general_settings.sfchm_chance,
		"wind_chance": general_settings.wind_chance,
		"snow_chance": general_settings.snow_chance,
		"alien_chance": general_settings.alien_chance
		}
	return general_settings_info


func get_item_settings() -> Array:
	return item_settings.item_list


func set_general_settings(new_general_settings: Dictionary):
	general_settings.set_settings(new_general_settings)


func set_item_settings(new_item_settings: Array):
	item_settings.set_item_list(new_item_settings)
