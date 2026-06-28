extends Control

@onready var import_pr2_level_button = $ImportPR2LevelButton
@onready var check_login_panel = $CheckLoginPanel
@onready var cancel_button = $CheckLogin/CancelButton
@onready var menu_panel = $MenuPanel
@onready var login_panel = $LoginPanel
var file_picker_popup = preload("res://ui/filepicker/filepicker_popup.gd")


func _ready():
	menu_panel.visible = false
	login_panel.visible = false
	check_login_panel.visible = false
	import_pr2_level_button.pressed.connect(_import_pr2_level_pressed)
	Jukebox.play_song("noodletown-4-remake")
	
	#Session.login_success.connect(_update_ui)
	#Session.logout_success.connect(_update_ui)
	
	if Session.is_logged_in():
		login_panel.set_username_string(Session.nickname)
		login_panel.visible = true
	else:
		menu_panel.visible = true


func _import_pr2_level_pressed():
	PopupManager.add_custom_popup(file_picker_popup, {"mode": "load_file", "load_func": Callable(self, "_load_pr2_level"), "extensions_list": ["txt"], "title": "-- Import PR2 Level --"})


func _load_pr2_level(pr2_level_dir: String):
	if FileAccess.file_exists(pr2_level_dir):
		var pr2_level = FileAccess.open(pr2_level_dir, FileAccess.READ)
		var pr2_level_data = pr2_level.get_as_text()
		pr2_level.close()
		Game.local_pr2_level = pr2_level_data
		Main.set_scene(Main.GAME)
