extends Control
class_name ButtonPopup

@onready var intrusive_bg = $IntrusiveBG
@onready var popup = $Popup
@onready var default_panel = $Popup/DefaultPanel
@onready var holder = $Popup/Holder
@onready var buttons_holder = $Popup/ButtonsHolder

var intrusive: bool = true
var fade_in_speed: float = 0.12
var target_alpha: float = 1.0
var screen_size: Vector2 = Vector2(1920.0, 1080.0)
var minimum_size: Vector2 = Vector2(90, 90)
var available_size: Vector2 = Vector2(screen_size.x / 1.2, screen_size.y / 1.2)
var padding: Vector2 = Vector2(20.0, 20.0)
var auto_position: bool = true
var die_without_focus = false
var holder_size = Vector2(0.0, 0.0)


func _ready() -> void:
	modulate.a = 0.0
	screen_size = get_viewport().get_visible_rect().size
	popup.focus_exited.connect(_check_focus)
	default_panel.focus_exited.connect(_check_focus)
	holder.focus_exited.connect(_check_focus)
	buttons_holder.focus_exited.connect(_check_focus)
	popup.grab_focus()


func _process(_delta: float) -> void:
	screen_size = get_viewport().get_visible_rect().size
	global_position = Vector2(0.0, 0.0)
	available_size = Vector2(screen_size.x / 1.2, screen_size.y / 1.2)
	#var main_camera = get_viewport().get_camera_2d()
	#if main_camera:
		#scale = Vector2(1, 1) / main_camera.zoom
		#global_position = (main_camera.get_screen_center_position() - ((screen_size / main_camera.zoom) / 2))
	if modulate.a < target_alpha:
		if modulate.a + fade_in_speed > target_alpha:
			modulate.a = target_alpha
		else:
			modulate.a += fade_in_speed
	if intrusive:
		intrusive_bg.size = screen_size
		intrusive_bg.visible = true
	else:
		intrusive_bg.visible = false
	if holder.get_child_count() > 0 and "size" in holder.get_child(0):
		holder.size = holder.get_child(0).size
	else:
		holder.size = holder_size
	holder.position = padding
	buttons_holder.position = Vector2(((holder.position.x + holder.size.x) - buttons_holder.size.x), holder.position.y + holder.size.y + 10.0)
	default_panel.position = Vector2(0.0, 0.0)
	default_panel.size = Vector2(holder.size.x + (padding.x * 2), (buttons_holder.size.y + buttons_holder.position.y) + padding.y)
	popup.size = default_panel.size
	if auto_position:
		popup.position = Vector2((screen_size.x - popup.size.x) / 2, (screen_size.y - popup.size.y) / 2)


func add_node_to_holder(node = null, node_size = null) -> void:
	if node:
		for child in holder.get_children():
			child.free()
		holder.add_child(node)
		if node_size is Vector2:
			holder_size = node_size


func set_dimensions(new_dimensions: Vector2) -> void:
	available_size = Vector2(max(new_dimensions.x, minimum_size.x), max(new_dimensions.y, minimum_size.y))


func position_buttons() -> void:
	var x_space = 0.0
	if buttons_holder.get_child_count() > 0:
		for button in buttons_holder.get_child_count():
			buttons_holder.get_child(button).position.x = x_space + 10
			x_space = buttons_holder.get_child(button).position.x + buttons_holder.get_child(button).size.x
		buttons_holder.size = Vector2(x_space, 30)
	else:
		buttons_holder.size = Vector2(0, 0)


func create_button(button_string: String, button_func = null) -> void:
	var button = Button.new()
	button.size = Vector2(50.0, 30.0)
	button.set("theme_override_font_sizes/font_size", 17)
	button.pressed.connect(_maybe_do_button_func.bind(button_func))
	button.text = button_string
	buttons_holder.add_child(button)
	position_buttons()


func clear_buttons() -> void:
	for button in buttons_holder.get_children():
		button.free()


func _maybe_do_button_func(button_func = null) -> void:
	if button_func is Callable:
		button_func.call()


func _check_focus() -> void:
	var has_focus = false
	if popup.has_focus() or default_panel.has_focus():
		has_focus = true
	elif holder.has_focus() or (holder.get_child_count() > 0 and holder.get_child(0) is Control and holder.get_child(0).has_focus):
		has_focus = true
	elif buttons_holder.has_focus():
		has_focus = true
	else:
		for child in buttons_holder.get_children():
			if child.has_focus():
				has_focus = true
				break
	if !has_focus and die_without_focus:
		queue_free()
