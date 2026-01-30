class_name Item extends Area2D

# For example, break item, pickup item, etc
@export var action_text: String = ""
@export_enum("sadness", "anxiety", "anger", "fear", "shame") var avatar_quest = ""

func get_interaction_text() -> String:
	assert(action_text, "Did not assign text on item")
	return "Press 'E' to " + action_text

func interact() -> void:
	if avatar_quest:
		QuestManager.set(avatar_quest + "_quest", true)
		queue_free()
