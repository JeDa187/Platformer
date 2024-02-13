extends Area2D

func _ready():
	$LockedSprite.visible = true
	$UnlockedSprite.visible = false
	$CollisionShape2D.set_deferred("disabled",true)

func unlock():
	print("Unlock function called")
	$LockedSprite.visible = false
	$UnlockedSprite.visible = true
	$CollisionShape2D.set_deferred("disabled",false)  

func _on_body_entered(body):
	print("Body entered the lock area, body name: ", body.name)
	if body.is_in_group("player"):
		print("End game should be triggered now")
		end_game()

func end_game():
	get_tree().change_scene_to_file("res://menu.tscn")
