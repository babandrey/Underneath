extends Node2D

@onready var generic_pickup: AudioStreamPlayer = $GenericPickup
@onready var spider_pickup: AudioStreamPlayer = $SpiderPickup
@onready var crystal_ball_pickup: AudioStreamPlayer = $CrystalBallPickup
@onready var stick_pickup: AudioStreamPlayer = $StickPickup
@onready var water_bucket_pickup: AudioStreamPlayer = $WaterBucketPickup
@onready var break_player_mask: AudioStreamPlayer = $BreakPlayerMask
@onready var avatar_colored: AudioStreamPlayer = $AvatarColored

@onready var intro_music: AudioStreamPlayer = $IntroMusic
@onready var intro_music_stream: AudioStreamSynchronized = intro_music.stream

@onready var main_music: AudioStreamPlayer = $MainMusic
@onready var music_audio_stream: AudioStreamSynchronized = main_music.stream

@onready var sounds: Dictionary[String, AudioStreamPlayer]= {
	"pickup": generic_pickup,
	"spider": spider_pickup,
	"crystal_ball": crystal_ball_pickup,
	"water_bucket": water_bucket_pickup,
	"stick": stick_pickup,
	"avatar_colored": avatar_colored,
	"break_player_mask": break_player_mask
}

@onready var forest_ambient: AudioStreamPlayer = $ForestAmbient
@onready var forest_volume := forest_ambient.volume_linear

var in_main_music = false
var current_stream_index = -1
signal transition_to_main_music

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogue_event)
	play_intro_music()

func _on_dialogue_event(dictonary: Dictionary) -> void:
	if not in_main_music:
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		current_stream_index = 1
		tween.tween_method(lerp_current_volume_thingy, -60.0, 0.0, 5.0)
		print("INTRO MUSIC WAITING")
		await transition_to_main_music
		print("INTRO MUSIC FINISHED")
		current_stream_index = -1
		intro_music.stop()
		play_main_music()
		in_main_music = true

func play_intro_music() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	current_stream_index = 0
	tween.tween_method(lerp_current_volume_thingy, -60.0, 0.0, 5.0)
	intro_music.play()
	var time = intro_music_stream.get_sync_stream(0).get_length()
	get_tree().create_timer(time).timeout.connect(func():
		transition_to_main_music.emit()
	)
	await tween.finished
	current_stream_index = -1

func play_main_music() -> void:
	main_music.play()

func lerp_current_volume_thingy(value: float) -> void:
	if in_main_music:
		music_audio_stream.set_sync_stream_volume(current_stream_index, value)
	else:
		intro_music_stream.set_sync_stream_volume(current_stream_index, value)

func add_music_layer(layer: Player.Ability) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	current_stream_index = layer
	tween.tween_method(lerp_current_volume_thingy, -60.0, 0.0, 5.0)
	await tween.finished
	current_stream_index = -1

func play(sound_name: String) -> void:
	sounds[sound_name].play()

func play_ambient() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(forest_ambient, "volume_linear", forest_volume, 4.0).from(0.0)
	forest_ambient.play()

func stop_ambient() -> void:
	forest_ambient.stop()
