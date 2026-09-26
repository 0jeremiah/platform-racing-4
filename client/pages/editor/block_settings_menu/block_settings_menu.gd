extends Control

@onready var tab_bar = $TabBar
@onready var no_settings_available_text = $NoSettingsAvailableText
@onready var settings_menu = $SettingsMenu
@onready var side_settings_menu = $SideSettingsMenu

static var block_setting_tab: int = 0

var block_settings: ConfigurableBlockSettings = ConfigurableBlockSettings.new()
var container_size: Vector2 = Vector2(488.0, 298.0)


func _ready() -> void:
	tab_bar.tab_changed.connect(_change_tab)
	tab_bar.current_tab = block_setting_tab
	_change_tab(block_setting_tab)


func init(new_block_settings: ConfigurableBlockSettings):
	block_settings = new_block_settings
	settings_menu.init(block_settings)
	side_settings_menu.init(block_settings)
	update_display()


func _change_tab(new_index: int):
	block_setting_tab = new_index
	update_display()


func update_display():
	settings_menu.visible = false
	side_settings_menu.visible = false
	no_settings_available_text.visible = false
	if tab_bar.current_tab == 0:
		if settings_menu.has_settings:
			no_settings_available_text.visible = false
			settings_menu.visible = true
		else:
			no_settings_available_text.text = "No settings available. :("
			no_settings_available_text.visible = true
	elif tab_bar.current_tab == 1:
		if side_settings_menu.has_side_settings:
			no_settings_available_text.visible = false
			side_settings_menu.visible = true
		else:
			no_settings_available_text.text = "No side settings available. :("
			no_settings_available_text.visible = true
	else:
		no_settings_available_text.text = "Either no setting tabs exist, or tab is indexed out of bounds. :("
		no_settings_available_text.visible = true


func update_settings(new_settings: Dictionary):
	settings_menu._update_settings(new_settings)
	update_display()


func update_settings_menu():
	settings_menu.update_enabled_settings()
	update_display()


func update_side_settings(updated_side_settings: Dictionary):
	side_settings_menu._update_sides(updated_side_settings)
	update_display()


func change_container_size(new_container_size: Vector2):
	settings_menu.change_container_size(new_container_size)
	side_settings_menu.change_container_size(new_container_size)
