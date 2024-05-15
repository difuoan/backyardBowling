extends TextureRect

@export var fadeSpeed: float = 4

func _ready() -> void:
	Global.kill.connect(onKill)
	modulate.a = 0

func onKill(_victim: Node2D) -> void:
	modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0 / fadeSpeed)
