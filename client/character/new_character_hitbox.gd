extends Node2D
## Controls the character's collision shape.
## Adjusts between high and low profiles based on character state.

# Hitbox types
# 0 - only senses tiles; doesn't react to them
# 1 - reacts to every tile
# 2 - reacts to every tile except water and net
# 3 - reacts only to water and net tiles

# Special properties
# 0 - no special properties
# 1 - character's hitbox
# 2 - only active when the player is grounded
# 3 - only active when the player is airborn and ascending
# 4 - makes the player crawl if touched while on ground

@onready var hitboxes_container = $HitboxesContainer

const HIGH: float = 180.0
const LOW: float = 32.0

var default_hitbox_info: Dictionary = {"hitbox1":
	{
		"size": Vector2(48.0, 190.0),
		"position": Vector2(0.0, -5.0),
		"type": 0,
		"special": 1
	},
	"hitbox2":
	{
		"size": Vector2(64.0, 1.0),
		"position": Vector2(0.0, -99.5),
		"type": 1,
		"special": 3
	},
	"hitbox3":
	{
		"size": Vector2(64.0, 1.0),
		"position": Vector2(0.0, 89.5),
		"type": 1,
		"special": 4
	},
	"hitbox4":
	{
		"size": Vector2(2.0, 96.0),
		"position": Vector2(0.0, -52.0),
		"type": 0,
		"special": 4
	},
	"hitbox5":
	{
		"size": Vector2(64.0, 94.0),
		"position": Vector2(0.0, 43.0),
		"type": 0,
		"special": 2
	}
}
var hitbox_script = preload("res://character/hitbox.gd")
var hitbox_info: Dictionary
var hitbox_size: Vector2 = Vector2(1, 1)
var crawl_hitbox_list: Array = []
var mode: String = "high"
var can_crawl: bool = false
var is_crawling: bool = false


func _ready():
	hitbox_info = default_hitbox_info
	#go_high()
	set_hitboxes()


func init(new_hitbox_info: Dictionary):
	crawl_hitbox_list = []
	if !new_hitbox_info:
		hitbox_info = default_hitbox_info
		set_hitboxes()

func set_hitboxes():
	for hitbox in hitboxes_container.get_children():
		hitbox.free()
	var keys: Array = hitbox_info.keys()
	for hitbox in hitbox_info.size():
		var area_node = Area2D.new()
		area_node.name = "Area" + str(hitbox + 1)
		area_node.position = hitbox_info[keys[hitbox]].get("position")
		area_node.set_script(hitbox_script)
		area_node.init(self, hitbox_info[keys[hitbox]].get("type"), hitbox_info[keys[hitbox]].get("special"))
		var hitbox_node = CollisionShape2D.new()
		hitbox_node.shape = RectangleShape2D.new()
		hitbox_node.shape.size = hitbox_info[keys[hitbox]].get("size")
		hitbox_node.name = "Hitbox" + str(hitbox + 1)
		hitboxes_container.add_child(area_node)
		area_node.add_child(hitbox_node)
		if hitbox_info[keys[hitbox]].get("special") == 4:
			crawl_hitbox_list.append(area_node)


#func run(character: Character) -> void:
	#for area in hitboxes_container.get_children():
		#area.run(character)
	#hitbox_size = character.movement.size
	#if character.is_on_floor():
	#	go_low()
	#elif character.lightbreak.is_active():
	#	go_low()
	#elif character.velocity.rotated(-character.rotation).y >= -0.01:
	#	go_low()
	#elif character.movement.is_crouching:
	#	go_low()
	#else:
	#	go_high()
	
	# disable collision if we're stuck in a wall
	#if character.tile_interaction.is_in_solid(character):
	#	disabled = true
	#elif character.lightbreak.type == LightTile.MOON and character.lightbreak.is_active():
	#	disabled = true
	#else:
	#	disabled = false
	
	# position hitbox
	#position.y = round(-shape.size.y / 2.0)


#func should_crouch(character: Character, area: Area2D) -> bool:
	#if !character.is_on_floor():
	#	return false
	#var tiles_overlapping: Array = character.get_tiles_overlapping_area(area)
	#for tile_data in tiles_overlapping:
	#	if _tiles.is_solid(tile_data.block_id):
	#		return true
	#return false


func _bump_tile_covering_high_area(character: Character, area: Area2D) -> void:
	if !crawl_hitbox_list.is_empty():
		for crawl_hitbox in crawl_hitbox_list:
			var tiles: Array = character.tile_interaction.get_tiles_overlapping_area(crawl_hitbox)
	
			if tiles.size() != 0:
				var tile = tiles[0]
				var tile_type = CoordinateUtils.to_block_id(tile.atlas_coords)
	
				character.movement.attempting_bump = true
				if tile != character.movement.last_bumped_block:
					character.tile_interaction._tiles.on("bottom", tile_type, self, tile.tile_map_layer, tile.coords)
					character.tile_interaction._tiles.on("any_side", tile_type, self, tile.tile_map_layer, tile.coords)
					character.tile_interaction._tiles.on("bump", tile_type, self, tile.tile_map_layer, tile.coords)
					character.movement.last_bumped_block = tile
					Jukebox.play_sound("bump")
			else:
				push_error("TileInteractionController::bump_tile_covering_high_area - No tile covering high area")
	else:
		push_error("No crawl hitboxes exist to do that. :(")


func set_depth(character: Character, depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	var vapor_layer = Helpers.to_bitmask_32(depth * 2)
	character.collision_layer = solid_layer
	character.collision_mask = solid_layer
	for area in hitboxes_container.get_children():
		if area is Area2D:
			area.collision_layer = vapor_layer
			if area.type != 0:
				area.collision_mask = solid_layer | vapor_layer


#func go_high() -> void:
	#mode = "high"
	#shape.size.y = HIGH


#func go_low() -> void:
	#mode = "low"
	#shape.size.y = LOW
