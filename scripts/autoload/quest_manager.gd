extends Node

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogue_event)
	
func _on_dialogue_event(dictonary: Dictionary) -> void:
	var avatar_name = dictonary.keys()[0]
	var avatar_function = dictonary.values()[0]
	var avatar: Avatar = get_tree().current_scene.find_child(avatar_name + "Avatar")
	avatar.call(avatar_function)
	if avatar_function == "break_player_mask":
		var player: Player = get_tree().get_first_node_in_group("player")
		player.new_ability_unlocked = avatar.player_ability_unlock
