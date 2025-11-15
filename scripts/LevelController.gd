extends Area2D

# ---------------------- НАСТРОЙКИ ----------------------
@export var level_id: int = 1
@export var countdown_duration: float = 5.0

@onready var timer: Timer = $Timer
@onready var countdown_label: Label = $CountdownLabel
@export var level_timer_label: Label

# ---------------------- ДАННЫЕ УРОВНЯ -------------------
var total_collected := 0
var players_inside := {}

var countdown_time := 0.0
var counting := false

var elapsed_time: float = 0.0   # <<<<<< ОБЪЕДИНЕННЫЙ ТАЙМЕР УРОВНЯ


# ========================================================
#                      READY
# ========================================================
func _ready():
	connect("body_entered", _on_body_enter)
	connect("body_exited", _on_body_exit)
	timer.connect("timeout", _on_timer_timeout)

	countdown_label.visible = false

	_register_collectibles()

	PlayerData.add_attempt(level_id)


func _register_collectibles():
	for collectible in get_tree().get_nodes_in_group("collectible"):
		collectible.connect("collected", Callable(self, "_on_collectible_collected"))

# ========================================================
#                   ТАЙМЕР УРОВНЯ
# ========================================================
func _process(delta):
	# •• время уровня
	elapsed_time += delta
	level_timer_label.text = format_time(elapsed_time)

	# •• таймер финишной зоны
	if counting:
		countdown_time -= delta

		if countdown_time < 0:
			countdown_time = 0
			counting = false

		_update_label()

		if countdown_time <= 0 and timer.is_stopped():
			finish_level()


func get_elapsed_time() -> float:
	return elapsed_time


func format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	var centi = int((t - int(t)) * 100)
	return "%02d:%02d:%02d" % [minutes, seconds, centi]


# ========================================================
#                 СБОР МОНЕТ
# ========================================================
func _on_collectible_collected(body):
	total_collected += 1
	print("Collected:", total_collected)


# ========================================================
#                   ФИНИШНАЯ ЗОНА
# ========================================================
func _on_body_enter(body):
	if body.is_in_group("player"):
		players_inside[body.get_instance_id()] = true
		_check_players()


func _on_body_exit(body):
	if body.is_in_group("player"):
		players_inside.erase(body.get_instance_id())
		_check_players()


func _check_players():
	var count = players_inside.size()

	if count == 1:
		_show_static_5_seconds()

	elif count >= 2:
		if not counting:
			_start_countdown()

	else:
		_reset_countdown()


# ========================================================
#                   ОТСЧЁТ ВРЕМЕНИ
# ========================================================
func _start_countdown():
	countdown_time = countdown_duration
	counting = true
	countdown_label.visible = true
	timer.start(countdown_duration)
	print("Countdown started")


func _show_static_5_seconds():
	countdown_label.visible = true
	countdown_time = countdown_duration
	counting = false
	timer.stop()
	_update_label()


func _reset_countdown():
	counting = false
	countdown_label.visible = false
	countdown_label.text = ""
	timer.stop()
	print("Countdown reset")


func _update_label():
	var seconds = int(countdown_time)
	var centiseconds = int((countdown_time - seconds) * 100)
	countdown_label.text = "%02d:%02d" % [seconds, centiseconds]


func _on_timer_timeout():
	finish_level()


# ========================================================
#                  ФИНАЛИЗАЦИЯ УРОВНЯ
# ========================================================
func finish_level():
	counting = false
	countdown_label.visible = false

	var time_passed = get_elapsed_time()

	# Достаём сохранённые данные
	var saved_data = PlayerData._get_level(level_id)

	# Если уровня ещё нет в сохранении — регистрируем
	if saved_data == null:
		PlayerData.register_level(level_id)
		saved_data = PlayerData._get_level(level_id)

	var saved_coins = saved_data.coins
	var saved_time = saved_data.best_time

	# Выводим текущие результаты
	print("==================== LEVEL FINISHED ====================")
	print(" Level:", level_id)
	print(" Current coins:", total_collected)
	print(" Current time:", format_time(time_passed))

	# Выводим результаты из сохранения
	print(" Saved coins:", saved_coins)
	print(" Saved best time:", "NONE" if saved_time == null else format_time(saved_time))

	# ЛОГИКА СОХРАНЕНИЯ
	if total_collected > saved_coins:
		print(" → NEW RECORD: more coins, saving.")
		PlayerData.update_level_result(level_id, total_collected, time_passed)

	elif total_collected == saved_coins:
		if saved_time == null or time_passed < saved_time:
			print(" → NEW RECORD: better time, saving.")
			PlayerData.update_level_result(level_id, total_collected, time_passed)
		else:
			print(" → NO UPDATE: same coins, worse time.")

	else:
		print(" → NO UPDATE: fewer coins.")

	print("==========================================================")
