class_name Barrier extends Area2D

@export var barrier_name: String
@export var barrier_static: StaticBody2D

var barrier_active = true

func _ready() -> void:
	assert(barrier_name)

func get_interaction_text() -> String:
	if barrier_active:
		return "Press 'E' to break " + barrier_name
	else:
		return ""

func break_barrier() -> void:
	barrier_static.queue_free()
	barrier_active = false
