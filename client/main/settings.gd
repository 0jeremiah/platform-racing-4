class_name Settings

const tile_size = Vector2i(128, 128)
const tile_size_half = Vector2i(64, 64)
static var user_id: int = -1
static var user_nickname: String = ""
static var my_character: Dictionary = {
	"rank": 0,
	"speed": 50,
	"accel": 50,
	"jump": 50,
	"skill": 50,
	"hat": "1",
	"head": "1",
	"body": "1",
	"feet": "1",
	"hat_color": "ffffff",
	"head_color": "ffffff",
	"body_color": "ffffff",
	"feet_color": "ffffff",
	"hat_epic_color": "000000",
	"head_epic_color": "000000",
	"body_epic_color": "000000",
	"feet_epic_color": "000000"
}
static var music_on: bool = true
static var sound_on: bool = true
