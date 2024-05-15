extends Node

@export var ball: BowlingBall
@export var ballCounter: Label
@export var ballCount: int = 0:
	set(newCount):
		ballCount = newCount
		if not ballCounter: return
		ballCounter.text = str(newCount)
		if ballCount == 1: levelStart.emit()
		updateUi.emit()
@export var pins: Array[BowlingPin] = []
@export var hitPins: Array[BowlingPin] = []
@export var pinCounter: Label
@export var pinSize: int = 0:
	get:
		return pins.size()
	set(newSize):
		pinSize = newSize
		updateUi.emit()
@export var pinCount: int = 0
@export var levelCamera: Camera2D
@export var cameraTarget: Node
@export var nextScene: PackedScene

signal levelStart
signal levelComplete
signal levelLoaded
signal kill(victim: Node2D)
signal updateUi

func _ready():
	kill.connect(onKill)

func onKill(victim: Node2D) -> void:
	hitPins.append(victim)
	pinCount += 1
	if pinCounter: pinCounter.text = str(pinCount) + "/" + str(pinSize)
	updateUi.emit()
	if pinCount >= pinSize and pinSize != 0: onLevelComplete()

func onLevelComplete() -> void:
	Engine.time_scale = 0.1
	levelComplete.emit()
