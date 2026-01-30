extends Area2D

func _on_body_entered(player: Player) -> void:
	player.respawn_position = global_position
