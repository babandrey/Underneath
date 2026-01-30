class_name Player extends CharacterBody2D

@export var speed = 300.0
@export var acceleration = 300.0
@export var deacceleration = 300.0
@export var jump_velocity = 400.0
@export var gravity = 980.0

@export var water_speed = 170.0
@export var water_acceleration = 10.0
@export var water_deaccelartion = 10.0
@export var water_jump_velocity = 250.0
@export var water_gravity = 200.0
@export var max_water_gravity_velocity = 200.0

var can_swim := false
var is_swimming = false

@onready var start_position := global_position

var ability_unlock_dict: Dictionary[Ability, Callable] = {
	Ability.Swim: unlock_swim,
}

enum Ability
{
	None,
	Swim,
	Run,
	DoubleJump
}

@export var interact_label: Label
var avatar_in_area: Avatar = null

func _physics_process(delta: float) -> void:
	var g = water_gravity if is_swimming else gravity
	var acc = water_acceleration if is_swimming else acceleration
	var deacc = water_deaccelartion if is_swimming else deacceleration
	var spd = water_speed if is_swimming else speed
	var jump_vel = water_jump_velocity if is_swimming else jump_velocity
	
	if not is_on_floor():
		velocity.y += g * delta
		if is_swimming:
			velocity.y = min(max_water_gravity_velocity, velocity.y)

	if Input.is_action_just_pressed("jump"):
		if is_swimming or is_on_floor():
			velocity.y = -jump_vel

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * spd, acc)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deacc)
	
	if Input.is_action_just_pressed("interact") and avatar_in_area:
		avatar_in_area.talk()
		interact_label.text = ""
	
	move_and_slide()

func unlock_swim() -> void:
	can_swim = true

func start_swim() -> void:
	is_swimming = true
	velocity.y = clampf(velocity.y, 0.0, velocity.y - 200.0)

func stop_swim() -> void:
	is_swimming = false

func respawn() -> void:
	global_position = start_position

func unlock_ability(ability: Ability) -> void:
	ability_unlock_dict[ability].call()

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Avatar:
		var avatar: Avatar = area as Avatar
		avatar_in_area = avatar
		interact_label.text = "Press 'E' to talk to " + avatar.avatar_name

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is Avatar and area == avatar_in_area:
		avatar_in_area = null
		interact_label.text = ""
