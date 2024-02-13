extends CanvasLayer

@onready var world = $"../../../"

func _on_resume_button_pressed():
	world.pauseMenu()

func _on_quit_button_pressed():
	# Lataa päävalikon kohtauksen
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://menu.tscn")  
