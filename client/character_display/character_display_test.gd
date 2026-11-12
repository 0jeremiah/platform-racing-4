extends Node2D
## Test scene for character display customization.
## Allows testing different character styles with color pickers.

const NEW_BODY_IDS = ['1', '2']
var BASE_URL = Main.FILE_URL + "/characters"
@onready var head_color_picker_button: ColorPickerButton = $HeadColorPickerButton
@onready var body_color_picker_button: ColorPickerButton = $BodyColorPickerButton
@onready var feet_color_picker_button: ColorPickerButton = $FeetColorPickerButton
@onready var randomize_button: Button = $RandomizeButton
@onready var character_display: CharacterDisplay = $CharacterDisplay


func _ready() -> void:
	head_color_picker_button.color_changed.connect(_color_changed)
	body_color_picker_button.color_changed.connect(_color_changed)
	feet_color_picker_button.color_changed.connect(_color_changed)
	randomize_button.pressed.connect(_randomize_button_pressed)
	_randomize()


# Update character display with selected config from UI
func _render() -> void:
	var head_textures = CharacterManager.get_part_textures(_random_body(), "head")
	character_display.set_head_style(head_textures)
	var body_textures = CharacterManager.get_part_textures(_random_body(), "body")
	character_display.set_body_style(body_textures)
	var foot_front_textures = CharacterManager.get_part_textures(_random_body(), "foot_front")
	character_display.set_foot_front_style(foot_front_textures)
	var foot_back_textures = CharacterManager.get_part_textures(_random_body(), "foot_back")
	character_display.set_body_style(foot_back_textures)
	character_display.set_head_color(head_color_picker_button.color.to_html(false), "000000")
	character_display.set_body_color(body_color_picker_button.color.to_html(false), "000000")
	character_display.set_feet_color(feet_color_picker_button.color.to_html(false), "000000")


# Triggered when a color picker value changes
func _color_changed(_color: Color) -> void:
	_render()


# Generate a random color
func _random_color() -> Color:
	return Color(
		randf(),
		randf(),
		randf()
	)


# Get a random body type from available options
func _random_body() -> String:
	var i = randi_range(0, len(NEW_BODY_IDS) - 1)
	return NEW_BODY_IDS[i]


func _randomize_button_pressed() -> void:
	_randomize()


func _randomize() -> void:
	head_color_picker_button.color = _random_color()
	body_color_picker_button.color = _random_color()
	feet_color_picker_button.color = _random_color()
	_render()
