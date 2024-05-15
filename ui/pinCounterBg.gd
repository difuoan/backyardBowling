extends TextureRect

@export var itemSize: float = 25
@export var itemGap: float = 5

@onready var originalPosition: Vector2

func _ready() -> void:
	originalPosition = position
	Global.updateUi.connect(onUpdateUi)

func onUpdateUi() -> void:
	position = originalPosition + Vector2(0, (itemSize + itemGap) * (Global.pinSize - 1))
