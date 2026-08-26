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
@onready var my_hat: Node2D = $HatHolder/Hat1
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


func set_style(character_config: Dictionary) -> void:
	# colors
	head_color.modulate = Color(character_config["head"]["color"])
	body_color.modulate = Color(character_config["body"]["color"])
	foot_front_color.modulate = Color(character_config["feet"]["color"])
	foot_back_color.modulate = Color(character_config["feet"]["color"])
	
	# parts
	var head_texture
	if character_config["head"]["texture"]:
		head_texture = character_config["head"]["texture"]
	else:
		head_texture = await CachingLoader.load_texture(character_config["head"]["url"])
	
	var body_texture
	if character_config["body"]["texture"]:
		body_texture = character_config["body"]["texture"]
	else:
		body_texture = await CachingLoader.load_texture(character_config["body"]["url"])
	
	var feet_texture
	if character_config["feet"]["texture"]:
		feet_texture = character_config["feet"]["texture"]
	else:
		feet_texture = await CachingLoader.load_texture(character_config["feet"]["url"])
	
	head_color.texture = head_texture
	head_lines.texture = head_texture
	body_color.texture = body_texture
	body_lines.texture = body_texture
	foot_front_color.texture = feet_texture
	foot_front_lines.texture = feet_texture
	foot_back_color.texture = feet_texture
	foot_back_lines.texture = feet_texture


