extends CharacterBody2D

# Tärinäefektin asetukset
var tremble_magnitude := 0.3  # Tärinäefektin voimakkuus
var is_trembling := false  # Tärinä alkaa pois päältä
var original_position := Vector2()
var tremble_timer := Timer.new()  # Ajastin tärinän käyttöön
var stop_tremble_timer := Timer.new()  # Ajastin tärinän pysäyttämiseen
var animated_sprite: AnimatedSprite2D

func _ready():
	original_position = global_position  # Tallennetaan alkuperäinen positio
	animated_sprite = $AnimatedSprite2D  # Oletetaan, että AnimatedSprite2D on lapsisolmu
	setup_timers()

func setup_timers():
	# Asetetaan ajastin tärinän käynnistämiseen
	tremble_timer.wait_time = 2
	tremble_timer.one_shot = true
	add_child(tremble_timer)
	tremble_timer.connect("timeout", Callable(self, "start_tremble"))

	# Asetetaan ajastin tärinän pysäyttämiseen
	stop_tremble_timer.wait_time = 2
	stop_tremble_timer.one_shot = true
	add_child(stop_tremble_timer)
	stop_tremble_timer.connect("timeout", Callable(self, "stop_tremble"))

	# Käynnistetään ensimmäinen ajastin odottamaan tärinän aloittamista
	tremble_timer.start()

func start_tremble():
	is_trembling = true
	animated_sprite.play("Falling")  # Vaihda animaatio tärinän ajaksi
	stop_tremble_timer.start()

func stop_tremble():
	is_trembling = false
	animated_sprite.play("Rising")  # Palauta alkuperäinen animaatio, kun tärinä päättyy
	tremble_timer.start()

func _on_TrembleTimer_timeout():
	pass

func _process(delta):
	if is_trembling:
		apply_tremble()
	else:
		# Palauta alkuperäinen positio, kun tärinä ei ole käynnissä
		global_position = original_position

func apply_tremble():
	var tremble_x = (randf() * 2 - 1) * tremble_magnitude
	var tremble_y = (randf() * 2 - 1) * tremble_magnitude
	global_position = original_position + Vector2(tremble_x, tremble_y)
