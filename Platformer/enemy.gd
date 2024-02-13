extends CharacterBody2D

# Variables
var direction = Vector2.RIGHT
var sprite
var ledge_check_right
var ledge_check_left

# Initialization
func _ready():
	sprite = $AnimatedSprite2D
	ledge_check_right = $LedgeCheckRight
	ledge_check_left = $LedgeCheckLeft

# Physics Process
func _physics_process(_delta):
	var found_wall = is_on_wall()
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()

	if found_wall or found_ledge:
		direction *= -1
		sprite.play("Walking")

	# Update velocity based on direction
	velocity = direction * 20

	# Use move_and_slide() with updated velocity
	# Note: move_and_slide() in Godot 4 automatically modifies the velocity property
	move_and_slide()

	# Flip sprite based on direction
	sprite.flip_h = (direction.x > 0)
