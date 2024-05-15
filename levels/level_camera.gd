extends Camera2D

@export var followSpeed: float = 7.5
@export var zoomSpeed: float = 4
@export var finalZoom: float = 0.333
@export var minZoom: float = 0.1
@export var maxZoom: float = 1
@export var followDistance: float = 1

@onready var initialZoom: Vector2 = zoom

func _ready() -> void:
	Global.levelCamera = self
	Global.levelComplete.connect(onLevelComplete)

func _process(delta: float):
	followTarget(delta)
	zoomInOut(delta)

func onLevelComplete() -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "zoom", Vector2(finalZoom, finalZoom), 1 / zoomSpeed)

func followTarget(delta: float) -> void:
	position = position.lerp(
		get_global_mouse_position() * followDistance - global_position + Global.cameraTarget.position,
		delta * followSpeed * zoom.x
	)

func zoomInOut(_delta: float):
	if not (Input.is_action_just_pressed("ui_scroll_down") or Input.is_action_just_pressed("ui_scroll_up")): return
	var newZoom: float = zoom.x
	if Input.is_action_just_pressed("ui_scroll_down"):
		newZoom = clamp(zoom.x * (1 - (1 / zoomSpeed)), minZoom, maxZoom)
	elif Input.is_action_just_pressed("ui_scroll_up"):
		newZoom = clamp(zoom.x * (1 + (1 / zoomSpeed)), minZoom, maxZoom)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(newZoom, newZoom), (1 / zoomSpeed) * Engine.time_scale)
