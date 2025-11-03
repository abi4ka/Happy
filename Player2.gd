extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = 400.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction: float = 0.0
	if Input.is_action_pressed("move_left_p2"):
		direction -= 1.0
	if Input.is_action_pressed("move_right_p2"):
		direction += 1.0

	velocity.x = direction * speed

	# Прыжок
	if Input.is_action_just_pressed("jump_p2") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

	# ---- Анимация ----
	if not is_on_floor():
		anim.play("jump")
	elif direction != 0:
		anim.play("run")
		anim.flip_h = direction < 0
	else:
		anim.play("idle")
