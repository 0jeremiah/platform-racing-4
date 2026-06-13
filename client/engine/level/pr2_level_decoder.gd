extends Node2D
class_name PR2LevelDecoder


func decode_pr2_level(pr2_level: String):
	var pr2_level_data_array = pr2_level.split("&")
	var pr2_level_data = {}
	for data in pr2_level_data_array:
		var data_string = data.split("=")
		var data1 = data_string[0]
		var data2 = null
		if data_string[1]:
			data2 = data_string[1]
		pr2_level_data[data1] = data2
