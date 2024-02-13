extends AnimatedSprite2D

func _ready():
	# Luo Timer-solmu koodissa
	var timer = Timer.new()
	# Aseta timerin odotusaika 1 sekunniksi
	timer.wait_time = 1
	# Aseta timer toistuvaksi, jos haluat animaation käynnistyvän uudelleen määräajoin
	timer.one_shot = true
	# Lisää timer solmuun
	add_child(timer)
	# Kytke timerin 'timeout' signaali tämän skriptin funktioon, joka käynnistää animaation
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

	# Käynnistä timer
	timer.start()

func _on_Timer_timeout():
	# Käynnistä animaatio, kun timer saavuttaa määräajan
	play()
