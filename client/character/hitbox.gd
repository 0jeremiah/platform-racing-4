extends Area2D

var hitbox_type: int = 0
var special_property: int = 0
var holder: Node2D


func init(new_holder: Node2D, new_hitbox_type: int, new_special_property: int):
	holder = new_holder
	hitbox_type = new_hitbox_type
	special_property = new_special_property


func run(character: Character) -> void:
	var hitbox = get_child(0)
	if hitbox:
		if special_property != 0:
			if special_property == 2:
				if character.is_on_floor():
					hitbox.disabled = false
				else:
					hitbox.disabled = true
			elif special_property == 3:
				if !character.is_on_floor and character.velocity.rotated(-character.rotation).y >= 0:
					hitbox.disabled = false
				else:
					hitbox.disabled = true
			elif special_property == 4:
				if holder.should_crouch(character, hitbox):
					holder.is_crawling = true
				else:
					holder.is_crawling = false
	
	# disable collision if we're stuck in a wall
	if character.tile_interaction.is_in_solid():
		hitbox.disabled = true
	elif character.lightbreak.type == LightTile.MOON and character.lightbreak.is_active():
		hitbox.disabled = true
	else:
		hitbox.disabled = false
	
	# position hitbox
	#position.y = round(-shape.size.y / 2.0)

func should_crouch(character: Character, area: Area2D) -> bool:
	if !character.is_on_floor():
		return false
	var tiles_overlapping: Array = character.get_tiles_overlapping_area(area)
	for tile_data in tiles_overlapping:
		if tile_data.tile_map_layer.is_solid(tile_data.block_id):
			return true
	return false
