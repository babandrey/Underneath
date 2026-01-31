class_name RunningWitch extends Area2D

var direction_to_player := 0
 ## make sure this is between walking and running speed of player
@export var speed = 400.0
@export var intial_distance_to_player = 300.0

var chasing_player = false
var tween: Tween

func _ready() -> void:
	modulate.a = 0.0

func _physics_process(delta: float) -> void:
	if chasing_player:
		global_position.x += direction_to_player * speed * delta

func _on_body_entered(player: Player) -> void:
	if chasing_player:
		player.respawn()
		chasing_player = false
		if tween and tween.is_valid() and tween.is_running():
			tween.kill()
		modulate.a = 0.0

func show_behind_player(player: Player, direction_x) -> void:
	chasing_player = true
	direction_to_player = direction_x
	$Sprite2D.flip_h = direction_to_player == -1
	global_position.x = player.global_position.x - direction_to_player * intial_distance_to_player
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 1.0, 2.0)
	 
func dissipate() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	await tween.finished
	chasing_player = false
