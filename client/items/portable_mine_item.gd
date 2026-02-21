extends PortableBlockItem
class_name PortableMineItem


func _ready():
	PortableBlock = load("res://item_effects/portable_mine.tscn")
	tile_id = 46
	icon = $PortableMineItem


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_portable_mine")


func process_item(_character: Character) -> void:
	set_block_position(_character)
	set_visuals(_character)


func activate_item(_character: Character):
	if !_character.item_manager.using and can_place:
		_character.item_manager.using = true
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_portable_mine")
		use_block(_character)
		_character.item_manager.uses -= 1
