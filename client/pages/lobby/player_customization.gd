extends Control

@onready var character_display = $CharacterDisplay
@onready var hat_label = $HatSelector/HatLabel
@onready var hat_color_button = $HatSelector/ColorButton
@onready var hat_epic_color_button = $HatSelector/EpicColorButton
@onready var prev_hat_button = $HatSelector/PrevHatButton
@onready var next_hat_button = $HatSelector/NextHatButton
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
var has_hat_epic_color: bool = true
var hat_color: Color = Color("ffffff")
var hat_epic_color: Color = Color("000000")
var has_head_epic_color: bool = true
var head_color: Color = Color("ffffff")
var head_epic_color: Color = Color("000000")
var has_body_epic_color: bool = true
var body_color: Color = Color("ffffff")
var body_epic_color: Color = Color("000000")
var has_feet_epic_color: bool = true
var feet_color: Color = Color("ffffff")
var feet_epic_color: Color = Color("000000")


func _ready() -> void:
	hat_color_button.is_enabled(false)
	hat_epic_color_button.is_enabled(false)
	prev_hat_button.disabled = true
	next_hat_button.disabled = true
	head_color_button.is_enabled(false)
	head_epic_color_button.is_enabled(false)
	prev_head_button.disabled = true
	next_head_button.disabled = true
	body_color_button.is_enabled(false)
	body_epic_color_button.is_enabled(false)
	prev_body_button.disabled = true
	next_body_button.disabled = true
	feet_color_button.is_enabled(false)
	feet_epic_color_button.is_enabled(false)
	prev_feet_button.disabled = true
	next_feet_button.disabled = true
	part_list = parse_list(PARTS_PATH + "00_parts_list.json")
	if part_list:
		hat_color_button.set_color(hat_color)
		hat_epic_color_button.set_color(hat_epic_color)
		hat_color_button.colorbutton_color_changed.connect(_hat_color_changed)
		hat_epic_color_button.colorbutton_color_changed.connect(_hat_epic_color_changed)
		prev_hat_button.pressed.connect(_change_hat.bind(-1))
		next_hat_button.pressed.connect(_change_hat.bind(1))
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
		hat_color_button.is_enabled(true)
		hat_epic_color_button.is_enabled(true)
		prev_hat_button.disabled = false
		next_hat_button.disabled = false
		head_color_button.is_enabled(true)
		head_epic_color_button.is_enabled(true)
		prev_head_button.disabled = false
		next_head_button.disabled = false
		body_color_button.is_enabled(true)
		body_epic_color_button.is_enabled(true)
		prev_body_button.disabled = false
		next_body_button.disabled = false
		feet_color_button.is_enabled(true)
		feet_epic_color_button.is_enabled(true)
		prev_feet_button.disabled = false
		next_feet_button.disabled = false
		_render()


func parse_list(list_location: String) -> Dictionary:
	var json = JSON.new()
	if !json.parse(FileAccess.get_file_as_string(list_location)):
		return json.parse_string(FileAccess.get_file_as_string(list_location))
	else:
		return {}


