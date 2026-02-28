extends Control
class_name GameTimer

signal increase_time(new_timer: float)

@onready var timer_text = $TimeText

var time: float = 120.0
var timer: float = 120.0
var stopwatch: float = 0.0
var pause: bool = true
var game = null
var player: Character = null


func init(game_scene):
	game = game_scene
	player = game_scene.get_node("PlayerManager").get_character()
	player.connect("increase_time", _inc_timer)


func _physics_process(delta: float) -> void:
	if !pause:
		if time > 0:
			if timer - delta > 0:
				timer -= delta
			elif !player.movement.finished:
				player.movement.finished = true
		else:
			stopwatch += delta
	update_display()


func update_display():
	var current_timer: float = 0.0
	if time > 0:
		current_timer = timer
	else:
		current_timer = stopwatch
	var counter = 0
	var hours = 0
	var minutes = 0
	var seconds = 0
	var milliseconds = 0
	var time_string = ""
	while 3600 * (counter + 1) < current_timer:
		counter += 1
		hours += 1
	counter = 0
	while 60 * (counter + 1) < (current_timer - (3600 * hours)):
		counter += 1
		minutes += 1
	counter = 0
	while 1 * (counter + 1) < (current_timer - ((3600 * hours) + (60 * minutes))):
		counter += 1
		seconds += 1
	counter = 0
	while 0.001 * (counter + 1) < (current_timer - ((3600 * hours) + (60 * minutes) + (1 * seconds))):
		counter += 1
		milliseconds += 1
	var minutestext = ""
	var secondstext = ""
	var millisecondstext = ""
	if len(str(minutes)) > 1:
		minutestext = str(minutes)
	else:
		minutestext = "0" + str(minutes)
	if len(str(seconds)) > 1:
		secondstext = str(seconds)
	else:
		secondstext = "0" + str(seconds)
	if len(str(milliseconds)) > 2:
		millisecondstext = str(milliseconds)
	elif len(str(milliseconds)) > 1:
		millisecondstext = "0" + str(milliseconds)
	else:
		millisecondstext = "00" + str(milliseconds)
	if hours > 0:
		time_string = str(hours) + ":" + minutestext + ":" + secondstext + "." + millisecondstext
	else:
		time_string = minutestext + ":" + secondstext + "." + millisecondstext
	timer_text.text = time_string


func set_timer(new_time: float):
	time = new_time


func _inc_timer(increment: float):
	if time > 0:
		timer += increment
	else:
		stopwatch += increment


func start_timer():
	timer = time
	stopwatch = 0.0
	pause = false


func pause_timer(switch: bool):
	pause = switch
