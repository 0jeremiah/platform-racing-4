extends Control

@onready var welcome_label = $WelcomeLabel
@onready var server_button = $ServerDropdownButton
@onready var login_button = $LoginButton
@onready var level_editor_button = $LevelEditorButton
@onready var block_editor_button = $BlockEditorButton
@onready var stamp_editor_button = $StampEditorButton
@onready var user_settings_button = $UserSettingsButton
@onready var credits_button = $CreditsButton
@onready var logout_button = $LogoutButton

var login_popup = preload("res://pages/title/login_popup.gd")
var guest_popup = preload("res://pages/title/guest_popup.gd")
var register_popup = preload("res://pages/title/register_popup.gd")
var credits_popup = preload("res://pages/title/credits_popup.gd")


func _ready() -> void:
	login_button.pressed.connect(_on_login_pressed)
	level_editor_button.pressed.connect(_on_level_editor_pressed)
	block_editor_button.pressed.connect(_on_block_editor_pressed)
	user_settings_button.pressed.connect(_on_user_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	logout_button.pressed.connect(_on_logout_pressed)


func set_username_string(username: String):
	welcome_label.text = "Welcome, " + username + "!"


func _on_login_pressed():
	pass


func _on_guest_pressed():
	PopupManager.add_custom_popup(guest_popup)


func _on_create_account_pressed():
	PopupManager.add_custom_popup(register_popup)


func _on_level_editor_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)


func _on_block_editor_pressed():
	Main.set_scene(Main.BLOCK_EDITOR)


func _on_credits_pressed():
	PopupManager.add_custom_popup(credits_popup)


func _on_logout_pressed():
	PopupManager.add_confirm_popup(Callable(self, "_confirm_logout"), "Are you sure you want to log out?")


func _confirm_logout():
	#Session.logout()
	pass


func _on_user_settings_pressed():
	Main.set_scene(Main.USER_SETTINGS)
