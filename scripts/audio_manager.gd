extends Node2D

@onready var generic_pickup: AudioStreamPlayer = $GenericPickup
@onready var forest_ambient: AudioStreamPlayer = $ForestAmbient
@onready var spider_pickup: AudioStreamPlayer = $SpiderPickup
@onready var crystal_ball_pickup: AudioStreamPlayer = $CrystalBallPickup
@onready var stick_pickup: AudioStreamPlayer = $StickPickup
@onready var water_bucket_pickup: AudioStreamPlayer = $WaterBucketPickup
@onready var main_music: AudioStreamPlayer = $MainMusic
@onready var break_player_mask: AudioStreamPlayer = $BreakPlayerMask
@onready var avatar_colored: AudioStreamPlayer = $AvatarColored

@onready var sounds: Dictionary[String, AudioStreamPlayer]= {
	"pickup": generic_pickup,
	"spider": spider_pickup,
	"crystal_ball": crystal_ball_pickup,
	"water_bucket": water_bucket_pickup,
	"stick": stick_pickup,
	"avatar_colored": avatar_colored,
	"break_player_mask": break_player_mask
}

func play(sound_name: String) -> void:
	sounds[sound_name].play()

func play_ambient() -> void:
	forest_ambient.play()

func stop_ambient() -> void:
	forest_ambient.stop()
