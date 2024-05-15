extends Sprite2D

@export var initialVisibility: bool = false

var audio: AudioStreamPlayer

func _ready() -> void:
	if get_child_count() > 0: audio = $AudioStreamPlayer
	visible = initialVisibility
	Global.levelComplete.connect(onLevelComplete)

func onLevelComplete() -> void:
	if audio: audio.play()
	visible = not initialVisibility
