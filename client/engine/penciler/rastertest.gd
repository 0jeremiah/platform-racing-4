extends Node2D

@onready var drawer = $Drawer
@onready var lines = $ArtContainer/ArtViewport/Lines
var previous_cursor_position: Vector2 = Vector2(0, 0)
var current_cursor_position: Vector2 = Vector2(0, 0)
var image = Image.new() #.load_from_file("res://stamps/CactusGraphic.svg")
var mouse_clicked: bool = false
var mode = "idle"
var color: Color = Color("000000ff")


func _ready() -> void:
	current_cursor_position = get_global_mouse_position()
	previous_cursor_position = current_cursor_position
	#bg.texture = ImageTexture.new()
	#image = Image.create_empty(1920, 1080, false, Image.FORMAT_RGBA8)
	#image.fill(Color("FFFFFFFF"))
	#image.set_pixel(60, 60, Color.RED)
	#bg.texture.set_image(image)
	#global_position = Vector2(image.get_width() / 2, image.get_height() / 2)

func _process(delta: float) -> void:
	current_cursor_position = get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !mouse_clicked:
			if Input.is_key_pressed(KEY_SPACE):
				mode = "erase"
				color = Color("ffffffff")
			elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				mode = "draw"
				color = Color("000000ff")
		drawer._draw_line(current_cursor_position, color, 5)
		mouse_clicked = true
	else:
		mouse_clicked = false
	
	if !mouse_clicked and mode != "idle":
		var line = drawer._get_line(mode)
		if line != null and line is Line2D:
			lines.add_child(line)
			drawer._clear()
		mode = "idle"
	previous_cursor_position = current_cursor_position
	#bg.texture.update(image)
