extends Control

func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(%FadeScreen, "color:a", 0.0, 2.0)
