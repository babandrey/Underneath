extends Node

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogue_event)
	
func _on_dialogue_event(dictonary: Dictionary) -> void:
	var avatar_name = dictonary.keys()[0]
	var avatar_function = dictonary.values()[0]
	var avatar: Avatar = get_tree().current_scene.find_child(avatar_name + "Avatar")
	avatar.call(avatar_function)
