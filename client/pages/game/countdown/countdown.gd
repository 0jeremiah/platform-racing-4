extends Node2D

@onready var countdown_text = preload("res://pages/game/countdown/countdowntext.tscn")
@onready var countdown_box_1 = $CountdownBox1
@onready var countdown_box_2 = $CountdownBox2
@onready var countdown_box_3 = $CountdownBox3

var countdown_time: float = 3.0
var countdown_timer: float = countdown_time + 1.0
var current_countdown: int = int(countdown_time)
var run_countdown: bool = false
var screen_size: Vector2 = Vector2(1920.0, 1080.0)
var fade_mode: String = "fadein"
var alpha: float = 0.0


func _ready() -> void:
	set_countdown_time(5.0)
	start_countdown()


func _process(delta: float):
	if fade_mode == "fadein" or fade_mode == "fadeout":
		if fade_mode == "fadein" and alpha + 0.05 < 1.0:
			alpha += 0.05
		elif fade_mode == "fadeout" and alpha - 0.05 > 0.0:
			alpha -= 0.05
		else:
			if fade_mode == "fadein":
				alpha = 1.0
				fade_mode = "idle"
			if fade_mode == "fadeout":
				alpha = 0.0
				queue_free()
	var viewport = get_viewport()
	if viewport:
		screen_size = viewport.get_visible_rect().size
	countdown_box_1.self_modulate.a = alpha
	countdown_box_2.self_modulate.a = alpha
	countdown_box_3.self_modulate.a = alpha
	countdown_box_1.size.x = screen_size.x
	countdown_box_2.size.x = screen_size.x
	countdown_box_3.size.x = screen_size.x
	countdown_box_1.position = Vector2(0.0, screen_size.y / 20)#(screen_size.y - countdown_box_1.size.y) / 2
	countdown_box_2.position = Vector2(0.0, (screen_size.y / 20) + ((countdown_box_1.size.y - countdown_box_2.size.y) / 2))#(screen_size.y - countdown_box_2.size.y) / 2
	countdown_box_3.position = Vector2(0.0, (screen_size.y / 20) + ((countdown_box_1.size.y - countdown_box_3.size.y) / 2))#(screen_size.y - countdown_box_3.size.y) / 2
	if run_countdown:
		if countdown_timer - (delta * 1.5) > 0:
			countdown_timer -= (delta * 1.5)
			if current_countdown != int(countdown_timer):
				var countdown_node = countdown_text.instantiate()
				if current_countdown - 1 > 0:
					countdown_node.countdown_text = str(current_countdown - 1)
					countdown_node.countdown_text_fill_color = Color(0.419, 0.694, 0.957, 1.0)
				else:
					countdown_node.countdown_text = "GO!"
					countdown_node.level_type_text = "Test Level Type!"
					countdown_node.play_go_sound = true
					countdown_node.countdown_text_fill_color = Color(0.114, 0.641, 0.441, 1.0)
				countdown_node.position = Vector2(screen_size.x / 2, (countdown_box_3.position.y + (countdown_box_3.size.y / 2)) - 25)
				add_child(countdown_node)
				current_countdown = int(countdown_timer)
		else:
			countdown_timer = 0.0
			fade_mode = "fadeout"


func set_countdown_time(new_countdown_time: float):
	countdown_time = new_countdown_time
	countdown_timer = countdown_time + 1.0
	current_countdown = int(countdown_timer)


func start_countdown():
	run_countdown = true
