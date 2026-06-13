extends Node2D

@onready var selected_button_panel = $LobbyTab/SelectedButtonPanel
@onready var page_title = $LobbyTab/PageTitle
@onready var page_description = $LobbyTab/PageDescription
@onready var buttons_container = $LobbyTab/ButtonsContainer
@onready var mod_button = $LobbyTab/ButtonsContainer/ModButton/Button
@onready var customize_button = $LobbyTab/ButtonsContainer/CustomizeButton/Button
@onready var single_player_button = $LobbyTab/ButtonsContainer/SinglePlayerButton/Button
@onready var multi_player_button = $LobbyTab/ButtonsContainer/MultiPlayerButton/Button
@onready var chat_button = $LobbyTab/ButtonsContainer/ChatButton/Button
@onready var players_button = $LobbyTab/ButtonsContainer/PlayersButton/Button
@onready var messages_button = $LobbyTab/ButtonsContainer/MessagesButton/Button
@onready var jump_menu_button = $LobbyTab/ButtonsContainer/JumpMenuButton/Button

static var mod_page: String = "mod"
static var customize_page: String = "customize"
static var single_player_page: String = "single_player"
static var multi_player_page: String = "multi_player"
static var chat_page: String = "chat"
static var players_page: String = "players"
static var messages_page: String = "messages"

@onready var button_dictionary: Dictionary = {
	"mod": {"button": mod_button, "title": "Moderate", "description": "Perform knightly tasks", "function": Callable(self, "_set_page"), "page": mod_page},
	"customize": {"button": customize_button, "title": "Customize", "description": "Choose your look, or change your stats", "function": Callable(self, "_set_page"), "page": customize_page},
	"single_player": {"button": single_player_button, "title": "Single Player", "description": "Play levels you have saved locally, or try the campaign", "function": Callable(self, "_set_page"), "page": single_player_page},
	"multi_player": {"button": multi_player_button, "title": "Multi Player", "description": "Race, slice, and blast friends to victory", "function": Callable(self, "_set_page"), "page": multi_player_page},
	"chat": {"button": chat_button, "title": "Chat", "description": "Mingle with the locals", "function": Callable(self, "_set_page"), "page": chat_page},
	"players": {"button": players_button, "title": "Players", "description": "Keep track of who's online, your friends, and people you ignored", "function": Callable(self, "_set_page"), "page": players_page},
	"messages": {"button": messages_button, "title": "Messages", "description": "Read messages people have sent you", "function": Callable(self, "_set_page"), "page": messages_page},
	"jump_menu": {"button": jump_menu_button, "title": "Menu", "description": "Jump to other areas of the game"},
}
var current_page: String = customize_page
var selected_button: String = "customize"


func _ready():
	for button_info in button_dictionary:
		button_dictionary[button_info].button.pressed.connect(_call_button_function.bind(button_info))
		button_dictionary[button_info].button.mouse_entered.connect(_move_tab.bind(button_info))
		button_dictionary[button_info].button.mouse_exited.connect(_move_tab_to_selected_button)


func _call_button_function(button_name: String):
	if button_name in button_dictionary and button_dictionary[button_name].has("function"):
		if button_dictionary[button_name].function.get_argument_count() > 0:
			button_dictionary[button_name].function.call(button_name)
		else:
			button_dictionary[button_name].function.call()


func _move_tab(button_name: String):
	if button_name in button_dictionary:
		selected_button_panel.global_position.x = button_dictionary[button_name].button.global_position.x - 3
		page_title.text = button_dictionary[button_name].title
		page_description.text = button_dictionary[button_name].description


func _set_page(button_name: String):
	if button_name in button_dictionary and button_dictionary[button_name].has("page"):
		current_page = button_dictionary[button_name].page
		selected_button = button_name
		_move_tab(button_name)


func _move_tab_to_selected_button():
	if selected_button in button_dictionary:
		selected_button_panel.global_position.x = button_dictionary[selected_button].button.global_position.x - 3
		page_title.text = button_dictionary[selected_button].title
		page_description.text = button_dictionary[selected_button].description
