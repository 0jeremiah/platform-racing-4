extends TileOptions
class_name StatsOptions

var amount: int = 5
var stats_popup = preload("res://popups/statsoptionspopup.tscn")


func set_amount(new_amount: int):
	amount = new_amount
	data = [amount]
