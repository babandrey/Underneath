class_name Item extends Area2D

# For example, break item, pickup item, etc
@export var item_name: String
@export var action_text: String = ""
@export_enum("sadness", "anxiety", "anger", "fear", "shame") var avatar_quest = ""

func _ready() -> void:
	assert(item_name)

func get_interaction_text() -> String:
	assert(action_text, "Did not assign text on item")
	return "Press 'E' to " + action_text

func interact() -> void:
	if avatar_quest:
		Dialogic.VAR.get(avatar_quest.to_pascal_case()).quest_completed = true		
		AudioManager.play("pickup")
		AudioManager.play(item_name)
		queue_free()
