extends Area2D

func _on_body_entered(player: Player) -> void:
	if not player.can_go_through_dark:
		player.is_talking = true
		get_tree().create_timer(1.5).timeout.connect(func():
			player.respawn()
			player.is_talking = false
		)
	else:
		print("went through dark")

func _on_body_exited(player: Player) -> void:
	if player.can_go_through_dark:
		pass # TODO stop scary sounds that started on body entered
