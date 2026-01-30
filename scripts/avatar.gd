class_name Avatar extends Area2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@export var avatar_name: String
@export var player_ability_unlock: Player.Ability
@export_enum("red", "blue", "green", "purple", "yellow") var unlock_color: String
@export var sprite: Sprite2D

@onready var avatar_material: ShaderMaterial = sprite.material
var mask_broken = false

# FIRST WE BREAK AVATAR MASK, ONLY THEN WE CAN BREAK PLAYER AFTER QUEST COMPLETE

func break_avatar_mask() -> void:
	# TODO: Break mask animation
	assert(unlock_color, "Didn't set unlock color")
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_shader_value, 0.0, 1.0, 3.0)
	await tween.finished
	mask_broken = true
	prints("broke", avatar_name, "avater mask")

func set_shader_value(value: float) -> void:
	var param_name = unlock_color + "_anim"
	avatar_material.set_shader_parameter(param_name, value)

func break_player_mask() -> void:
	# TODO: Relationship Status ?
	# TODO: change world shader to open color
	# TODO: await Player break mask animation
	#await Dialogic.timeline_ended
	player.unlock_ability(player_ability_unlock)
	print("broke player avater mask")

func talk() -> void:
	Dialogic.start("main-timeline") # TODO: Change this to be based on avatar name
