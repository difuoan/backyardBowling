extends Node2D

@export var firstLevel: PackedScene

func _on_new_game_button_button_up():
	get_tree().change_scene_to_packed(firstLevel)

func _on_load_game_button_button_up():
	print("not done yet!")

func _on_options_button_up():
	print("not done yet!")
