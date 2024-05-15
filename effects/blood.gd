extends Sprite2D

@onready var growthTimer: Timer = $GrowthTimer
@onready var fadeTimer: Timer = $FadeTimer

var initialScale: Vector2
var initialAlpha: float
var growing: bool = true

func _ready():
	initialAlpha = modulate.a
	initialScale = scale
	scale = Vector2.ZERO

func _process(delta: float) -> void:
	if growing: grow(delta)
#	else: fade(delta)

func grow(delta: float) -> void:
	scale += initialScale / growthTimer.wait_time * delta

func fade(delta: float) -> void:
	modulate.a -= initialAlpha / fadeTimer.wait_time * delta

func _on_fade_timer_timeout() -> void:
	queue_free()

func _on_growth_timer_timeout() -> void:
#	fadeTimer.start()
	growing = false
