extends CharacterBody2D

@export var speed: float = 75.0
@export var jump_force: float = 250.0
@export var move_left_action: String
@export var move_right_action: String
@export var jump_action: String

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var collected_items: int = 0

@onready var anim = $AnimatedSprite2D

func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction: float = 0.0
	if Input.is_action_pressed(move_left_action):
		direction -= 1.0
	if Input.is_action_pressed(move_right_action):
		direction += 1.0

	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

	# ---- Animation ----
	if direction != 0:
		anim.play("run")
		anim.flip_h = direction < 0
	else:
		anim.play("idle")
