extends RigidBody2D

class_name BowlingBall

@export var velocityMultiplicator: int = 3
@export var massMultiplicator: float = 2

@onready var masked: Node2D = $CanvasGroup/Masked

var controllable: bool = false
var lastVelocity: Vector2 = Vector2.ZERO
var lastPosition: Vector2 = position

func _process(_delta: float) -> void:
	lastVelocity = linear_velocity
	lastPosition = position

func _ready() -> void:
	Global.levelLoaded.connect(onLevelLoaded)
	Global.levelComplete.connect(onLevelComplete)

func _unhandled_input(event: InputEvent) -> void:
	if not controllable: return
	handleClick(event)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var isAudioPlayer = body is Background or body is BowlingPin
	if not isAudioPlayer or Global.ballCount < 0: return
	var clampedVelocity: float = clamp(lastVelocity.length(), 0, 2500)
	var mappedVelocity: float = remap(clampedVelocity, 0, 2500, -12, 0)
	body.hitAudioPlayer.volume_db = mappedVelocity
	body.hitAudioPlayer.play()

func handleClick(event: InputEvent) -> void:
	var isEcho: bool = event.is_echo()
	var isLeftClick: bool = event.is_action("click_left")
	var isReleased: bool = event.is_released()
	var hasPosition: bool = "global_position" in event
	if not isLeftClick or not hasPosition or isEcho or not isReleased: return
	apply_central_impulse((get_global_mouse_position() - global_position) * velocityMultiplicator * mass)
	Global.ballCount += 1

func onLevelLoaded() -> void:
	Global.ball = self
	Global.cameraTarget = self
	controllable = true

func onLevelComplete() -> void:
	controllable = false
