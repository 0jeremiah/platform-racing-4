extends Control

signal set_new_slider_value

@onready var slider_line_edit = $SliderLineEdit
@onready var slider = $Slider
@onready var ok_button = $OKButton
var slider_value = 10
var old_size_box_text: String = "0"
var is_int: bool = true


func _ready() -> void:
	slider_line_edit.text_changed.connect(_set_size_value)
	slider.value_changed.connect(_set_size_value)
	slider_line_edit.text = str(slider_value)
	slider.value = slider_value
	ok_button.pressed.connect(_set_new_size_value.bind(true))


func init(init_dictionary: Dictionary):
	if "is_int" in init_dictionary and init_dictionary.is_int is bool:
		is_int = init_dictionary.is_int
		slider.rounded = is_int
	if "min_value" in init_dictionary and (init_dictionary.min_value is float or init_dictionary.min_value is int):
		slider.min_value = float(init_dictionary.min_value)
	if "max_value" in init_dictionary and (init_dictionary.max_value is float or init_dictionary.max_value is int):
		slider.max_value = float(init_dictionary.max_value)
	if "current_value" in init_dictionary and (init_dictionary.current_value is float or init_dictionary.current_value is int):
		_set_size_value(float(init_dictionary.current_value), is_int)


func _set_size_value(new_size: float, send_signal: bool = true, close_slider_popup: bool = false):
	var compatible_new_size = new_size
	if is_int:
		compatible_new_size = int(compatible_new_size)
	var new_size_string = str(compatible_new_size)
	var min_value = slider.min_value if !is_int else int(slider.min_value)
	var max_value = slider.max_value if !is_int else int(slider.max_value)
	var cursor_position = slider_line_edit.get_caret_column()
	if !new_size_string.is_empty() and (new_size_string.is_valid_float() or new_size_string.is_valid_int()):
		if (compatible_new_size >= min_value and compatible_new_size <= max_value):
			slider_value = compatible_new_size if compatible_new_size is float else float(compatible_new_size)
		elif compatible_new_size > max_value:
			slider_value = max_value if max_value is float else float(max_value)
		else:
			slider_value = min_value if min_value is float else float(min_value)
	elif old_size_box_text and (old_size_box_text.is_valid_float() or old_size_box_text.is_valid_int()):
		slider_value = float(old_size_box_text)
	elif slider_value > max_value:
		slider_value = float(max_value)
	else:
		slider_value = float(min_value)
	if send_signal:
		_set_new_size_value(close_slider_popup)
	slider_line_edit.text = str(slider_value)
	slider.value = slider_value
	old_size_box_text = str(slider.value)
	slider_line_edit.caret_column = cursor_position


func _set_new_size_value(close_slider_popup: bool = false):
	emit_signal("set_new_slider_value", {"slider_value": slider.value if !is_int else int(slider.value), "close_slider_popup": close_slider_popup})


func set_slider_size(new_slider_size: Vector2):
	var safe_slider_size = Vector2(max(new_slider_size.x, 180.0), max(new_slider_size.y, 60.0))
	size = safe_slider_size
	slider.size = Vector2(safe_slider_size.x, 20.0)
	slider.position = Vector2(0.0, size.y - slider.size.y)
	ok_button.position = Vector2(size.x - ok_button.size.x, 0.0)
