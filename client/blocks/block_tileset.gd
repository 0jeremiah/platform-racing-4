class_name ConfigurableTileSet
extends TileSet
## TileSet that is dynamically generated from an array of block configuration dictionaries
##
## Takes block configs (from JSON or runtime) and creates a complete TileSet with:
## - Multiple atlas sources (deduplicated by texture)
## - Physics layers for different matter types
## - Alternative tiles for visible/invisible/active/deactivated states

static var block_scene = preload("res://blocks/block_scene.tscn")
static var sources_map: Dictionary = {}
static var atlas_textures = {}


## Initialize the tileset
func init() -> void:
	# Set tile size from settings
	tile_size = Settings.tile_size
	
	# Create scenes collection source
	var scenes_collection_source: TileSetScenesCollectionSource = TileSetScenesCollectionSource.new()

	# Add source to tileset
	add_source(scenes_collection_source, 0)

	# Create block scene in ScenesCollectionSource (other scenes can also be added for stuff that aren't blocks)
	scenes_collection_source.create_scene_tile(block_scene, 0)

	# Setup physics layers
	_setup_physics_layers()


## Setup physics layers: layer 0 for solid, layer 1 for non-solid (liquid/gas)
func _setup_physics_layers() -> void:
	add_physics_layer()  # Layer 0: solid blocks
	add_physics_layer()  # Layer 1: non-solid blocks (liquid, gas)
