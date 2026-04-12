extends Control

signal level_load

const LEVEL_ROW = preload("res://pages/editor/load/level_row.tscn")
var selected_level = ""
var selected_description = ""

@onready var levels_holder = $Levels/LevelsContainer/LevelsHolder


func _ready():
	render()


func render() -> void:
	clear()

	var save_level_array = FileManager.list_saved_levels()
	for level_name in save_level_array:
		var row = LEVEL_ROW.instantiate()
		#row.position.y = levels_holder.get_child_count() * 50
		row.get_node("LevelLabel").text = level_name
		levels_holder.add_child(row)
		var button = row.get_node("Button")
		button.pressed.connect(_row_pressed.bind(level_name))
		if FileManager.get_current_level_name() == level_name:
			button.button_pressed = true


func clear() -> void:
	for child in levels_holder.get_children():
		child.queue_free()


func _load_pressed():
	emit_signal("level_load", selected_level, selected_description)


#func _delete_pressed():
	#if selected_level == "":
		#return
		#
	#FileManager.delete_level(selected_level)
	#for child in row_holder.get_children():
		#var label = child.get_node("LevelLabel")
		#if label.text == selected_level:
			#child.queue_free()
			#break
			#
	#selected_level = ""
	#selected_description = ""

func _row_pressed(level_name: String):
	selected_level = level_name
