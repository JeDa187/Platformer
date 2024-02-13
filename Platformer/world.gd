extends Node2D

var pause_menu
var paused = false

func _ready():
	# Oletetaan, että "Player" on suora lapsi "world" nodesta ja "Camera2D" on "Player" noden lapsi.
	pause_menu = get_node_or_null("Player/Camera2D/PauseMenu")
	
	if pause_menu:
		pause_menu.hide()


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func pauseMenu():
	if pause_menu:
		if paused:
			pause_menu.hide()
			Engine.time_scale = 1
		else:
			pause_menu.show()
			Engine.time_scale = 0
		paused = !paused

