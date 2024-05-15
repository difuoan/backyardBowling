extends VBoxContainer

@export var pinCounterItem: PackedScene = preload("res://ui/pin_counter_item.tscn")

func _ready() -> void:
	Global.updateUi.connect(onUpdateUi)

func onUpdateUi() -> void:
	clearChildren()
	addChildren()

func clearChildren() -> void:
	for child in get_children():
		child.queue_free()

func addChildren() -> void:
	for pin in Global.pins:
		var child: PinCounterItem = pinCounterItem.instantiate() as PinCounterItem
		self.add_child(child)
		child.crossTexture.visible = Global.hitPins.has(pin)
		child.crossTexture.rotation_degrees = pin.pinCountercrossRotation
		child.pinTexture.rotation_degrees = pin.pinCounterRotation
