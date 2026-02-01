extends Area2D

@export var audio_player: AudioStreamPlayer2D

func _on_body_entered(player: Player) -> void:
	print("hi")
	audio_player.play(randf_range(0.0, audio_player.stream.get_length()))

func _on_body_exited(player: Player) -> void:
	print("bye")
	audio_player.stop()
