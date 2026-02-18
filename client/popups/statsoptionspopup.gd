extends Control

signal amount_changed

@onready var block_label = $BlockLabel
@onready var description_label = $DescriptionLabel
@onready var stats_change_label = $StatsChangeLabel
@onready var stats_change_slider = $StatsChangeSlider

var type: String = "inc"
var amount: int = 5


func init(new_amount: int, new_block_label: String = "Happy", new_description_label: String = "increase"):
	amount = new_amount
	block_label.text = "-- " + new_block_label + " Block --"
	description_label.text = "Bumping this block will " + new_description_label + " all of the racer's stats by:"
	

func _ready() -> void:
	stats_change_slider.connect("value_changed", set_amount)
	stats_change_label.text = str(amount)


func set_amount(new_amount: int):
	amount = new_amount
	stats_change_label.text = str(amount)
	emit_signal("amount_changed", amount)
