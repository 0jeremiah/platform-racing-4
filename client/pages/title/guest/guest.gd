extends Control



func _ready():
	#Session.login_success.connect(_on_login_success)
	#Session.login_failure.connect(_on_login_failure)
	pass


func _on_login_pressed():
	var nickname = "Guest" + str(randi_range(1, 99999))


func _on_cancel_pressed():
	pass


func _on_login_success():
	pass


func _on_login_failure(error_message):
	pass
	#PopupManager.add_message_popup(error_message)
