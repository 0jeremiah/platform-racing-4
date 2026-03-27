extends Control

signal stat_options_changed

@onready var amount_dec_button = $AmountSlider/AmountDecButton
@onready var amount_inc_button = $AmountSlider/AmountIncButton
@onready var amount_slider = $AmountSlider/AmountSlider
@onready var amount_box = $AmountSlider/AmountBox

var amount: int = 5


func _ready() -> void:
	amount_dec_button.pressed.connect(_change_amount.bind(-1, true))
	amount_inc_button.pressed.connect(_change_amount.bind(1, true))
	amount_slider.value_changed.connect(_change_amount)
	amount_box.init("int", "5", 0, 100)
	amount_box.return_line.connect(_change_amount)


func _change_amount(new_amount: int, inc_or_dec: bool = false):
	if inc_or_dec and amount + new_amount > 0 and amount + new_amount < 100:
		amount += new_amount
		if amount_slider.value != amount:
			amount_slider.set_value_no_signal(amount)
		if int(amount_box.text) != amount:
			amount_box._update_text(str(amount))
		emit_signal("stat_options_changed", {"amount": amount})
	elif new_amount > 0 and new_amount < 100:
		amount = new_amount
		if amount_slider.value != amount:
			amount_slider.set_value_no_signal(amount)
		if int(amount_box.text) != amount:
			amount_box._update_text(str(amount))
		emit_signal("stat_options_changed", {"amount": amount})


func set_amount(new_amount: int):
	amount_slider.set_value_no_signal(new_amount)
	amount_box._update_text(str(new_amount))
	amount = clamp(new_amount, 0, 100)
