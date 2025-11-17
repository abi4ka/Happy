extends Area2D

signal collected

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("default"):
		anim.play("default")

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("collected", body)
		queue_free()
