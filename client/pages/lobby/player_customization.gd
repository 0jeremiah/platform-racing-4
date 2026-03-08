extends Control

@onready var character_display = $CharacterDisplay
@onready var head_color_button = $HeadSelector/ColorButton
@onready var head_epic_color_button = $HeadSelector/EpicColorButton
@onready var prev_head_button = $HeadSelector/PrevHeadButton
@onready var next_head_button = $HeadSelector/NextHeadButton
@onready var body_color_button = $BodySelector/ColorButton
@onready var body_epic_color_button = $BodySelector/EpicColorButton
@onready var prev_body_button = $BodySelector/PrevBodyButton
@onready var next_body_button = $BodySelector/NextBodyButton
@onready var feet_color_button = $FeetSelector/ColorButton
@onready var feet_epic_color_button = $FeetSelector/EpicColorButton
@onready var prev_feet_button = $FeetSelector/PrevFeetButton
@onready var next_feet_button = $FeetSelector/NextFeetButton

const HAT_IDS = ['none', 'exp']
const HEAD_IDS = ['classic', 'tired']
const BODY_IDS = ['classic', 'tired']
const FEET_IDS = ['classic', 'tired']
var STYLE_PATH = "res://character_display/styles/"
var hat: int = 0
var head: int = 0
var body: int = 0
var feet: int = 0
var hat_color: Color = Color("FFFFFF")
var hat_epic_color: Color = Color("000000")
var head_color: Color = Color("FFFFFF")
var head_epic_color: Color = Color("000000")
var body_color: Color = Color("FFFFFF")
var body_epic_color: Color = Color("000000")
var feet_color: Color = Color("FFFFFF")
var feet_epic_color: Color = Color("000000")


func _ready() -> void:
	head_color_button.set_color(head_color)
	head_epic_color_button.set_color(head_epic_color)
	head_color_button.colorbutton_color_changed.connect(_head_color_changed)
	head_epic_color_button.colorbutton_color_changed.connect(_head_epic_color_changed)
	prev_head_button.pressed.connect(_change_head.bind(-1))
	next_head_button.pressed.connect(_change_head.bind(1))
	body_color_button.set_color(body_color)
	body_epic_color_button.set_color(body_epic_color)
	body_color_button.colorbutton_color_changed.connect(_body_color_changed)
	body_epic_color_button.colorbutton_color_changed.connect(_body_epic_color_changed)
	prev_body_button.pressed.connect(_change_body.bind(-1))
	next_body_button.pressed.connect(_change_body.bind(1))
	feet_color_button.set_color(feet_color)
	feet_epic_color_button.set_color(feet_epic_color)
	feet_color_button.colorbutton_color_changed.connect(_feet_color_changed)
	feet_epic_color_button.colorbutton_color_changed.connect(_feet_epic_color_changed)
	prev_feet_button.pressed.connect(_change_feet.bind(-1))
	next_feet_button.pressed.connect(_change_feet.bind(1))
	_render()


func _render() -> void:
	var head_name = HEAD_IDS[head]
	var body_name = BODY_IDS[body]
	var feet_name = FEET_IDS[feet]
	var character_config = {
		"head": {
			"head_color": STYLE_PATH + head_name + "/" + head_name + "_head_color.png",
			"head_lines": STYLE_PATH + head_name + "/" + head_name + "_head_lines.png",
			"head_epic_color": STYLE_PATH + head_name + "/" + head_name + "_head_epic_color.png",
			"head_misc1": STYLE_PATH + head_name + "/" + head_name + "_head_misc1.png",
			"color": head_color,
			"epic_color": head_epic_color
		},
		"body": {
			"body_color": STYLE_PATH + body_name + "/" + body_name + "_body_color.png",
			"body_lines": STYLE_PATH + body_name + "/" + body_name + "_body_lines.png",
			"body_epic_color": STYLE_PATH + body_name + "/" + body_name + "_body_epic_color.png",
			"body_misc1": STYLE_PATH + body_name + "/" + body_name + "_body_misc1.png",
			"color": body_color,
			"epic_color": body_epic_color
		},
		"foot": {
			"foot_color": STYLE_PATH + feet_name + "/" + feet_name + "_foot_color.png",
			"foot_lines": STYLE_PATH + feet_name + "/" + feet_name + "_foot_lines.png",
			"foot_epic_color": STYLE_PATH + feet_name + "/" + feet_name + "_foot_epic_color.png",
			"foot_misc1": STYLE_PATH + feet_name + "/" + feet_name + "_foot_misc1.png",
			"color": feet_color,
			"epic_color": feet_epic_color
		}
	}
	character_display.set_style_from_path(character_config)


func _change_head(by: int):
	if head + by >= 0 and head + by <= HEAD_IDS.size() - 1:
		head += by
	elif head + by > 0:
		head = 0
	else:
		head = HEAD_IDS.size() - 1
	_render()


func _head_color_changed(new_color: Color) -> void:
	head_color = new_color
	_render()


func _head_epic_color_changed(new_color: Color) -> void:
	head_epic_color = new_color
	_render()


func _change_body(by: int):
	if body + by >= 0 and body + by <= BODY_IDS.size() - 1:
		body += by
	elif body + by > 0:
		body = 0
	else:
		body = BODY_IDS.size() - 1
	_render()


func _body_color_changed(new_color: Color) -> void:
	body_color = new_color
	_render()


func _body_epic_color_changed(new_color: Color) -> void:
	body_epic_color = new_color
	_render()


func _change_feet(by: int):
	if feet + by >= 0 and feet + by <= FEET_IDS.size() - 1:
		feet += by
	elif feet + by > 0:
		feet = 0
	else:
		feet = FEET_IDS.size() - 1
	_render()


func _feet_color_changed(new_color: Color) -> void:
	feet_color = new_color
	_render()


func _feet_epic_color_changed(new_color: Color) -> void:
	feet_epic_color = new_color
	_render()
