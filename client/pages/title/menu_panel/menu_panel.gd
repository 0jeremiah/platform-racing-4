extends Control

@onready var login_button = $LoginButton
@onready var guest_button = $GuestButton
@onready var create_account_button = $CreateAccountButton
@onready var instructions_button = $InstructionsButton
@onready var credits_button = $CreditsButton
@onready var level_editor_button = $LevelEditorButton
@onready var block_editor_button = $BlockEditorButton
@onready var stamp_editor_button = $StampEditorButton

var login_popup = preload("res://pages/title/login_popup.gd")
var guest_popup = preload("res://pages/title/guest_popup.gd")
var register_popup = preload("res://pages/title/register_popup.gd")
var credits_popup = preload("res://pages/title/credits_popup.gd")


func _ready() -> void:
	login_button.pressed.connect(_on_login_pressed)
	guest_button.pressed.connect(_on_guest_pressed)
	create_account_button.pressed.connect(_on_create_account_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	level_editor_button.pressed.connect(_on_level_editor_pressed)
	block_editor_button.pressed.connect(_on_block_editor_pressed)


func _on_login_pressed():
	PopupManager.add_custom_popup(login_popup)


func _on_guest_pressed():
	PopupManager.add_custom_popup(guest_popup)


func _on_create_account_pressed():
	PopupManager.add_custom_popup(register_popup)


func _on_credits_pressed():
	PopupManager.add_custom_popup(credits_popup)


func _on_level_editor_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)


func _on_block_editor_pressed():
	Main.set_scene(Main.BLOCK_EDITOR)
