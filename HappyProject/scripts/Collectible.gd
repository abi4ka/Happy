extends Area2D

signal collected

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var s_collect = $CollectSound

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("default"):
		anim.play("default")

func _on_body_entered(body):
	if not visible:
		return
	if body.is_in_group("player"):
		s_collect.pitch_scale = randf_range(0.7, 1.2)
		s_collect.play()

		emit_signal("collected", body)

		call_deferred("_after_collect")

func _after_collect():
	visible = false
	$CollisionShape2D.disabled = true

	await get_tree().create_timer(s_collect.stream.get_length()).timeout
	queue_free()
