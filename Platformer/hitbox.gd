extends Area2D


func _on_body_entered(body):
	if body is Player:
		# Kutsutaan Player-luokan restart_game-funktiota
		body.restart_game()
