extends Control

@onready var check_login_panel = $CheckLoginPanel
@onready var cancel_button = $CheckLogin/CancelButton
@onready var menu_panel = $MenuPanel
@onready var login_panel = $LoginPanel


func _ready():
	menu_panel.visible = false
	login_panel.visible = false
	check_login_panel.visible = false
	Jukebox.play_song("noodletown-4-remake")
	
	#Session.login_success.connect(_update_ui)
	#Session.logout_success.connect(_update_ui)
	
	if Session.is_logged_in():
		login_panel.set_username_string(Session.nickname)
		login_panel.visible = true
	else:
		menu_panel.visible = true
