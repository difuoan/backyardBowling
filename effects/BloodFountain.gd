extends Node2D

@export var fadeTime: float = 5

@onready var strongParticles: GPUParticles2D = $GPUParticles2D
@onready var weakParticles: GPUParticles2D = $GPUParticles2D2

func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(strongParticles, "modulate", Color.TRANSPARENT, fadeTime)
	tween.tween_property(weakParticles, "modulate", Color.WHITE, fadeTime)

func _on_timer_2_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(weakParticles, "modulate", Color.TRANSPARENT, fadeTime)
