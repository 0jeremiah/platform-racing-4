class_name CharacterDisplay
extends Node2D
## Displays and animates a character with customizable parts and colors.
## Provides methods to control animations and appearance.

const AIRBORN := "airborn"
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
	AIRBORN,
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
@onready var animations: AnimationPlayer = $Animations

var played_footstep = false


func _process(delta: float) -> void:
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
	head_color.self_modulate = Color(character_config["head"]["color"])
	head_epic_color.self_modulate = Color(character_config["head"]["epic_color"])
	
	body_color.self_modulate = Color(character_config["body"]["color"])
	body_epic_color.self_modulate = Color(character_config["body"]["epic_color"])
	
	foot_front_color.self_modulate = Color(character_config["foot_front"]["color"])
	foot_front_epic_color.self_modulate = Color(character_config["foot_front"]["epic_color"])
	
	foot_back_color.self_modulate = Color(character_config["foot_back"]["color"])
	foot_back_epic_color.self_modulate = Color(character_config["foot_back"]["epic_color"])
	
	# parts
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
		foot_back_misc1_texture = load(character_config["foot_back"]["foot_back_misc2"])
	
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
