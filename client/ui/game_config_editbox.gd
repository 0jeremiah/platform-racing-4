extends LineEdit

signal return_data

var type = "string"
var old_string: String = ""
var int_min: int = -999999999
var int_max: int = 9999999999
var float_min: float = -9999999.9
var float_max: float = 99999999.9
var category_key: String = ""
var value_key: String = ""


func _ready() -> void:
	text_changed.connect(_maybe_enforce_limits.bind())


func init(new_type: String, current_value: String = "", new_min: float = -9999999.9, new_max: float = 99999999.9):
	var cursor_position = get_caret_column()
	if new_type == "int":
		type = "int"
		int_min = new_min
		int_max = new_max
		var new_number: int
		if int(current_value) >= int_min and int(current_value) <= int_max:
			new_number = int(current_value)
		else:
			if int(current_value) < int_min:
				new_number = int_min
			else:
				new_number = int_max
		text = str(new_number)
		old_string = text
		caret_column = cursor_position
	elif new_type == "float":
		type = "float"
		float_min = new_min
		float_max = new_max
		var new_number: float
		if float(current_value) >= float_min and float(current_value) <= float_max:
			new_number = float(current_value)
		else:
			if float(current_value) < int_min:
				new_number = int_min
			else:
				new_number = int_max
		text = str(new_number)
		old_string = text
		caret_column = cursor_position
	else:
		type = "string"
		text = current_value
		old_string = text
		caret_column = cursor_position

func _maybe_enforce_limits(new_string: String) -> void:
	if type == "int":
		maybe_change_int(new_string)
	elif type == "float":
		maybe_change_float(new_string)
	emit_signal("return_data", [text, category_key, value_key])


func maybe_change_int(current_number: String):
	var cursor_position = get_caret_column()
	if current_number.is_valid_int():
		var new_number: int
		if int(current_number) >= int_min and int(current_number) <= int_max:
			new_number = str(current_number).to_int()
		else:
			if int(current_number) < int_min:
				new_number = int_min
			else:
				new_number = int_max
		text = str(new_number)
		old_string = text
		caret_column = cursor_position
	else:
		text = old_string
		caret_column = cursor_position


func maybe_change_float(current_number: String):
	var cursor_position = get_caret_column()
	if current_number.is_valid_float():
		var new_number: float
		if float(current_number) >= float_min and float(current_number) <= float_max:
			new_number = str(current_number).to_float()
		else:
			if float(current_number) < float_min:
				new_number = float_min
			else:
				new_number = float_max
		text = str(new_number)
		old_string = text
		caret_column = cursor_position
	else:
		text = old_string
		caret_column = cursor_position
