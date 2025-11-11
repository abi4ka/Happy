extends CharacterBody2D

@export var speed: float = 75.0
@export var jump_force: float = 250.0
@export var move_left_action: String
@export var move_right_action: String
@export var jump_action: String
@export var interact_action: String

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = $AnimatedSprite2D

var just_pressed_interact := false
var interact_cooldown := 0.3
var interact_timer := 0.0
var is_pushing := false

func _ready():
	add_to_group("player")
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if is_pushing:
		velocity.x = 0
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := 0.0
	if Input.is_action_pressed(move_left_action):
		direction -= 1.0
	if Input.is_action_pressed(move_right_action):
		direction += 1.0
	velocity.x = direction * speed

	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

	just_pressed_interact = false
	if interact_timer > 0.0:
		interact_timer -= delta
	elif Input.is_action_just_pressed(interact_action):
		just_pressed_interact = true
		interact_timer = interact_cooldown

	if just_pressed_interact:
		anim.play("push")
		is_pushing = true
	elif direction != 0:
		anim.play("run")
		anim.flip_h = direction < 0
	else:
		anim.play("idle")

func _on_animation_finished():
	if anim.animation == "push":
		is_pushing = false
		anim.play("idle")

func just_pressed_button() -> bool:
	return just_pressed_interact
