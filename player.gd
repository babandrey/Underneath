class_name Player extends CharacterBody2D

@export var speed = 300.0
@export var acceleration = 300.0
@export var deacceleration = 300.0
@export var jump_velocity = 400.0
@export var gravity = 980.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deacceleration)

	move_and_slide()
