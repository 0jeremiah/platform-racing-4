extends Control

signal control_event
signal music_changed

@onready var music_button = $MusicSetting/MusicButton
@onready var level_type_button = $LevelTypeSetting/LevelTypeButton
@onready var time_box = $TimeSetting/TimeEdit
@onready var gravity_box = $GravitySetting/GravityEdit
@onready var password_box = $PasswordSetting/PasswordEdit
@onready var sfchm_box = $SFCHMSetting/SFCHMEdit
@onready var wind_box = $WindSetting/WindEdit
@onready var snow_box = $SnowSetting/SnowEdit
@onready var alien_box = $EvilAliensSetting/EvilAliensEdit

var music_list = ["none", "random"]
var music_names = ["None", "Random"]
var composer_names = ["", ""]
var allowed_song_groups = []
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
	allowed_song_groups = Jukebox.race_song_groups
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
	music = music_list[1]
	music_button.text = music_names[1]
	level_type = level_type_ids[0]
	level_type_button.text = level_type_names[0]
	time_box.init("int", "120", 0, 9999)
	time_box.return_line.connect(_set_time.bind())
	gravity_box.init("float", "1.0", -99.0, 99.0)
	gravity_box.return_line.connect(_set_gravity.bind())
	password_box.init("string")
	password_box.return_line.connect(_set_password.bind())
	sfchm_box.init("int", "0", 0, 100)
	sfchm_box.return_line.connect(_set_sfchm_chance.bind())
	wind_box.init("int", "0", 0, 100)
	wind_box.return_line.connect(_set_wind_chance.bind())
	snow_box.init("int", "0", 0, 100)
	snow_box.return_line.connect(_set_snow_chance.bind())
	alien_box.init("int", "0", 0, 100)
	alien_box.return_line.connect(_set_alien_chance.bind())


func _set_music(new_index: int):
	music = music_list[new_index]
	music_button.text = music_names[new_index]
	if composer_names[new_index] != "":
		music_button.text = music_button.text + " by " + composer_names[new_index]
	emit_signal("control_event", {
		"type": EditorEvents.SET_MUSIC,
		"music": music
	})
	emit_signal("music_changed")


func _set_level_type(new_index: int):
	level_type = level_type_ids[new_index]
	level_type_button.text = level_type_names[new_index]
	emit_signal("control_event", {
		"type": EditorEvents.SET_LEVEL_TYPE,
		"level_type": level_type
	})


func _set_time(new_time: int):
	if time != 0 and time >= 3:
		time = new_time
	elif time == 0:
		time = 0
	else:
		time = 3
	emit_signal("control_event", {
		"type": EditorEvents.SET_TIME,
		"time": time
	})


func _set_gravity(new_gravity: float):
	gravity = new_gravity
	emit_signal("control_event", {
		"type": EditorEvents.SET_GRAVITY,
		"gravity": gravity
	})


func _set_password(new_password: String):
	password = new_password
	emit_signal("control_event", {
		"type": EditorEvents.SET_PASSWORD,
		"password": password
	})


func _set_sfchm_chance(new_sfchm_chance: int):
	sfchm_chance = new_sfchm_chance
	emit_signal("control_event", {
		"type": EditorEvents.SET_SFCHM_CHANCE,
		"sfchm_chance": sfchm_chance
	})


func _set_wind_chance(new_wind_chance: int):
	wind_chance = new_wind_chance
	emit_signal("control_event", {
		"type": EditorEvents.SET_WIND_CHANCE,
		"wind_chance": wind_chance
	})


func _set_snow_chance(new_snow_chance: int):
	snow_chance = new_snow_chance
	emit_signal("control_event", {
		"type": EditorEvents.SET_SNOW_CHANCE,
		"snow_chance": snow_chance
	})


func _set_alien_chance(new_alien_chance: int):
	alien_chance = new_alien_chance
	emit_signal("control_event", {
		"type": EditorEvents.SET_ALIEN_CHANCE,
		"alien_chance": alien_chance
	})


func set_settings(new_settings: Dictionary):
	if new_settings.has("music"):
		if music_list.has(new_settings.music):
			var index = music_list.find(new_settings.music)
			music = music_list[index]
			music_button.text = music_names[index]
			if composer_names[index] != "":
				music_button.text = music_button.text + " by " + composer_names[index]
		else:
			music = music_list[1]
			music_button.text = music_names[1]
	if new_settings.has("level_type"):
		if level_type_ids.has(new_settings.level_type):
			var index = level_type_ids.find(new_settings.level_type)
			level_type = level_type_ids[index]
			level_type_button.text = level_type_names[index]
		elif level_type_failsafe.has(new_settings.level_type):
			var index: int = 0
			match new_settings.level_type:
				"r": index = level_type_ids.find("race")
				"d": index = level_type_ids.find("deathmatch")
				"h": index = level_type_ids.find("hatAttack")
				"obj", "o": index = level_type_ids.find("objective")
				"eggs", "e": index = level_type_ids.find("alienEggs")
			level_type = level_type_ids[index]
			level_type_button.text = level_type_names[index]
		else:
			level_type = level_type_ids[0]
			level_type_button.text = level_type_names[0]
	if new_settings.has("time"):
		time = new_settings.time
		time_box._update_text(str(time))
	if new_settings.has("gravity"):
		gravity = new_settings.gravity
		gravity_box._update_text(str(gravity))
	if new_settings.has("password"):
		password = new_settings.password
		password_box._update_text(str(password))
	if new_settings.has("sfchm_chance"):
		sfchm_chance = new_settings.sfchm_chance
		sfchm_box._update_text(str(sfchm_chance))
	if new_settings.has("wind_chance"):
		wind_chance = new_settings.wind_chance
		wind_box._update_text(str(wind_chance))
	if new_settings.has("snow_chance"):
		snow_chance = new_settings.snow_chance
		snow_box._update_text(str(snow_chance))
	if new_settings.has("alien_chance"):
		alien_chance = new_settings.alien_chance
		alien_box._update_text(str(alien_chance))
