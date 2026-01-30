extends Area2D

@export var running_witch: RunningWitch
@export var direction_to_run: int

func _ready() -> void:
	assert(direction_to_run != 0)

func _on_body_entered(player: Player) -> void:
	if !running_witch.chasing_player:
		running_witch.show_behind_player(player, direction_to_run)
	else:
		running_witch.dissipate()
