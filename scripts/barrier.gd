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
	var tween = create_tween().set_parallel()
	for body: RigidBody2D in $RocksRigidbodies.get_children():
		body.freeze = false
		tween.tween_property(body, "modulate:addd", 0.0, 3.0)
	barrier_active = false
