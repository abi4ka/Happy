extends Node2D

signal pressed
signal released

@onready var area = $Area2D
@onready var sprite = $Sprite2D

var pressed_down := false
var players_in_range: Array = []
var target_y := 0.0
var move_speed := 10.0

func _ready():
	target_y = sprite.position.y
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		players_in_range.append(body)

func _on_body_exited(body):
	if body.is_in_group("player"):
		players_in_range.erase(body)
		if pressed_down and players_in_range.is_empty():
			_release_button()

func _process(delta):
	sprite.position.y = lerp(sprite.position.y, target_y, delta * move_speed)

	for player in players_in_range:
		if player.has_method("just_pressed_button") and player.just_pressed_button():
			if not pressed_down:
				_press_button()
			return
	if pressed_down and players_in_range.is_empty():
		_release_button()

func _press_button():
	pressed_down = true
	target_y += 2
	emit_signal("pressed")

func _release_button():
	pressed_down = false
	target_y -= 2
	emit_signal("released")
