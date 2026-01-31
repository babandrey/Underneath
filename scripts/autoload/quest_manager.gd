extends Node

const world_grayscale_shader: ShaderMaterial = preload("uid://bwyc4afcikibs")
var shader_param_name := ""

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogue_event)
	
func _on_dialogue_event(args) -> void:
	if args is Dictionary:
		var avatar_name = args.keys()[0]
		var avatar_function = args.values()[0]
		var avatar: Avatar = get_tree().current_scene.find_child(avatar_name + "Avatar")
		avatar.call(avatar_function)
		if avatar_function == "break_player_mask":
			AudioManager.play("break_player_mask")
			AudioManager.add_music_layer(avatar.player_ability_unlock)
			var player: Player = get_tree().get_first_node_in_group("player")
			player.new_ability_unlocked = avatar.player_ability_unlock
			shader_param_name = avatar.unlock_color + "_anim"
			var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_method(change_color_animation, 0.0, 1.0, 5.0)
			await tween.finished
			shader_param_name = ""
		elif avatar_function == "complete_quest":
			AudioManager.play("avatar_colored")

func change_color_animation(value: float) -> void:
	world_grayscale_shader.set_shader_parameter(shader_param_name, value)
