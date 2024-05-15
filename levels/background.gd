extends StaticBody2D

class_name Background

@export var hitSound: AudioStream = preload("res://sound/ballDrop.mp3")
@export var massMultiplicator: float = 0.75

@onready var hitAudioPlayer: AudioStreamPlayer

func _ready():
	hitAudioPlayer = AudioStreamPlayer.new()
	add_child(hitAudioPlayer)
	hitAudioPlayer.stream = hitSound
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
