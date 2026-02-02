extends Node2D

@onready var generic_pickup: AudioStreamPlayer = $GenericPickup
@onready var spider_pickup: AudioStreamPlayer = $SpiderPickup
@onready var crystal_ball_pickup: AudioStreamPlayer = $CrystalBallPickup
@onready var stick_pickup: AudioStreamPlayer = $StickPickup
@onready var water_bucket_pickup: AudioStreamPlayer = $WaterBucketPickup
@onready var diary_pickup: AudioStreamPlayer = $DiaryPickup
@onready var break_player_mask: AudioStreamPlayer = $BreakPlayerMask
@onready var avatar_colored: AudioStreamPlayer = $AvatarColored
@onready var unlock_ability: AudioStreamPlayer = $UnlockAbility
@onready var break_barrier: AudioStreamPlayer = $BreakBarrier

@onready var intro_music: AudioStreamPlayer = $IntroMusic
@onready var intro_music_stream: AudioStreamSynchronized = intro_music.stream

@onready var main_music: AudioStreamPlayer = $MainMusic
var playback: AudioStreamPlaybackInteractive

@onready var sounds: Dictionary[String, AudioStreamPlayer]= {
	"pickup": generic_pickup,
	"spider": spider_pickup,
	"crystal_ball": crystal_ball_pickup,
	"water_bucket": water_bucket_pickup,
	"stick": stick_pickup,
	"diary": diary_pickup,
	"avatar_colored": avatar_colored,
	"break_player_mask": break_player_mask,
	"unlock_ability": unlock_ability,
	"break_barrier": break_barrier
}

@onready var forest_ambient: AudioStreamPlayer = $ForestAmbient
@onready var forest_volume := forest_ambient.volume_linear

var in_main_music = false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogue_event)

func _on_dialogue_event(dictonary: Dictionary) -> void:
	var avatar_function = dictonary.values()[0]
	if not in_main_music and avatar_function == "complete_quest":
		playback.switch_to_clip_by_name("intro_transition")
		in_main_music = true

func play_main_music() -> void:
	main_music.play()
	playback = main_music.get_stream_playback()

func add_music_layer(layer_name: StringName) -> void:
	playback.switch_to_clip_by_name(layer_name.to_snake_case())

func play(sound_name: String) -> void:
	sounds[sound_name].play()

func play_ambient() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(forest_ambient, "volume_linear", forest_volume, 4.0).from(0.0)
	forest_ambient.play()

func stop_ambient() -> void:
	forest_ambient.stop()
