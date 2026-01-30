extends Node

## QUESTS
var sadness_quest := false
var anxiety_quest := false
var anger_quest := false
var fear_quest := false
var shame_quest := false

var sadness_colored := false
var anxiety_colored := false
var anger_colored := false
var fear_colored := false
var shame_colored := false

var sadness_relationship := false
var anxiety_relationship := false
var anger_relationship := false
var fear_relationship := false
var shame_relationship := false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogue_event)
	
func _on_dialogue_event(dictonary: Dictionary) -> void:
	var avatar_name = dictonary.keys()[0]
	var avatar_function = dictonary.values()[0]
	var avatar: Avatar = get_tree().current_scene.find_child(avatar_name + "Avatar")
	avatar.call(avatar_function)
