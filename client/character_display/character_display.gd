class_name CharacterDisplay
extends Node2D
## Displays and animates a character with customizable parts and colors.
## Provides methods to control animations and appearance.

const AIRBORNE := "airborne"
const CHARGE := "charge"
const CHARGE_HOLD := "charge_hold"
const CRAWL := "crawl"
const CROUCH := "crouch"
const FINISH := "finish"
const FINISH_START := "finish_start"
const HURT := "hurt"
const HURT_START := "hurt_start"
const IDLE := "idle"
const JUMP := "jump"
const RECOVER := "recover"
const RUN := "run"
const SWIM := "swim"
const WALL_SLIDE := "wall_slide"
const ANIMS := [
	AIRBORNE,
	CHARGE,
	CHARGE_HOLD,
	CRAWL,
	CROUCH,
	FINISH,
	FINISH_START,
	HURT,
	HURT_START,
	IDLE,
	JUMP,
	RECOVER,
	RUN,
	SWIM,
	WALL_SLIDE,
]

@onready var foot_back_color: Sprite2D = $FootBack/Color
@onready var foot_back_lines: Sprite2D = $FootBack/Lines
@onready var foot_back_epic_color: Sprite2D = $FootBack/Color2
@onready var foot_back_misc1: Sprite2D = $FootBack/Misc1
@onready var foot_back_misc2: Sprite2D = $FootBack/Misc2
@onready var body_color: Sprite2D = $Body/Color
@onready var body_lines: Sprite2D = $Body/Lines
@onready var body_epic_color: Sprite2D = $Body/Color2
@onready var body_misc1: Sprite2D = $Body/Misc1
@onready var body_misc2: Sprite2D = $Body/Misc2
@onready var foot_front_color: Sprite2D = $FootFront/Color
@onready var foot_front_lines: Sprite2D = $FootFront/Lines
@onready var foot_front_epic_color: Sprite2D = $FootFront/Color2
@onready var foot_front_misc1: Sprite2D = $FootFront/Misc1
@onready var foot_front_misc2: Sprite2D = $FootFront/Misc2
@onready var head_color: Sprite2D = $Head/Color
@onready var head_lines: Sprite2D = $Head/Lines
@onready var head_epic_color: Sprite2D = $Head/Color2
@onready var head_misc1: Sprite2D = $Head/Misc1
@onready var head_misc2: Sprite2D = $Head/Misc2
@onready var hat_holder: Node2D = $HatHolder
@onready var item_holder: Node2D = $ItemHolder
@onready var life_bar = $LifeBar
@onready var life_bar_rect = $LifeBar/LifeBarRect
@onready var remaining_life_bar = $LifeBar/RemainingLifeBar
@onready var health_text = $LifeBar/HealthText
@onready var username = $Username
@onready var username_text = $Username/UsernameText
@onready var animations: AnimationPlayer = $Animations

var played_footstep = false


func _process(_delta: float) -> void:
	played_footstep = false


func add_hat_display(hat_info: Dictionary, number: String = "") -> bool:
	if hat_info.has("id"):
		var new_hat_textures = CharacterManager.get_part_textures(hat_info.id, "hat")
		var new_hat_color = hat_info.get("color", "FFFFFF")
		var new_hat_epic_color = hat_info.get("epic_color", "FFFFFF")
		var new_hat_node = Node2D.new()
		var color_sprite = Sprite2D.new()
		color_sprite.texture = new_hat_textures["color"]
		color_sprite.self_modulate = Color(new_hat_color)
		color_sprite.name = "Color"
		new_hat_node.add_child(color_sprite)
		var lines_sprite = Sprite2D.new()
		lines_sprite.texture = new_hat_textures["lines"]
		lines_sprite.name = "Lines"
		new_hat_node.add_child(lines_sprite)
		var color2_sprite = Sprite2D.new()
		color2_sprite.texture = new_hat_textures["epic_color"]
		color2_sprite.self_modulate = Color(new_hat_epic_color)
		color2_sprite.name = "Color2"
		new_hat_node.add_child(color2_sprite)
		var misc1_sprite = Sprite2D.new()
		misc1_sprite.texture = new_hat_textures["misc1"]
		misc1_sprite.name = "Misc1"
		new_hat_node.add_child(misc1_sprite)
		var misc2_sprite = Sprite2D.new()
		misc2_sprite.texture = new_hat_textures["misc2"]
		misc2_sprite.name = "Misc2"
		new_hat_node.add_child(misc2_sprite)
		if number != "":
			new_hat_node.name = "Hat" + number
			if number.is_valid_int():
				new_hat_node.position.y = -20.0 * (int(number) - 1)
		hat_holder.add_child(new_hat_node)
		return true
	return false


