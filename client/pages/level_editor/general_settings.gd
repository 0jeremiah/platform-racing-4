extends Control

signal control_event
signal music_changed

@onready var music_button = $MusicSetting/MusicButton
@onready var level_type_button = $LevelTypeSetting/LevelTypeButton
@onready var time_box = $TimeSetting/TimeEdit
@onready var gravity_box = $GravitySetting/GravityEdit
@onready var pass_box = $PassSetting/PassEdit
@onready var sfchm_box = $SFCHMSetting/SFCHMEdit
@onready var wind_box = $WindSetting/WindEdit
@onready var snow_box = $SnowSetting/SnowEdit
@onready var alien_box = $EvilAliensSetting/EvilAliensEdit

var music_list = ["none", "random"]
var music_names = ["None", "Random"]
var composer_names = ["", ""]
var allowed_song_groups = ["pr1", "pr2", "pr3", "pr4", "2024"]
var full_music_list: Dictionary = {}
var music: String = "random"
var level_type_names = ["Race", "Deathmatch", "Hat Attack", "Coin Fiend", "Objective", "Alien Eggs"]
var level_type_ids = ["race", "deathmatch", "hatAttack", "coinFiend", "objective", "alienEggs"]
var level_type_failsafe = ["r", "dm", "d", "h", "obj", "o", "eggs", "e"]
var level_type: String = ""
# should alien eggs be its own game mode or should eggs just be breakable on coin field?
var time: int = 120
var gravity: float = 1.0
var password: String = ""
var sfchm_chance: int = 0
var wind_chance: int = 0
var snow_chance: int = 0
var alien_chance: int = 0


func _ready() -> void:
	full_music_list = Jukebox.get_music_list()
	for song in full_music_list.keys():
		if full_music_list.get(song).group in allowed_song_groups:
			music_list.push_back(song)
			music_names.push_back(full_music_list[song].title)
			composer_names.push_back(full_music_list[song].composer)
	for song_name in music_names:
		music_button.get_popup().add_item(song_name)
	for level_type in level_type_names:
		level_type_button.get_popup().add_item(level_type)
	music_button.get_popup().index_pressed.connect(_set_music.bind())
	level_type_button.get_popup().index_pressed.connect(_set_level_type.bind())
	_set_music(1)
	_set_level_type(0)
	time_box.init("int", "120", 0, 9999)
	time_box.return_string.connect(_set_time.bind())
	gravity_box.init("float", "1", -99, 99)
	gravity_box.return_string.connect(_set_gravity.bind())
	pass_box.init("string")
	pass_box.return_string.connect(_set_password.bind())
	sfchm_box.init("int", "0", 0, 100)
	sfchm_box.return_string.connect(_set_sfchm_chance.bind())
	wind_box.init("int", "0", 0, 100)
	wind_box.return_string.connect(_set_wind_chance.bind())
	snow_box.init("int", "0", 0, 100)
	snow_box.return_string.connect(_set_snow_chance.bind())
	alien_box.init("int", "0", 0, 100)
	alien_box.return_string.connect(_set_alien_chance.bind())


func _on_control_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_MUSIC:
		var musiccheck: int = 0
		while music_list[musiccheck] == event.music or musiccheck < music_list.size():
			musiccheck =+ 1
		if music_list[musiccheck] == event.music:
			_set_music(event.music)
		else:
			_set_music(1)
	if event.type == EditorEvents.SET_TIME:
		_set_time(event.time)


func _set_music(new_index: int):
	music = music_list[new_index]
	music_button.text = music_names[new_index]
	if composer_names[new_index] != "":
		music_button.text = music_button.text + " by " + composer_names[new_index]
	emit_signal("music_changed")


func _set_level_type(new_index: int):
	level_type = level_type_ids[new_index]
	level_type_button.text = level_type_names[new_index]


func _set_time(new_time: String):
	time = int(new_time)
	time_box.text = new_time
	emit_signal("control_event", {
		"type": EditorEvents.SET_TIME,
		"music": time
	})


func _set_gravity(new_gravity: String):
	gravity = float(new_gravity)
	gravity_box.text = new_gravity


func _set_password(new_password: String):
	password = new_password
	pass_box.text = new_password


func _set_sfchm_chance(new_sfchm_chance: String):
	sfchm_chance = int(new_sfchm_chance)
	sfchm_box.text = new_sfchm_chance


func _set_wind_chance(new_wind_chance: String):
	wind_chance = int(new_wind_chance)
	wind_box.text = new_wind_chance


func _set_snow_chance(new_snow_chance: String):
	snow_chance = int(new_snow_chance)
	snow_box.text = new_snow_chance


func _set_alien_chance(new_alien_chance: String):
	alien_chance = int(new_alien_chance)
	alien_box.text = new_alien_chance
