extends Control

@onready var username_box = $UsernameBox
@onready var password_box = $PasswordBox
@onready var confirm_password_box = $ConfirmPasswordBox
@onready var email_box = $EmailBox


func _ready():
	#Session.login_success.connect(_on_login_success)
	#Session.login_failure.connect(_on_login_failure)
	pass


func _on_register_pressed():
	var nickname = username_box.text
	var password = password_box.text
	var confirm_password = confirm_password_box.text
	var email = email_box.text
	#Session.login(nickname, password)


func _on_cancel_pressed():
	pass


func _on_register_success():
	pass


func _on_register_failure(error_message):
	pass
	#PopupManager.add_message_popup(error_message)