func set_style_from_path(character_config: Dictionary) -> void:
	# colors
	my_hat.get_node("Color").self_modulate = Color(character_config["hat"]["color"])
	my_hat.get_node("Color2").self_modulate = Color(character_config["hat"]["epic_color"])
	
	head_color.self_modulate = Color(character_config["head"]["color"])
	head_epic_color.self_modulate = Color(character_config["head"]["epic_color"])
	
	body_color.self_modulate = Color(character_config["body"]["color"])
	body_epic_color.self_modulate = Color(character_config["body"]["epic_color"])
	
	foot_front_color.self_modulate = Color(character_config["foot_front"]["color"])
	foot_front_epic_color.self_modulate = Color(character_config["foot_front"]["epic_color"])
	
	foot_back_color.self_modulate = Color(character_config["foot_back"]["color"])
	foot_back_epic_color.self_modulate = Color(character_config["foot_back"]["epic_color"])
	
	# parts
	var hat_color_texture = null
	var hat_lines_texture = null
	var hat_epic_color_texture = null
	var hat_misc1_texture = null
	var hat_misc2_texture = null
	if character_config.has("hat") and character_config.hat.has("hat_color"):
		hat_color_texture = load(character_config["hat"]["hat_color"])
	if character_config.has("hat") and character_config.hat.has("hat_lines"):
		hat_lines_texture = load(character_config["hat"]["hat_lines"])
	if character_config.has("hat") and character_config.hat.has("hat_epic_color"):
		hat_epic_color_texture = load(character_config["hat"]["hat_epic_color"])
	if character_config.has("hat") and character_config.hat.has("hat_misc1"):
		hat_misc1_texture = load(character_config["hat"]["hat_misc1"])
	if character_config.has("hat") and character_config.hat.has("hat_misc2"):
		hat_misc2_texture = load(character_config["hat"]["hat_misc2"])
	
	var head_color_texture = null
	var head_lines_texture = null
	var head_epic_color_texture = null
	var head_misc1_texture = null
	var head_misc2_texture = null
	if character_config.has("head") and character_config.head.has("head_color"):
		head_color_texture = load(character_config["head"]["head_color"])
	if character_config.has("head") and character_config.head.has("head_lines"):
		head_lines_texture = load(character_config["head"]["head_lines"])
	if character_config.has("head") and character_config.head.has("head_epic_color"):
		head_epic_color_texture = load(character_config["head"]["head_epic_color"])
	if character_config.has("head") and character_config.head.has("head_misc1"):
		head_misc1_texture = load(character_config["head"]["head_misc1"])
	if character_config.has("head") and character_config.head.has("head_misc2"):
		head_misc2_texture = load(character_config["head"]["head_misc2"])
	
	var foot_front_color_texture = null
	var foot_front_lines_texture = null
	var foot_front_epic_color_texture = null
	var foot_front_misc1_texture = null
	var foot_front_misc2_texture = null
	if character_config.has("foot_front") and character_config.foot_front.has("foot_front_color"):
		foot_front_color_texture = load(character_config["foot_front"]["foot_front_color"])
	if character_config.has("foot_front") and character_config.foot_front.has("foot_front_lines"):
		foot_front_lines_texture = load(character_config["foot_front"]["foot_front_lines"])
	if character_config.has("foot_front") and character_config.foot_front.has("foot_front_epic_color"):
		foot_front_epic_color_texture = load(character_config["foot_front"]["foot_front_epic_color"])
	if character_config.has("foot_front") and character_config.foot_front.has("foot_front_misc1"):
		foot_front_misc1_texture = load(character_config["foot_front"]["foot_front_misc1"])
	if character_config.has("foot_front") and character_config.foot_front.has("foot_front_misc2"):
		foot_front_misc2_texture = load(character_config["foot_front"]["foot_front_misc2"])
	
	var body_color_texture = null
	var body_lines_texture = null
	var body_epic_color_texture = null
	var body_misc1_texture = null
	var body_misc2_texture = null
	if character_config.has("body") and character_config.body.has("body_color"):
		body_color_texture = load(character_config["body"]["body_color"])
	if character_config.has("body") and character_config.body.has("body_lines"):
		body_lines_texture = load(character_config["body"]["body_lines"])
	if character_config.has("body") and character_config.body.has("body_epic_color"):
		body_epic_color_texture = load(character_config["body"]["body_epic_color"])
	if character_config.has("body") and character_config.body.has("body_misc1"):
		body_misc1_texture = load(character_config["body"]["body_misc1"])
	if character_config.has("body") and character_config.body.has("body_misc2"):
		body_misc2_texture = load(character_config["body"]["body_misc2"])
	
	var foot_back_color_texture = null
	var foot_back_lines_texture = null
	var foot_back_epic_color_texture = null
	var foot_back_misc1_texture = null
	var foot_back_misc2_texture = null
	if character_config.has("foot_back") and character_config.foot_back.has("foot_back_color"):
		foot_back_color_texture = load(character_config["foot_back"]["foot_back_color"])
	if character_config.has("foot_back") and character_config.foot_back.has("foot_back_lines"):
		foot_back_lines_texture = load(character_config["foot_back"]["foot_back_lines"])
	if character_config.has("foot_back") and character_config.foot_back.has("foot_back_epic_color"):
		foot_back_epic_color_texture = load(character_config["foot_back"]["foot_back_epic_color"])
	if character_config.has("foot_back") and character_config.foot_back.has("foot_back_misc1"):
		foot_back_misc1_texture = load(character_config["foot_back"]["foot_back_misc1"])
	if character_config.has("foot_back") and character_config.foot_back.has("foot_back_misc2"):
		foot_back_misc2_texture = load(character_config["foot_back"]["foot_back_misc2"])
	
	my_hat.get_node("Color").texture = hat_color_texture
	my_hat.get_node("Lines").texture = hat_lines_texture
	my_hat.get_node("Color2").texture = hat_epic_color_texture
	my_hat.get_node("Misc1").texture = hat_misc1_texture
	my_hat.get_node("Misc2").texture = hat_misc2_texture
	
	head_color.texture = head_color_texture
	head_lines.texture = head_lines_texture
	head_epic_color.texture = head_epic_color_texture
	head_misc1.texture = head_misc1_texture
	head_misc2.texture = head_misc2_texture
	
	foot_front_color.texture = foot_front_color_texture
	foot_front_lines.texture = foot_front_lines_texture
	foot_front_epic_color.texture = foot_front_epic_color_texture
	foot_front_misc1.texture = foot_front_misc1_texture
	foot_front_misc2.texture = foot_front_misc2_texture
	
	body_color.texture = body_color_texture
	body_lines.texture = body_lines_texture
	body_epic_color.texture = body_epic_color_texture
	body_misc1.texture = body_misc1_texture
	body_misc2.texture = body_misc2_texture
	
	foot_back_color.texture = foot_back_color_texture
	foot_back_lines.texture = foot_back_lines_texture
	foot_back_epic_color.texture = foot_back_epic_color_texture
	foot_back_misc1.texture = foot_back_misc1_texture
	foot_back_misc2.texture = foot_back_misc2_texture


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