func set_hat_array(hat_array: Array):
	for hat in hat_holder.get_child_count():
		hat_holder.get_child(hat - 1).name = "removedhat" + str(hat)
		hat_holder.get_child(hat - 1).queue_free()
	var hat_counter = 1
	for hat in hat_array.size():
		if add_hat_display(hat_array[hat], str(hat_counter)):
			hat_counter += 1


func set_head(new_head_id: String, new_head_color: String = "", new_head_epic_color: String = ""):
	if CharacterManager._parts_lookup.head.has(new_head_id):
		var default_head_color = CharacterManager._parts_lookup.head.get(new_head_id, {}).get("settings", {}).get("default_color", "ffffff")
		var default_head_epic_color = CharacterManager._parts_lookup.head.get(new_head_id, {}).get("settings", {}).get("default_epic_color", "ffffff")
		var current_color = new_head_color if new_head_color != "" and new_head_color.is_valid_html_color() else default_head_color
		var current_epic_color = new_head_epic_color if new_head_epic_color != "" and new_head_epic_color.is_valid_html_color() else default_head_epic_color
		var head_textures = CharacterManager.get_part_textures(new_head_id, "head")
		set_head_style(head_textures)
		set_head_color(current_color, current_epic_color)


func set_head_style(part_config: Dictionary):
	head_color.texture = part_config["color"]
	head_lines.texture = part_config["lines"]
	head_epic_color.texture = part_config["epic_color"]
	head_misc1.texture = part_config["misc1"]
	head_misc2.texture = part_config["misc2"]


func set_head_color(new_head_color_string: String, new_head_epic_color_string: String):
	head_color.self_modulate = Color(new_head_color_string)
	head_epic_color.self_modulate = Color(new_head_epic_color_string)


func set_body(new_body_id: String, new_body_color: String = "", new_body_epic_color: String = ""):
	if CharacterManager._parts_lookup.body.has(new_body_id):
		var default_body_color = CharacterManager._parts_lookup.body.get(new_body_id, {}).get("settings", {}).get("default_color", "ffffff")
		var default_body_epic_color = CharacterManager._parts_lookup.body.get(new_body_id, {}).get("settings", {}).get("default_epic_color", "ffffff")
		var current_color = new_body_color if new_body_color != "" and new_body_color.is_valid_html_color() else default_body_color
		var current_epic_color = new_body_epic_color if new_body_epic_color != "" and new_body_epic_color.is_valid_html_color() else default_body_epic_color
		var head_textures = CharacterManager.get_part_textures(new_body_id, "body")
		set_body_style(head_textures)
		set_body_color(current_color, current_epic_color)


func set_body_style(part_config: Dictionary):
	body_color.texture = part_config["color"]
	body_lines.texture = part_config["lines"]
	body_epic_color.texture = part_config["epic_color"]
	body_misc1.texture = part_config["misc1"]
	body_misc2.texture = part_config["misc2"]


func set_body_color(new_body_color_string: String, new_body_epic_color_string: String):
	body_color.self_modulate = Color(new_body_color_string)
	body_epic_color.self_modulate = Color(new_body_epic_color_string)


