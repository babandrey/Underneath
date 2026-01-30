extends Area2D

func _on_body_entered(player: Player):
	if player.can_swim:
		player.start_swim()
	else:
		player.respawn()

func _on_body_exited(player: Player):
	if player.can_swim and player.is_swimming:
		player.stop_swim()
