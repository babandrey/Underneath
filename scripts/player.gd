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

var is_swimming := false
var is_talking := false

var can_swim := false
var can_run := false
var can_go_through_dark := false
var can_break_barriers := false
var can_teleport := false

var last_floor := false

@onready var respawn_position := global_position

var ability_unlock_dict: Dictionary[Ability, Callable] = {
	Ability.Swim: func(): can_swim = true,
	Ability.Run: func(): can_run = true,
	Ability.GoThroughDark: func(): can_go_through_dark = true,
	Ability.BreakBarriers: func(): can_break_barriers = true,
	Ability.ShameAbility: func(): can_teleport = true
}

enum Ability
{
	None,
	Swim,
	Run,
	GoThroughDark,
	BreakBarriers,
	ShameAbility
}

@export_group("Refs")
@export var sprite: AnimatedSprite2D
@export var vignette: ColorRect
@export var interact_label: Label
@export var new_ability_label_description: RichTextLabel
@export var camera: Camera2D
@onready var new_ability_labels: MarginContainer = %NewAbilityLabels
@export var teleporter: Marker2D

var new_ability_unlocked := Ability.None

@onready var vignette_material: ShaderMaterial = vignette.material
@onready var footstep_audio_player: AudioStreamPlayer = $FootstepAudioPlayer
@onready var footstep_timer: Timer = $FootstepTimer

var avatar_in_area: Avatar = null
var item_in_area: Item = null
var barrier_in_area: Barrier = null
var in_end_location = false
var buffer_teleport = false

func _ready() -> void:
	assert(teleporter)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)
	vignette.show()
	new_ability_labels.show()
	new_ability_labels.modulate.a = 0.0
	
	AudioManager.play_ambient()
	AudioManager.play_main_music() # if has main menu, start play in there
	
	Dialogic.signal_event.connect(func(args):
		if args is String:
			if args == "teleport_to_start_location":
				buffer_teleport = true
	)
	Dialogic.timeline_ended.connect(func():
		if buffer_teleport:
			teleport_to_start_location()
		)

func _physics_process(delta: float) -> void:
	var last_vel = velocity
	
	var g = water_gravity if is_swimming else gravity
	var acc = water_acceleration if is_swimming else acceleration
	var deacc = water_deaccelartion if is_swimming else deacceleration
	var spd = water_speed if is_swimming else speed
	var jump_vel = water_jump_velocity if is_swimming else jump_velocity
	
	if not is_on_floor():
		velocity.y += g * delta
		if is_swimming:
			velocity.y = min(max_water_gravity_velocity, velocity.y)
	
	if is_talking:
		velocity.x = move_toward(velocity.x, 0.0, deacc)
		move_and_slide()
		return
	
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
			sprite.play("idle")
			is_talking = true
		elif item_in_area:
			item_in_area.interact()
			item_in_area = null
		elif barrier_in_area:
			barrier_in_area.break_barrier()
			barrier_in_area = null
		elif in_end_location:
			var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(%FadeScreen, "color:a", 1.0, 3.0)
			is_talking = true
			await tween.finished
			get_tree().change_scene_to_file("res://scenes/end_game_screen.tscn")
			
		interact_label.text = ""
		# TODO: once back from talking section you can put the activate the interact label again
	
	# Animation
	if direction != 0:
		if last_vel.x == 0: # start running
			sprite.play("walk_start")
		
		if direction > 0:
			sprite.flip_h = false
		elif direction < 0:
			sprite.flip_h = true
	else:
		sprite.play(&"idle")
	
	# Audio
	if is_on_floor() and direction != 0:
		if (last_vel.x == 0 or last_floor != true) and footstep_timer.is_stopped(): # start running
			footstep_audio_player.play()
			footstep_timer.start()
	
	last_floor = is_on_floor()
	
	move_and_slide()

func start_swim() -> void:
	is_swimming = true
	velocity.y = 0.0

func stop_swim() -> void:
	is_swimming = false

func should_run() -> bool:
	return can_run and !is_swimming and Input.is_action_pressed("run")

