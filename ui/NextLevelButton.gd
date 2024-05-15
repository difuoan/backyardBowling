extends Button

func _ready() -> void:
	Global.levelComplete.connect(onLevelComplete)

func onLevelComplete() -> void:
	visible = true
	disabled = false

func _on_button_up():
	get_tree().change_scene_to_packed(Global.nextScene)
