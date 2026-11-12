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

var hat: String = "1"
var head: String = "1"
var body: String = "1"
var feet: String = "1"
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
	CharacterManager.init()
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


func _render() -> void:
	character_display.set_hat_array([{"id": hat, "color": hat_color.to_html(false), "epic_color": hat_epic_color.to_html(false)}])
	character_display.set_head(head, head_color.to_html(false), head_epic_color.to_html(false))
	character_display.set_body(body, body_color.to_html(false), body_epic_color.to_html(false))
	character_display.set_feet(feet, feet_color.to_html(false), feet_epic_color.to_html(false))
	hat_label.text = CharacterManager._parts_lookup.hat.get(hat, {}).get("settings", {}).get("title", "").capitalize()
	head_label.text = CharacterManager._parts_lookup.head.get(head, {}).get("settings", {}).get("title", "").capitalize()
	body_label.text = CharacterManager._parts_lookup.body.get(body, {}).get("settings", {}).get("title", "").capitalize()
	feet_label.text = CharacterManager._parts_lookup.feet.get(feet, {}).get("settings", {}).get("title", "").capitalize()
	hat_description_label.text = CharacterManager._parts_lookup.hat.get(hat, {}).get("settings", {}).get("comment", "")


func _change_hat(by: int):
	var hat_keys = CharacterManager._parts_lookup.hat.keys()
	var hat_index = hat_keys.find(hat)
	if hat_index > -1:
		if hat_index + by >= 0 and hat_index + by < hat_keys.size():
			hat = hat_keys[hat_index + by]
		elif hat_index + by > 0:
			hat = hat_keys[0]
		else:
			hat = hat_keys[hat_keys.size() - 1]
	else:
		hat = hat_keys[0]
	_render()


func _hat_color_changed(new_color: Color) -> void:
	hat_color = new_color
	_render()


func _hat_epic_color_changed(new_color: Color) -> void:
	hat_epic_color = new_color
	_render()


func _change_head(by: int):
	var head_keys = CharacterManager._parts_lookup.head.keys()
	var head_index = head_keys.find(head)
	if head_index > -1:
		if head_index + by >= 0 and head_index + by < head_keys.size():
			head = head_keys[head_index + by]
		elif head_index + by > 0:
			head = head_keys[0]
		else:
			head = head_keys[head_keys.size() - 1]
	else:
		head = head_keys[0]
	_render()


func _head_color_changed(new_color: Color) -> void:
	head_color = new_color
	_render()


func _head_epic_color_changed(new_color: Color) -> void:
	head_epic_color = new_color
	_render()


func _change_body(by: int):
	var body_keys = CharacterManager._parts_lookup.body.keys()
	var body_index = body_keys.find(body)
	if body_index > -1:
		if body_index + by >= 0 and body_index + by < body_keys.size():
			body = body_keys[body_index + by]
		elif body_index + by > 0:
			body = body_keys[0]
		else:
			body = body_keys[body_keys.size() - 1]
	else:
		body = body_keys[0]
	_render()


func _body_color_changed(new_color: Color) -> void:
	body_color = new_color
	_render()


func _body_epic_color_changed(new_color: Color) -> void:
	body_epic_color = new_color
	_render()


func _change_feet(by: int):
	var feet_keys = CharacterManager._parts_lookup.feet.keys()
	var feet_index = feet_keys.find(feet)
	if feet_index > -1:
		if feet_index + by >= 0 and feet_index + by < feet_keys.size():
			feet = feet_keys[feet_index + by]
		elif feet_index + by > 0:
			feet = feet_keys[0]
		else:
			feet = feet_keys[feet_keys.size() - 1]
	else:
		feet = feet_keys[0]
	_render()


func _feet_color_changed(new_color: Color) -> void:
	feet_color = new_color
	_render()


func _feet_epic_color_changed(new_color: Color) -> void:
	feet_epic_color = new_color
	_render()
