extends Node2D

@export var nextScene: PackedScene

func _ready() -> void:
	Engine.time_scale = 1
	Global.pinCount = 0
	Global.ballCount = 0
	Global.pins = []
	Global.nextScene = nextScene
	Global.levelLoaded.emit()
