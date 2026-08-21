extends StaticBody2D

@onready var block_texture = $BlockTexture
@onready var top_hitbox = $TopHitbox
@onready var bottom_hitbox = $BottomHitbox
@onready var left_hitbox = $LeftHitbox
@onready var right_hitbox = $RightHitbox
@onready var area_hitbox = $AreaHitbox

var id = ""
var settings = ConfigurableBlockSettings.new()
var location: String = ""


func init(new_id: String, new_settings: ConfigurableBlockSettings):
	if new_id in BlockManager._block_lookup:
		id = new_id
		settings = new_settings
		top_hitbox.disabled = settings.matter_type == ConfigurableBlockSettings.SOLID and settings.top.type == ConfigurableBlockSideSettings.INACTIVE
		bottom_hitbox.disabled = settings.matter_type == ConfigurableBlockSettings.SOLID and settings.bottom.type == ConfigurableBlockSideSettings.INACTIVE
		left_hitbox.disabled = settings.matter_type == ConfigurableBlockSettings.SOLID and settings.left.type == ConfigurableBlockSideSettings.INACTIVE
		right_hitbox.disabled = settings.matter_type == ConfigurableBlockSettings.SOLID and settings.right.type == ConfigurableBlockSideSettings.INACTIVE
		area_hitbox.disabled = settings.matter_type != ConfigurableBlockSettings.SOLID# and (settings.right.type != ConfigurableBlockSideSettings.INACTIVE or settings.right.type != ConfigurableBlockSideSettings.START_POSITION)
		set_block_texture()


func _ready():
	block_texture.size = Vector2(Settings.tile_size)
	block_texture.position = -Vector2(float(Settings.tile_size.x) / 2, float(Settings.tile_size.y) / 2)
	top_hitbox.shape.size = Vector2(float(Settings.tile_size.x), float(Settings.tile_size.y) / 2)
	top_hitbox.position = Vector2(0, float(-Settings.tile_size.y) / 4)
	bottom_hitbox.shape.size = Vector2(float(Settings.tile_size.x), float(Settings.tile_size.y) / 2)
	bottom_hitbox.position = Vector2(0, float(Settings.tile_size.y) / 4)
	left_hitbox.shape.size = Vector2(float(Settings.tile_size.x) / 2, float(Settings.tile_size.y))
	left_hitbox.position = Vector2(float(-Settings.tile_size.x) / 4, 0)
	right_hitbox.shape.size = Vector2(float(Settings.tile_size.x) / 2, float(Settings.tile_size.y))
	right_hitbox.position = Vector2(float(Settings.tile_size.x) / 4, 0)
	area_hitbox.shape.size = Vector2(Settings.tile_size)
	area_hitbox.position = Vector2.ZERO
	var parent = get_parent()
	if parent and parent is ConfigurableTileMapLayer:
		location = str(int(position.x / Settings.tile_size.x)) + "," + str(int(position.y / Settings.tile_size.y))
		if location in parent.block_dict:
			parent.block_dict[location].node = self
			init(parent.block_dict[location].id, parent.block_dict[location].settings)
			name = location


func set_block_texture():
	BlockManager.get_block_texture(id)
