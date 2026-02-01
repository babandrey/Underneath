extends Area2D

@onready var waterfall_sound: AudioStreamPlayer2D = %WaterfallSound

func _on_body_entered(player: Player):
	if player.can_swim:
		player.start_swim()
	else:
		player.respawn()

func _on_body_exited(player: Player):
	if player.can_swim and player.is_swimming:
		player.stop_swim()

func _on_player_detection_zone_body_entered(player: Player) -> void:
	waterfall_sound.play(randf_range(0.0, waterfall_sound.stream.get_length()))

func _on_player_detection_zone_body_exited(player: Player) -> void:
	waterfall_sound.stop()
