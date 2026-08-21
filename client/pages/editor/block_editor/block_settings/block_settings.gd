extends Control

@onready var settings_menu = $SettingsMenu
@onready var side_settings_menu = $SideSettingsMenu

var block_settings: ConfigurableBlockSettings = ConfigurableBlockSettings.new()


func _ready() -> void:
	settings_menu.init(block_settings)
	side_settings_menu.init(block_settings)
	maybe_enable_settings_menu()


func maybe_enable_settings_menu() -> void:
	settings_menu._maybe_enable_settings({
		"block_settings": {
			"general": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID, "setting": "general"},
			ConfigurableBlockSettings.MOVE: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.MOVE, "setting": ConfigurableBlockSettings.MOVE},
			ConfigurableBlockSettings.CHANGE: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.CHANGE, "setting": ConfigurableBlockSettings.CHANGE},
			"stat": {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and (block_settings.has_side_type(ConfigurableBlockSideSettings.CHANGE_STATS) or block_settings.has_side_type(ConfigurableBlockSideSettings.CUSTOM_STATS)), "setting": "stat"},
			ConfigurableBlockSideSettings.ITEM: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.ITEM), "setting": ConfigurableBlockSideSettings.ITEM},
			ConfigurableBlockSideSettings.TELEPORT: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT), "setting": ConfigurableBlockSideSettings.TELEPORT},
			ConfigurableBlockSideSettings.TIME: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.has_side_type(ConfigurableBlockSideSettings.TIME), "setting": ConfigurableBlockSideSettings.TIME},
			ConfigurableBlockSettings.GEAR: {"enabled": block_settings.matter_type == ConfigurableBlockSettings.SOLID and block_settings.block_type == ConfigurableBlockSettings.GEAR, "setting": ConfigurableBlockSettings.GEAR}
		}
	})
