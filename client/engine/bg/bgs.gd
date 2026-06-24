class_name Backgrounds

static var pr2_dots_node = preload("res://engine/bg/pr2bg5-dots.tscn")
static var bg_dictionary: Dictionary = {
	"blank": {"texture": preload("res://engine/bg/100x100.png")},
	"pr2_field": {"texture": preload("res://engine/bg/pr2bg1-Field.svg")},
	"pr2_generic": {"texture": preload("res://engine/bg/pr2bg2-generic.svg")},
	"pr2_lake": {"texture": preload("res://engine/bg/pr2bg3-lake.svg")},
	"pr2_desert": {"texture": preload("res://engine/bg/pr2bg4-desert.svg"), "sprite_rect": Rect2(3.0, 0.0, 550.0, 400.0)},
	"pr2_dots": {"texture": preload("res://engine/bg/pr2bg5-dots-blank.svg")},
	"pr2_space": {"texture": preload("res://engine/bg/pr2bg6-space.svg"), "sprite_rect": Rect2(22.0, 0.0, 550.0, 400.0)},
	"pr2_skyscraper": {"texture": preload("res://engine/bg/pr2bg7-skyscraper.svg"), "sprite_rect": Rect2(48.0, 0.0, 550.0, 400.0)},
	"pr3_desert": {"texture": preload("res://engine/bg/pr3bg1-desert.png")},
	"pr3_industrial": {"texture": preload("res://engine/bg/pr3bg2-industrial.png")},
	"pr3_jungle": {"texture": preload("res://engine/bg/pr3bg3-jungle.png")},
	"pr3_space": {"texture": preload("res://engine/bg/pr3bg4-space.png")},
	"pr3_underwater": {"texture": preload("res://engine/bg/pr3bg5-underwater.png")},
	"pr3_volcano": {"texture": preload("res://engine/bg/pr3bg6-volcano.png")}, 
	"pr3_thanksgiving": {"texture": preload("res://engine/bg/pr3bg8-thanksgiving.png")}, 
	"pr3_main": {"texture": preload("res://engine/bg/pr3bg9-main.png")}, 
	"pr3_christmas": {"texture": preload("res://engine/bg/pr3bg10-christmas.png")}
}
static var bg_failsafe_dictionary: Dictionary = {
	"field": {"compat_id": "pr2_field"},
	"generic": {"compat_id": "pr2_generic"},
	"lake": {"compat_id": "pr2_lake"},
	"desert": {"compat_id": "pr2_desert"},
	"dots": {"compat_id": "pr2_dots"},
	"space": {"compat_id": "pr2_space"},
	"skyscraper": {"compat_id": "pr2_skyscraper"}
}


static func set_dots(sprite: Sprite2D):
	# dots colors are random, has entire system dedicated to that.
	if !sprite.has_node("Dots"):
		sprite.texture = bg_dictionary["pr2_dots"].texture
		sprite.set_region_enabled(false)
		var dots = pr2_dots_node.instantiate()
		sprite.add_child(dots)


static func get_bg(sprite: Sprite2D, p_id: String, fade_color: String) -> void:
	var background_id = p_id
	if p_id in bg_failsafe_dictionary:
		background_id = bg_failsafe_dictionary[p_id].compat_id
	# deletes the dots if id isn't dots so we don't keep making more dots
	if (background_id != "dots" or background_id != "pr2_dots") and sprite.has_node("Dots"):
		sprite.get_node("Dots").queue_free()
	# sets backgrounds accordingly
	# the ids without the "pr2_" prefixes are failsafes for old levels.
	if background_id in bg_dictionary:
		if background_id == "dots" or background_id == "pr2_dots":
			set_dots(sprite)
		else:
			sprite.set_region_enabled(false)
			sprite.texture = bg_dictionary[background_id].texture
			if "sprite_rect" in bg_dictionary[background_id]:
				sprite.set_region_enabled(true)
				sprite.set_region_rect(bg_dictionary[background_id].sprite_rect)
		if background_id == "blank":
			sprite.modulate = Color(fade_color)
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		sprite.texture = bg_dictionary["pr2_field"].texture; sprite.set_region_enabled(false)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

static func get_bg_no_dots(sprite: Sprite2D, p_id: String, fade_color: String) -> void:
	var background_id = p_id
	if p_id in bg_failsafe_dictionary:
		background_id = bg_failsafe_dictionary[p_id].compat_id
	# sets backgrounds accordingly
	# the ids without the "pr2_" prefixes are failsafes for old levels.
	if background_id in bg_dictionary:
		sprite.set_region_enabled(false)
		sprite.texture = bg_dictionary[background_id].texture
		if "sprite_rect" in bg_dictionary[background_id]:
			sprite.set_region_enabled(true)
			sprite.set_region_rect(bg_dictionary[background_id].sprite_rect)
		if background_id == "blank":
			sprite.modulate = Color(fade_color)
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		sprite.texture = bg_dictionary["pr2_field"].texture; sprite.set_region_enabled(false)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
