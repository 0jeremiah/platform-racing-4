extends Control

@onready var save_label = $SaveLabel
@onready var publish_notice_label = $PublishNoticeLabel
@onready var title_box = $TitleBox
@onready var comment_box = $CommentBox
@onready var publish_check_box = $PublishCheckBox
#@onready var http_request = $HTTPRequest

var current_data: Dictionary

var mode = "level"
var is_publish = true


func _ready():
	publish_check_box.pressed.connect(_maybe_publish)


func init(new_mode: String, new_current_data: Dictionary) -> void:
	publish_check_box.visible = false
	publish_notice_label.visible = false
	size = Vector2(400, comment_box.position.y + comment_box.size.y)
	mode = new_mode
	if mode == "level":
		save_label.text = "-- Save Level --"
		title_box.text = FileManager.get_current_level_name_and_description().title
		comment_box.text = FileManager.get_current_level_name_and_description().description
		current_data = new_current_data
		publish_check_box.visible = true
		publish_check_box.position.y = comment_box.position.y + comment_box.size.y + 10
		publish_notice_label.visible = true
		publish_notice_label.position.y = publish_check_box.position.y + publish_check_box.size.y + 10
		size.y = publish_notice_label.position.y + publish_notice_label.size.y
		#save_button.connect("pressed", func() -> void:
			#_save_pressed(current_data)
		#)
	elif mode == "block":
		save_label.text = "-- Save Block --"
		#title_box.text = FileManager.get_current_level_name()
		#comment_box.text = FileManager.get_current_level_description()
		current_data = new_current_data
		publish_notice_label.visible = true
		publish_notice_label.position.y = comment_box.position.y + comment_box.size.y + 10
		size.y = publish_notice_label.position.y + publish_notice_label.size.y


func _maybe_publish() -> void:
	is_publish = publish_check_box.button_pressed

# Move this to level editor.
#func _save_pressed(current_level: Dictionary):
	#if title_edit.text == "":
		#return
	#
	#LevelEditor.current_level_name = title_edit.text
	#LevelEditor.current_level_description = description_edit.text
	#current_level.get_or_add("title")
	#current_level.title = title_edit.text
	#current_level.get_or_add("description")
	#current_level.description = description_edit.text
	#var encoded_string = FileManager.save_level_to_file(current_level, title_edit.text)
	#
	#var post_data = {
		#"level_data": encoded_string,
	#}
#
	#var json_string = JSON.stringify(post_data)
	#var url = ApiManager.get_base_url() + "/save_level"
#
	#if is_publish:
		#var error = $HTTPRequest.request(url, [], HTTPClient.METHOD_POST, json_string)
		#if error != OK:
			#push_error("An error occurred in the HTTP request.")
	#
	#self.visible = false
#
#func _on_request_completed(result, response_code, headers, body):
	#if result != HTTPRequest.RESULT_SUCCESS:
		#print("Failed to save level. Result: ", result)
		#return
#
	#if response_code == 200:
		#print("Level saved successfully!")
	#else:
		#print("Error saving level. Server responded with code: ", response_code)
