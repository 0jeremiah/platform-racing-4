extends Node
## Manages fonts, this is here so we dont have to preload fonts everytime

var action_man_font = preload("res://fonts/actionman/action-man.ttf")
var arial_font = preload("res://fonts/arial/arial.ttf")
var gwibble_font = preload("res://fonts/gwibble/gwibble.ttf")
var poetsenone_font = preload("res://fonts/poetsenone/poetsenone-regular.ttf")
var quicksand_font = preload("res://fonts/quicksand/quicksand-variablefont_wght.ttf")
var verdana_font = preload("res://fonts/verdana/verdana.ttf")
var font_list = {
	"poetsenone": {
		"title": "Poetsen One",
		"font": poetsenone_font
	},
	"arial": {
		"title": "Arial",
		"font": arial_font
	},
	"verdana": {
		"title": "Verdana",
		"font": verdana_font
	},
	"actionman": {
		"title": "Action Man",
		"font": action_man_font
	},
	"gwibble": {
		"title": "Gwibble",
		"font": gwibble_font
	},
	"quicksand": {
		"title": "Quicksand",
		"font": quicksand_font
	}
}


func get_font(font_name: String) -> Font:
	if font_list.has(font_name):
		return font_list[font_name].font
	return quicksand_font


func get_font_dictionary(font_name: String) -> Dictionary:
	if font_list.has(font_name):
		return font_list[font_name]
	return {}
