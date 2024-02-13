extends CharacterBody2D

# Define character states
enum {HOVER, FALL, LAND, RISE}

# Variable declarations
var state = RISE
var start_position: Vector2
var rise_speed = 40
var fall_speed = 300
var tremble_magnitude := 0.5  # Magnitude of the trembling effect
var is_trembling := false
var animated_sprite: AnimatedSprite2D
var dust_particles: CPUParticles2D

func _ready():
	# Initialize variables and connect signals
	animated_sprite = $AnimatedSprite2D
	randomize()
	start_position = global_position
	dust_particles = $CPUParticles2D  # Assuming CPUParticles2D is a direct child named CPUParticles2D

	# Setup and connect timers
	get_node("HoverEndTimer").wait_time = 2  # Time to wait before starting the trembling effect
	get_node("HoverEndTimer").one_shot = true
	get_node("HoverEndTimer").connect("timeout", Callable(self, "_on_HoverEndTimer_timeout"))

	get_node("HoverTrembleTimer").wait_time = 0.01  # Timer interval for the trembling effect
	get_node("HoverTrembleTimer").one_shot = false
	get_node("HoverTrembleTimer").connect("timeout", Callable(self, "_on_HoverTrembleTimer_timeout"))

	get_node("StartHoverTimer").wait_time = 5  # Time before starting to hover
	get_node("StartHoverTimer").one_shot = true
	get_node("StartHoverTimer").connect("timeout", Callable(self, "_on_StartHoverTimer_timeout"))

	get_node("LandTimer").wait_time = 2  # Time on ground before rising
	get_node("LandTimer").one_shot = true
	get_node("LandTimer").connect("timeout", Callable(self, "_on_LandTimer_timeout"))

	get_node("RayCast2D").enabled = true

	# Start the hover timer
	get_node("StartHoverTimer").start()

func _physics_process(delta):
	# Handle state changes and animations
	match state:
		HOVER:
			# Ensure RayCast2D is enabled for other states
			get_node("RayCast2D").enabled = true
		FALL:
			# Play falling animation and apply movement
			animated_sprite.play("Falling")
			global_position.x = start_position.x
			global_position.y += fall_speed * delta
			# Ensure RayCast2D is enabled to detect collision
			get_node("RayCast2D").enabled = true
			# Check for collision to switch to LAND state
			if get_node("RayCast2D").is_colliding():
				state = LAND
				get_node("LandTimer").start()
				emit_dust_effect()  # Emit dust effect when hitting the ground
		LAND:
			# Ensure RayCast2D is enabled for other states
			get_node("RayCast2D").enabled = true
		RISE:
			# Play rising animation and move up
			animated_sprite.play("Rising")
			global_position.y -= rise_speed * delta
			# Disable RayCast2D when rising
			get_node("RayCast2D").enabled = false
			# Reset to HOVER state upon reaching the start position
			if global_position.y <= start_position.y:
				global_position.y = start_position.y
				state = HOVER
				get_node("HoverEndTimer").start()


func _on_HoverEndTimer_timeout():
	# Start trembling and wait for a timeout before falling
	is_trembling = true
	get_node("HoverTrembleTimer").start()

	# Lisää satunnainen viive ennen putoamista
	var random_fall_delay = randf() * 1.5 + 0.5  # 0.5 - 2.0 sekuntia satunnainen viive
	await get_tree().create_timer(random_fall_delay).timeout

	is_trembling = false
	get_node("HoverTrembleTimer").stop()
	state = FALL


func _on_HoverTrembleTimer_timeout():
	# Apply trembling effect if character is trembling
	if is_trembling:
		apply_tremble()

func apply_tremble():
	# Calculate and apply trembling effect
	var tremble_x = (randf() * 2 - 1) * tremble_magnitude
	var tremble_y = (randf() * 2 - 1) * tremble_magnitude
	global_position.x = clamp(global_position.x + tremble_x, start_position.x - tremble_magnitude, start_position.x + tremble_magnitude)
	global_position.y = clamp(global_position.y + tremble_y, start_position.y - tremble_magnitude, start_position.y + tremble_magnitude)

func _on_StartHoverTimer_timeout():
	# Change state to HOVER
	state = HOVER

func _on_LandTimer_timeout():
	# Change state to RISE
	state = RISE

func emit_dust_effect():
	# Emit dust particles effect
	dust_particles.restart()
