extends Node2D

@onready var countdown_text_1 = $TextContainer/CountdownText1
@onready var countdown_text_2 = $TextContainer/CountdownText2
@onready var countdown_text_fill = $TextContainer/CountdownText2/CountdownTextFill
@onready var countdown_text_3 = $TextContainer/CountdownText3
@onready var level_type_text_holder = $TextContainer/LevelTypeTextHolder
@onready var level_type_text_1 = $TextContainer/LevelTypeTextHolder/LevelTypeText1
@onready var level_type_text_2 = $TextContainer/LevelTypeTextHolder/LevelTypeText2
@onready var animations = $AnimationPlayer
var countdown_text: String = "GO!"
var level_type_text: String = ""
var played_countdown_sound: bool = false
var play_go_sound: bool = false
var countdown_text_fill_color: Color = Color(1.0, 1.0, 1.0)


func _ready() -> void:
	set_countdown_text(countdown_text)
	set_level_type_text(level_type_text)
	countdown_text_fill.self_modulate = countdown_text_fill_color
	animations.animation_finished.connect(_animation_finished)
	animations.play("countdown")


func set_countdown_text(new_countdown_text: String):
	if new_countdown_text != "":
		countdown_text_1.text = new_countdown_text
		countdown_text_2.text = new_countdown_text
		countdown_text_3.text = new_countdown_text


func set_level_type_text(new_level_type_text: String):
	level_type_text_holder.visible = false
	if new_level_type_text != "":
		level_type_text_1.text = new_level_type_text
		level_type_text_2.text = new_level_type_text
		level_type_text_holder.visible = true


func play_countdown_sound():
	if !played_countdown_sound:
		if play_go_sound:
			Jukebox.play_sound("go")
		else:
			Jukebox.play_sound("ready")
		played_countdown_sound = true


func _animation_finished(_animation_name: String):
	queue_free()
