extends Node2D

signal pressed
signal released

@onready var area = $Area2D
@onready var sprite = $Sprite2D

var pressed_down = false

func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("player") and not pressed_down:
		pressed_down = true
		sprite.position.y += 2
		emit_signal("pressed")

func _on_body_exited(body):
	if body.is_in_group("player") and pressed_down:
		pressed_down = false
		sprite.position.y -= 2
		emit_signal("released")
