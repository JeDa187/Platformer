extends CharacterBody2D
class_name Player

enum State { MOVE, CLIMB }
var current_state = State.MOVE

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const MAX_JUMPS = 2
const DOUBLE_JUMP_TIME_LIMIT = 0.2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_count = 0
var time_since_last_ground = 0.0
var start_position: Vector2
var animated_sprite: AnimatedSprite2D
var ladder_check
var has_key = false  # Tämä pitää kirjaa siitä, onko avain kerätty
var lock # Tämä on viittaus lukkoon pelissä

var camera_start_position: Vector2


func _ready():
	camera_start_position = get_viewport().get_camera_2d().global_position
	animated_sprite = $AnimatedSprite2D
	start_position = global_position
	ladder_check = $LadderCheck
	add_to_group("player")
	var key_status = get_node("Camera2D/UI/KeyStatus")
	key_status.text = "Find the key!"
	# Haetaan lukko käyttäen suhteellista polkua.
	lock = get_node_or_null("../Lock")  # Olettaen että pelaaja ja lukko ovat saman 'world'-solmun lapsia.
	var key_silhouette = get_node("Camera2D/UI/KeySilhouette")
	key_silhouette.modulate = Color(0.5, 0.5, 0.5, 1)  # Aseta alustava harmaa väri



func _physics_process(delta):
	match current_state:
		State.MOVE:
			process_movement(delta)
		State.CLIMB:
			process_climbing(delta)

	move_and_slide()

	# Tarkista, onko kamera siirtynyt yli 500 pikseliä alaspäin alkuperäisestä sijainnistaan
	var camera_current_position = get_viewport().get_camera_2d().global_position
	if camera_current_position.y - camera_start_position.y > 250:
		restart_game()

func process_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	update_animation("Run", "Idle", direction != 0)
	process_gravity(delta)
	process_jump(delta)

	if ladder_check.is_colliding() and (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
		current_state = State.CLIMB

func process_climbing(delta):
	velocity.y = Input.get_axis("ui_up", "ui_down") * SPEED
	velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
	update_animation("Climb", "Idle", velocity.y != 0 or velocity.x != 0)

	if not ladder_check.is_colliding():
		current_state = State.MOVE

func update_animation(run_anim: String, idle_anim: String, is_moving: bool):
	if is_moving:
		play_animation(run_anim)
		animated_sprite.flip_h = velocity.x > 0
	else:
		play_animation(idle_anim)

func process_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		set_jump_frame()
		time_since_last_ground += delta
	else:
		reset_jump_state()

func process_jump(delta):
	if can_jump():
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		set_jump_frame()
		time_since_last_ground = 0

func can_jump():
	return Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS and (jump_count == 0 or time_since_last_ground <= DOUBLE_JUMP_TIME_LIMIT)

func reset_jump_state():
	jump_count = 0
	time_since_last_ground = 0

func play_animation(animation_name: String):
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func set_jump_frame():
	if not is_on_floor():
		animated_sprite.play("Run")
		animated_sprite.frame = 0
		animated_sprite.stop()

func restart_game():
	get_tree().reload_current_scene()


func pick_up_key():
	has_key = true
	var key_silhouette = get_node("Camera2D/UI/KeySilhouette")
	var key_filled = get_node("Camera2D/UI/KeyFilled")
	var key_status = get_node("Camera2D/UI/KeyStatus")

	if key_silhouette and key_filled:
		key_silhouette.modulate = Color(1, 1, 1, 1)  # Palautetaan alkuperäinen väri
		key_filled.visible = true
		key_silhouette.visible = false

	if key_status:
		key_status.text = "You have found the key!"  # Päivitä teksti

	if lock:
		lock.unlock()

