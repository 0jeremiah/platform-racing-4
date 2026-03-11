extends Control

@onready var character_display = $CharacterDisplay
@onready var hat_label = $HatSelector/HatLabel
@onready var hat_color_button = $HatSelector/ColorButton
@onready var hat_epic_color_button = $HatSelector/EpicColorButton
@onready var prev_hat_button = $HatSelector/PrevHeadButton
@onready var next_hat_button = $HatSelector/NextHeadButton
@onready var head_label = $HeadSelector/HeadLabel
@onready var head_color_button = $HeadSelector/ColorButton
@onready var head_epic_color_button = $HeadSelector/EpicColorButton
@onready var prev_head_button = $HeadSelector/PrevHeadButton
@onready var next_head_button = $HeadSelector/NextHeadButton
@onready var body_label = $BodySelector/BodyLabel
@onready var body_color_button = $BodySelector/ColorButton
@onready var body_epic_color_button = $BodySelector/EpicColorButton
@onready var prev_body_button = $BodySelector/PrevBodyButton
@onready var next_body_button = $BodySelector/NextBodyButton
@onready var feet_label = $FeetSelector/FeetLabel
@onready var feet_color_button = $FeetSelector/ColorButton
@onready var feet_epic_color_button = $FeetSelector/EpicColorButton
@onready var prev_feet_button = $FeetSelector/PrevFeetButton
@onready var next_feet_button = $FeetSelector/NextFeetButton
@onready var hat_description_label = $HatDescriptionLabel

const PARTS_PATH = "res://character_display/parts/"
var part_list = {}
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
	part_list = parse_list(PARTS_PATH + "00_parts_list.json")
	if part_list:
		hat_color_button.set_color(hat_color)
		hat_epic_color_button.set_color(hat_epic_color)
		hat_color_button.is_enabled(false)
		hat_epic_color_button.is_enabled(false)
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


func parse_list(list_location: String) -> Dictionary:
	var list_string = FileAccess.get_file_as_string(list_location)
	var json = JSON.new()
	var list_data = json.parse_string(list_string)
	if list_data:
		print("PlayerCustomization::_ready() - file (" + list_location + ") obtained successfully!")
		return list_data
	else:
		print("PlayerCustomization::_ready() - failed to get list from (" + list_location + ") :(")
		return {}


func _render() -> void:
	var head_name = part_list.heads[part_list.heads.keys()[head]].head_name
	var body_name = part_list.bodies[part_list.bodies.keys()[body]].body_name
	var feet_name = part_list.feet[part_list.feet.keys()[feet]].feet_name
	var character_config = {
		"head": {
			"head_color": PARTS_PATH + head_name + "/" + head_name + "_head_color.png",
			"head_lines": PARTS_PATH + head_name + "/" + head_name + "_head_lines.png",
			"head_epic_color": PARTS_PATH + head_name + "/" + head_name + "_head_epic_color.png",
			"head_misc1": PARTS_PATH + head_name + "/" + head_name + "_head_misc1.png",
			"color": head_color,
			"epic_color": head_epic_color
		},
		"foot_front": {
			"foot_front_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_color.png",
			"foot_front_lines": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_lines.png",
			"foot_front_epic_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_epic_color.png",
			"foot_front_misc1": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_misc1.png",
			"color": feet_color,
			"epic_color": feet_epic_color
		},
		"body": {
			"body_color": PARTS_PATH + body_name + "/" + body_name + "_body_color.png",
			"body_lines": PARTS_PATH + body_name + "/" + body_name + "_body_lines.png",
			"body_epic_color": PARTS_PATH + body_name + "/" + body_name + "_body_epic_color.png",
			"body_misc1": PARTS_PATH + body_name + "/" + body_name + "_body_misc1.png",
			"color": body_color,
			"epic_color": body_epic_color
		},
		"foot_back": {
			"foot_back_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_color.png",
			"foot_back_lines": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_lines.png",
			"foot_back_epic_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_epic_color.png",
			"foot_back_misc1": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_misc1.png",
			"color": feet_color,
			"epic_color": feet_epic_color
		}
	}
	character_display.set_style_from_path(character_config)
	hat_label.text = part_list.hats[part_list.hats.keys()[hat]].hat_name.capitalize()
	head_label.text = part_list.heads[part_list.heads.keys()[head]].head_name.capitalize()
	body_label.text = part_list.bodies[part_list.bodies.keys()[body]].body_name.capitalize()
	feet_label.text = part_list.feet[part_list.feet.keys()[feet]].feet_name.capitalize()
	hat_description_label.text = part_list.hats[part_list.hats.keys()[hat]].hat_description


func _change_head(by: int):
	if head + by >= 0 and head + by <= part_list.heads.size() - 1:
		head += by
	elif head + by > 0:
		head = 0
	else:
		head = part_list.heads.size() - 1
	_render()


func _head_color_changed(new_color: Color) -> void:
	head_color = new_color
	_render()


func _head_epic_color_changed(new_color: Color) -> void:
	head_epic_color = new_color
	_render()


func _change_body(by: int):
	if body + by >= 0 and body + by <= part_list.bodies.size() - 1:
		body += by
	elif body + by > 0:
		body = 0
	else:
		body = part_list.bodies.size() - 1
	_render()


func _body_color_changed(new_color: Color) -> void:
	body_color = new_color
	_render()


func _body_epic_color_changed(new_color: Color) -> void:
	body_epic_color = new_color
	_render()


func _change_feet(by: int):
	if feet + by >= 0 and feet + by <= part_list.feet.size() - 1:
		feet += by
	elif feet + by > 0:
		feet = 0
	else:
		feet = part_list.feet.size() - 1
	_render()


func _feet_color_changed(new_color: Color) -> void:
	feet_color = new_color
	_render()


func _feet_epic_color_changed(new_color: Color) -> void:
	feet_epic_color = new_color
	_render()
