extends Control

const LEVEL_ROW = preload("res://pages/editor/load/level_row.tscn")
var selected_folder = ""
var selected_title = ""
var selected_description = ""

var mode = "level"

@onready var levels = $Levels
@onready var levels_holder = $Levels/LevelsContainer/LevelsHolder


func init(new_mode: String):
	mode = new_mode
	render()


func render() -> void:
	levels.visible = false
	clear()
	
	if mode == "level":
		var save_level_array = FileManager.list_saved_levels()
		for level_info in save_level_array:
			var row = LEVEL_ROW.instantiate()
			#row.position.y = levels_holder.get_child_count() * 50
			row.get_node("LevelLabel").text = level_info.title
			if level_info.description != "":
				row.get_node("DescriptionLabel").text = level_info.description
			else:
				row.get_node("DescriptionLabel").text = ""
			levels_holder.add_child(row)
			var button = row.get_node("Button")
			button.pressed.connect(_row_pressed.bind(level_info))
			#if FileManager.get_current_level_folder() == level_info.folder:
				#button.button_pressed = true
			levels.visible = true


func clear() -> void:
	for child in levels_holder.get_children():
		child.queue_free()


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


func _row_pressed(load_info: Dictionary):
	selected_folder = load_info.folder
	selected_title = load_info.title
	selected_description = load_info.description


func get_load_params() -> Dictionary:
	return {"folder": selected_folder, "title": selected_title, "description": selected_description}
