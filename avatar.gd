class_name Avatar extends Area2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@export var avatar_name: String
@export var player_ability_unlock: Player.Ability
@export_enum("red", "blue", "green", "purple", "yellow") var unlock_color: String
@export var sprite: Sprite2D
@onready var avatar_material: ShaderMaterial = sprite.material

var mask_broken = false

func break_avatar_mask() -> void:
	# TODO: Break mask animation
	assert(unlock_color, "Didn't set unlock color")
	avatar_material.set_shader_parameter(unlock_color + "_open", true)
	mask_broken = true

func break_player_mask() -> void:
	# TODO: Relationship Status ?
	# TODO: change world shader to open color
	# TODO: await Player break mask animation 
	player.unlock_ability(player_ability_unlock)

func talk() -> void:
	# TODO: Dialogue system
	# temp just for debug
	if not mask_broken:
		break_avatar_mask()
	else:
		break_player_mask()
