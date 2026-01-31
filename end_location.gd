class_name EndLocation extends Area2D

func _ready() -> void:
	Dialogic.signal_event.connect(func(args):
		if args is Dictionary:
			var avatar_name = (args.keys()[0] as String).to_pascal_case()
			var mask = find_child(avatar_name+ "Mask")
			mask.visible = true
	)
