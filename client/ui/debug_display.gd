extends Control
class_name DebugDisplay

@onready var debug_text_container = $DebugTextContainer
var active: bool = false
var character: Character
var debug_text: String


func init(p_character: Character):
	character = p_character


func _process(float) -> void:
	if active:
		visible = true
		if character:
			var player_position = "position: " + str(character.position)
			var velocity = "velocity: " +  str(character.velocity)
			var prev_velocity = "previous_velocity: " +  str(character.movement.previous_velocity)
			var last_velocity = "last_velocity: " +  str(character.movement.last_velocity)
			var player_size = "size: " +  str(character.movement.size)
			var last_bumped_block = "last_bumped_block: " +  str(character.movement.last_bumped_block)
			var speed = "speed: " +  str(character.stats.speed)
			var accel = "accel: " +  str(character.stats.accel)
			var jump = "jump: " +  str(character.stats.jump)
			var skill = "skill: " +  str(character.stats.skill)
			var hitbox_mode = "hitbox_mode: " +  str(character.hitbox.mode)
			var gravity = "gravity: " +  str(character.gravity.gravity)
			var frozen = "frozen: " +  str(character.movement.frozen)
			var shielded = "shielded: " +  str(character.movement.shielded)
			var finished = "finished: " +  str(character.movement.finished)
			var hurt = "hurt: " +  str(character.movement.hurt)
			var current_anim = "current_animation: " +  str(character.display.animations.get_current_animation())
			var touched_tiles = "touched_tiles: " +  str(character.tile_interaction.touched_tiles)
			for text in debug_text_container.get_children():
				if text is RichTextLabel:
					text.text = (player_position + "\n" + velocity + "\n" + prev_velocity + "\n" + last_velocity
					+ "\n" + player_size + "\n" + last_bumped_block + "\n" + speed + "\n" + accel + "\n" + jump
					+ "\n" + skill + "\n" + hitbox_mode + "\n" + gravity + "\n" + frozen + "\n" + shielded + "\n"
					+ finished + "\n" + hurt + "\n" + current_anim + "\n" + touched_tiles)
	elif visible:
		visible = false


func activate():
	active = true


func deactivate():
	active = false
