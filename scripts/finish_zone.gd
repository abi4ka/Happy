extends Area2D

@onready var timer: Timer = $Timer
@onready var countdown_label: Label = $CountdownLabel

var players_inside := {}
var countdown_time := 5.0 
var counting := false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	timer.connect("timeout", _on_timer_timeout)

	countdown_label.visible = false
	countdown_label.text = ""


func _process(delta):
	# Отсчёт идёт только если два игрока внутри
	if counting:
		countdown_time -= delta
		if countdown_time < 0:
			countdown_time = 0
			counting = false

		_update_label()

		if countdown_time <= 0 and timer.is_stopped():
			finish_level()


func _on_body_entered(body):
	if body.is_in_group("player"):
		players_inside[body.get_instance_id()] = true
		_check_players()


func _on_body_exited(body):
	if body.is_in_group("player"):
		players_inside.erase(body.get_instance_id())
		_check_players()


func _check_players():
	var count = players_inside.size()

	if count == 1:
		# Один игрок — показываем 5.00, но не запускаем таймер
		countdown_label.visible = true
		countdown_time = 5.0
		_update_label()
		counting = false
		timer.stop()

	elif count >= 2:
		# Два игрока — запускаем реальный отсчёт
		if not counting:
			_start_countdown()

	else:
		# Никого нет — скрываем
		_reset_countdown()


func _start_countdown():
	countdown_time = 5.0
	counting = true
	countdown_label.visible = true
	timer.start(5.0)
	print("Countdown started")


func _reset_countdown():
	counting = false
	countdown_label.visible = false
	countdown_label.text = ""
	timer.stop()
	print("Countdown reset")


func _update_label():
	var seconds = int(countdown_time)
	var centiseconds = int((countdown_time - seconds) * 100)  # 00–99
	countdown_label.text = "%02d:%02d" % [seconds, centiseconds]


func _on_timer_timeout():
	finish_level()


func finish_level():
	counting = false
	countdown_label.visible = false
	print("Level completed!")
