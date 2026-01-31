class_name FearAvatar extends Avatar

@export var animated_sprite: AnimatedSprite2D

func _ready() -> void:
	animated_sprite.material = animated_sprite.material.duplicate()
	avater_material = animated_sprite.material
	Dialogic.signal_event.connect(animated_sprite.play)
