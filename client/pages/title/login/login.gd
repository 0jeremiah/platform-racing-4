extends Control

@onready var username_box = $UsernameBox
@onready var password_box = $PasswordBox
@onready var forgot_password_button = $ForgotPasswordButton
@onready var remember_me_checkbox = $RememberMeCheckbox


func _ready():
	#Session.login_success.connect(_on_login_success)
	#Session.login_failure.connect(_on_login_failure)
	pass


func _on_login_pressed():
	var nickname = username_box.text
	var password = password_box.text
	var remember = remember_me_checkbox.button_pressed
	#Session.login(nickname, password)


func _on_cancel_pressed():
	pass


func _on_login_success():
	pass


func _on_login_failure(error_message):
	pass
	#PopupManager.add_message_popup(error_message)