func set_feet(new_feet_id: String, new_feet_color: String = "", new_feet_epic_color: String = ""):
	if CharacterManager._parts_lookup.feet.has(new_feet_id) and (CharacterManager._parts_lookup.feet[new_feet_id].has("foot_front") or CharacterManager._parts_lookup.feet[new_feet_id].has("foot_back")):
		var default_feet_color = CharacterManager._parts_lookup.feet.get(new_feet_id, {}).get("settings", {}).get("default_color", "ffffff")
		var default_feet_epic_color = CharacterManager._parts_lookup.feet.get(new_feet_id, {}).get("settings", {}).get("default_epic_color", "ffffff")
		var current_color = new_feet_color if new_feet_color != "" and new_feet_color.is_valid_html_color() else default_feet_color
		var current_epic_color = new_feet_epic_color if new_feet_epic_color != "" and new_feet_epic_color.is_valid_html_color() else default_feet_epic_color
		if CharacterManager._parts_lookup.feet[new_feet_id].has("foot_front"):
			var foot_front_textures = CharacterManager.get_part_textures(new_feet_id, "foot_front")
			set_foot_front_style(foot_front_textures)
			if !CharacterManager._parts_lookup.feet[new_feet_id].has("foot_back"):
				set_foot_back_style(foot_front_textures)
		if CharacterManager._parts_lookup.feet[new_feet_id].has("foot_back"):
			var foot_back_textures = CharacterManager.get_part_textures(new_feet_id, "foot_back")
			set_foot_back_style(foot_back_textures)
			if !CharacterManager._parts_lookup.feet[new_feet_id].has("foot_front"):
				set_foot_front_style(foot_back_textures)
		set_feet_color(current_color, current_epic_color)


func set_foot_front_style(part_config: Dictionary):
	foot_front_color.texture = part_config["color"]
	foot_front_lines.texture = part_config["lines"]
	foot_front_epic_color.texture = part_config["epic_color"]
	foot_front_misc1.texture = part_config["misc1"]
	foot_front_misc2.texture = part_config["misc2"]


func set_foot_back_style(part_config: Dictionary):
	foot_back_color.texture = part_config["color"]
	foot_back_lines.texture = part_config["lines"]
	foot_back_epic_color.texture = part_config["epic_color"]
	foot_back_misc1.texture = part_config["misc1"]
	foot_back_misc2.texture = part_config["misc2"]


func set_feet_color(new_feet_color_string: String, new_feet_epic_color_string: String):
	foot_front_color.self_modulate = Color(new_feet_color_string)
	foot_front_epic_color.self_modulate = Color(new_feet_epic_color_string)
	foot_back_color.self_modulate = Color(new_feet_color_string)
	foot_back_epic_color.self_modulate = Color(new_feet_epic_color_string)


func play(anim: String) -> void:
	animations.play(anim)


func deferred_play_airborne() -> void:
	animations.play(AIRBORNE)


func play_random() -> void:
	animations.play(ANIMS.pick_random())


func set_speed_scale(num: float) -> void:
	animations.speed_scale = num


func play_footstep() -> void:
	if !played_footstep:
		played_footstep = true
		var soundid = randi_range(1, 4)
		match soundid:
			1: Jukebox.play_sound("run1")
			2: Jukebox.play_sound("run2")
			3: Jukebox.play_sound("run3")
			4: Jukebox.play_sound("run4")


func toggle_life_bar(toggle: bool):
	if toggle:
		life_bar.visible = true
	else:
		life_bar.visible = false


func update_life_bar(current_hp: int, max_hp: int, facing: int = 1):
	var max_health_size_x = life_bar_rect.size.x - (life_bar_rect.border_width + 4)
	remaining_life_bar.position.x = (life_bar_rect.position.x + ((life_bar_rect.border_width / 2) + 2)) * facing
	remaining_life_bar.size.x = max_health_size_x * (float(current_hp) / float(max_hp))
	remaining_life_bar.scale.x = facing
	health_text.position.x = remaining_life_bar.position.x
	health_text.size.x = max_health_size_x
	health_text.scale.x = remaining_life_bar.scale.x
	health_text.text = str(current_hp) + " / " + str(max_hp) + " (" + str(snappedf(float(current_hp) / float(max_hp), 0.001) * 100) + "%)"


func toggle_username(toggle: bool):
	if toggle:
		username.visible = true
	else:
		username.visible = false


func set_username(new_username_text: String):
	username_text.text = new_username_text