func _render() -> void:
	var hat_name = part_list.hats.keys()[hat]
	var head_name = part_list.heads.keys()[head]
	var body_name = part_list.bodies.keys()[body]
	var feet_name = part_list.feet.keys()[feet]
	var hat_render_epic_color = Color("000000")
	var head_render_epic_color = Color("000000")
	var body_render_epic_color = Color("000000")
	var feet_render_epic_color = Color("000000")
	
	if has_hat_epic_color:
		hat_render_epic_color = hat_epic_color
	elif part_list.hats[part_list.hats.keys()[hat]].has("hat_default_epic_color"):
		hat_render_epic_color = part_list.hats[part_list.hats.keys()[hat]].hat_default_epic_color
	if has_head_epic_color:
		head_render_epic_color = head_epic_color
	elif part_list.heads[part_list.heads.keys()[head]].has("head_default_epic_color"):
		head_render_epic_color = part_list.heads[part_list.heads.keys()[head]].head_default_epic_color
	if has_body_epic_color:
		body_render_epic_color = body_epic_color
	elif part_list.bodies[part_list.bodies.keys()[body]].has("body_default_epic_color"):
		body_render_epic_color = part_list.bodies[part_list.bodies.keys()[body]].body_default_epic_color
	if has_feet_epic_color:
		feet_render_epic_color = feet_epic_color
	elif part_list.feet[part_list.feet.keys()[feet]].has("feet_default_epic_color"):
		feet_render_epic_color = part_list.feet[part_list.feet.keys()[feet]].feet_default_epic_color
		
	var character_config = {
		"hat": {
			"hat_color": PARTS_PATH + hat_name + "/" + hat_name + "_hat_color.png",
			"hat_lines": PARTS_PATH + hat_name + "/" + hat_name + "_hat_lines.png",
			"hat_epic_color": PARTS_PATH + hat_name + "/" + hat_name + "_hat_epic_color.png",
			"hat_misc1": PARTS_PATH + hat_name + "/" + hat_name + "_hat_misc1.png",
			"hat_misc2": PARTS_PATH + hat_name + "/" + hat_name + "_hat_misc2.png",
			"color": hat_color,
			"epic_color": hat_render_epic_color
		},
		"head": {
			"head_color": PARTS_PATH + head_name + "/" + head_name + "_head_color.png",
			"head_lines": PARTS_PATH + head_name + "/" + head_name + "_head_lines.png",
			"head_epic_color": PARTS_PATH + head_name + "/" + head_name + "_head_epic_color.png",
			"head_misc1": PARTS_PATH + head_name + "/" + head_name + "_head_misc1.png",
			"head_misc2": PARTS_PATH + head_name + "/" + head_name + "_head_misc2.png",
			"color": head_color,
			"epic_color": head_render_epic_color
		},
		"foot_front": {
			"foot_front_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_color.png",
			"foot_front_lines": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_lines.png",
			"foot_front_epic_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_epic_color.png",
			"foot_front_misc1": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_misc1.png",
			"foot_front_misc2": PARTS_PATH + feet_name + "/" + feet_name + "_foot_front_misc2.png",
			"color": feet_color,
			"epic_color": feet_render_epic_color
		},
		"body": {
			"body_color": PARTS_PATH + body_name + "/" + body_name + "_body_color.png",
			"body_lines": PARTS_PATH + body_name + "/" + body_name + "_body_lines.png",
			"body_epic_color": PARTS_PATH + body_name + "/" + body_name + "_body_epic_color.png",
			"body_misc1": PARTS_PATH + body_name + "/" + body_name + "_body_misc1.png",
			"body_misc2": PARTS_PATH + body_name + "/" + body_name + "_body_misc2.png",
			"color": body_color,
			"epic_color": body_render_epic_color
		},
		"foot_back": {
			"foot_back_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_color.png",
			"foot_back_lines": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_lines.png",
			"foot_back_epic_color": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_epic_color.png",
			"foot_back_misc1": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_misc1.png",
			"foot_back_misc2": PARTS_PATH + feet_name + "/" + feet_name + "_foot_back_misc2.png",
			"color": feet_color,
			"epic_color": feet_render_epic_color
		}
	}
	character_display.set_style_from_path(character_config)
	hat_label.text = part_list.hats[part_list.hats.keys()[hat]].hat_name.capitalize()
	head_label.text = part_list.heads[part_list.heads.keys()[head]].head_name.capitalize()
	body_label.text = part_list.bodies[part_list.bodies.keys()[body]].body_name.capitalize()
	feet_label.text = part_list.feet[part_list.feet.keys()[feet]].feet_name.capitalize()
	hat_description_label.text = part_list.hats[part_list.hats.keys()[hat]].hat_description


func _change_hat(by: int):
	if hat + by >= 0 and hat + by <= part_list.hats.size() - 1:
		hat += by
	elif hat + by > 0:
		hat = 0
	else:
		hat = part_list.hats.size() - 1
	_render()


func _hat_color_changed(new_color: Color) -> void:
	hat_color = new_color
	_render()


func _hat_epic_color_changed(new_color: Color) -> void:
	hat_epic_color = new_color
	_render()


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