func respawn() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(%FadeScreen, "color:a", 1.0, 0.35)
	await tween.finished
	global_position = respawn_position
	camera.position_smoothing_enabled = false
	camera.global_position = global_position
	await get_tree().process_frame
	camera.position_smoothing_enabled = true
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(%FadeScreen, "color:a", 0.0, 2.0)

func unlock_ability(ability: Ability) -> void:
	assert(ability in ability_unlock_dict, "No ability entry in ability unlock dictionary.")
	ability_unlock_dict[ability].call()

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Avatar:
		var avatar: Avatar = area as Avatar
		avatar_in_area = avatar
		show_interact_avatar_text()
	elif area is Item:
		var item = area as Item
		item_in_area = item
		interact_label.text = area.get_interaction_text()
	elif area is Barrier and can_break_barriers:
		var barrier = area as Barrier
		if barrier.barrier_active:
			barrier_in_area = barrier
			interact_label.text = barrier.get_interaction_text()
	elif area is EndLocation:
		if got_all_abilitties():
			interact_label.text = "Press 'E' to end the game."
			in_end_location = true
			
func got_all_abilitties() -> bool:
	return can_swim and can_break_barriers and can_go_through_dark and can_run and can_teleport

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area == avatar_in_area:
		avatar_in_area = null
		interact_label.text = ""
	elif area == item_in_area:
		item_in_area = null
		interact_label.text = ""
	elif area == barrier_in_area:
		barrier_in_area = null
		interact_label.text = ""
	elif area is EndLocation:
		interact_label.text = ""

func _on_dialogue_ended() -> void:
	is_talking = false
	if avatar_in_area:
		show_interact_avatar_text()
	if new_ability_unlocked != Ability.None:
		show_new_ability(new_ability_unlocked)
		new_ability_unlocked = Ability.None

func show_interact_avatar_text() -> void:
	var avatar_name = avatar_in_area.avatar_name.to_pascal_case()
	avatar_name = avatar_name if Dialogic.VAR.get(avatar_name).is_colored else "???"
	interact_label.text = "Press 'E' to talk to " + avatar_name

func show_new_ability(new_ability: Ability) -> void:
	if new_ability == Ability.ShameAbility: return
	
	const NORMAL_VIGNETTE = 1.3
	const FULL_VIGNETTE = 1.6
	
	AudioManager.play("unlock_ability")
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_method(vignette_change_alpha, NORMAL_VIGNETTE, FULL_VIGNETTE, 1.0)
	tween.tween_property(new_ability_labels, "modulate:a", 1.0, 3.0)
	var text: String
	match new_ability:
		Ability.Swim: text = "You can now swim in [color=cornflower_blue][b][wave amp=30.0 freq=3.5 connected=1]water[/wave][/b][/color].."
		Ability.Run: text = "You can now press 'Shift' to [color=khaki][b]run[/b][/color]."
		Ability.GoThroughDark: text = "You are no longer afraid of [color=indigo]the darkness[/color]."
		Ability.BreakBarriers: text = "You can now interact to [color=orange_red]break barriers[/color]."
		# TODO: add last ability
		_: push_error("unknown ability")
		
	new_ability_label_description.text = text
	await tween.finished
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_method(vignette_change_alpha, FULL_VIGNETTE, NORMAL_VIGNETTE, 3.0).set_delay(1.0)
	tween.tween_property(new_ability_labels, "modulate:a", 0.0, 3.0).set_delay(1.0)
	
func vignette_change_alpha(value: float) -> void:
	vignette_material.set_shader_parameter("vignette_strength", value)

func _on_animated_sprite_animation_finished() -> void:
	if sprite.animation == "walk_start":
		sprite.play("walk_loop")

func teleport_to_start_location() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(%FadeScreen, "color:a", 1.0, 2.0)
	await tween.finished
	global_position = teleporter.global_position
	camera.position_smoothing_enabled = false
	camera.global_position = global_position
	await get_tree().process_frame
	camera.position_smoothing_enabled = true
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(%FadeScreen, "color:a", 0.0, 2.0)
	buffer_teleport = false

func _on_footstep_timer_timeout() -> void:
	if velocity.x != 0 and is_on_floor():
		footstep_audio_player.play()
	else:
		footstep_timer.stop()
