class_name Player extends CharacterBody2D

@export_group("Normal Movement")
@export var speed = 300.0
@export var acceleration = 300.0
@export var deacceleration = 300.0
@export var jump_velocity = 400.0
@export var gravity = 980.0
@export var running_speed = 450.0

@export_group("Water Movement")
@export var water_speed = 170.0
@export var water_acceleration = 10.0
@export var water_deaccelartion = 10.0
@export var water_jump_velocity = 250.0
@export var water_gravity = 200.0
@export var max_water_gravity_velocity = 200.0

var can_swim := false
var is_swimming := false
var is_talking := false

var can_run := false
var can_go_through_dark := false

@onready var start_position := global_position

var ability_unlock_dict: Dictionary[Ability, Callable] = {
	Ability.Swim: unlock_swim,
	Ability.Run: unlock_run,
}

enum Ability
{
	None,
	Swim,
	Run,
	DoubleJump
}

@export_group("Refs")
@export var sprite: AnimatedSprite2D
@export var vignette: ColorRect
@export var interact_label: Label
@export var camera: Camera2D

var avatar_in_area: Avatar = null
var item_in_area: Item = null

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogue_ended)
	vignette.show()

func _physics_process(delta: float) -> void:
	if is_talking: return
	
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
		if should_run():
			spd = running_speed
			
		velocity.x = move_toward(velocity.x, direction * spd, acc)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deacc)
	
	if Input.is_action_just_pressed("interact"):
		if avatar_in_area:
			avatar_in_area.talk()
			is_talking = true
		elif item_in_area:
			item_in_area.interact()
		
		interact_label.text = ""
		# TODO: once back from talking section you can put the activate the interact label again
	
	# Animation
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
	
	move_and_slide()

func unlock_swim() -> void:
	can_swim = true

func start_swim() -> void:
	is_swimming = true
	velocity.y = clampf(velocity.y, 0.0, velocity.y - 200.0)

func stop_swim() -> void:
	is_swimming = false

func unlock_run() -> void:
	can_run = true

func unlock_dark() -> void:
	can_go_through_dark = true

func should_run() -> bool:
	return can_run and !is_swimming and is_on_floor() and Input.is_action_pressed("run")

func respawn() -> void:
	global_position = start_position
	camera.position_smoothing_enabled = false
	camera.global_position = start_position
	await get_tree().process_frame
	camera.position_smoothing_enabled = true

func unlock_ability(ability: Ability) -> void:
	assert(ability in ability_unlock_dict, "No ability entry in ability unlock dictionary.")
	ability_unlock_dict[ability].call()

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Avatar:
		var avatar: Avatar = area as Avatar
		avatar_in_area = avatar
		interact_label.text = "Press 'E' to talk to " + avatar.avatar_name
	elif area is Item:
		var item = area as Item
		item_in_area = item
		interact_label.text = area.get_interaction_text()

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is Avatar and area == avatar_in_area:
		avatar_in_area = null
		interact_label.text = ""

func _on_dialogue_ended() -> void:
	is_talking = false
	if avatar_in_area:
		interact_label.text = "Press 'E' to talk to " + avatar_in_area.avatar_name
