extends Sprite2D

@export var growSpeed: float = 4
@export var fadeThreshhold: float = 2
@export var fadeTime: float = 2

var initialScale: Vector2
var initialAlpha: float
var growing: bool = true

func _ready() -> void:
	initialAlpha = modulate.a
	initialScale = scale
	scale = Vector2.ZERO
	Global.cameraTarget = self

func _process(delta: float) -> void:
	scale += initialScale / (1 / growSpeed) * delta
	if scale.x > fadeThreshhold:
		modulate.a -= 1 / (1 / growSpeed) * delta
		if modulate.a <= 0:
			Global.cameraTarget = Global.ball
			queue_free()
