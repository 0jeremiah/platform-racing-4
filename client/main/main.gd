extends Control
class_name Main

const TestRunner = preload("res://test_runner.gd")

static var FILE_URL = "https://files.platformracing.com"
static var instance: Main

# page names
const TITLE = "TITLE"
const CREDITS = "CREDITS"
const SOLO = "SOLO"
const LOBBY = "LOBBY"
const GAME = "GAME"
const TESTER = "TESTER"
const LOGIN = "LOGIN"
const REGISTER = "REGISTER"
const USER_SETTINGS = "USER_SETTINGS"
const LEVEL_EDITOR = "LEVEL_EDITOR"
const BLOCK_EDITOR = "BLOCK_EDITOR"
const CHARACTER_EDITOR = "CHARACTER_EDITOR"

var scenes = {
	TITLE: preload("res://pages/title/title.tscn"),
	CREDITS: preload("res://pages/credits/credits.tscn"),
	
	SOLO: preload("res://pages/solo/solo.tscn"),
	LOBBY: preload("res://pages/level_lists/lobby.tscn"),
	
	GAME: preload("res://pages/game/game.tscn"),
	TESTER: preload("res://pages/tester/tester.tscn"),
	
	LOGIN: preload("res://pages/login/login.tscn"),
	REGISTER: preload("res://pages/register/register.tscn"),
	USER_SETTINGS: preload("res://pages/user_settings/user_settings.tscn"),
	
	LEVEL_EDITOR: preload("res://pages/editor/level_editor/level_editor.tscn"),
	BLOCK_EDITOR: preload("res://pages/editor/block_editor/block_editor.tscn"),
	CHARACTER_EDITOR: preload("res://pages/editor/character_editor/character_editor.tscn")
}

@onready var game_client: Node2D = $GameClient
var current_scene: Node


func _init():
	var test_runner = TestRunner.new()
	test_runner.name = "TestRunner"
	add_child(test_runner)


func _ready():
	Main.instance = self
	if await TestRunner.run_tests(self):
		return

	ParticleManager.init_particles()
	await set_scene(TITLE)
	#PopupManager.add_message_popup("Welcome to Platform Racing 4! This game is currently in alpha status, and it's being worked on by Jiggmin and a few other contributors. If you would like to help, please go to our github!\n\nhttps://github.com/jacob-grahn/platform-racing-4")


static func set_scene(scene_name: String, data: Dictionary = {}) -> Node:
	if !instance:
		return null
	return await instance._set_scene(scene_name, data)


func _set_scene(scene_name: String, data: Dictionary = {}) -> Node:
	if current_scene:
		current_scene.queue_free()
	
	await get_tree().process_frame

	current_scene = scenes[scene_name].instantiate()
	current_scene.name = scene_name
	add_child(current_scene)
	
	if current_scene.has_method("init"):
		current_scene.init(data)

	return current_scene
