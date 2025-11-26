extends CharacterBody2D

@export var jump_force: float = 250.0
@export var move_left_action: String
@export var move_right_action: String
@export var jump_action: String
@export var interact_action: String

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = $AnimatedSprite2D
@onready var s_walk = $AudioWalk

var walk_sound_delay := 0.5
var walk_sound_timer := 0.0

var just_pressed_interact := false
var interact_cooldown := 0.3
var interact_timer := 0.0
var is_pushing := false

@export var speed := 75.0
var speed_multiplier := 1.0
var animation_speed_multiplier := 1.0

func _ready():
	add_to_group("player")
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func _physics_process(delta: float) -> void:
	if GameState.is_paused:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if is_dying:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
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
	velocity.x = direction * speed * speed_multiplier

	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = -jump_force

		s_walk.pitch_scale = 1.3
		s_walk.play()

	move_and_slide()
	_push_bodies()

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
		
	if direction != 0 and is_on_floor():
		walk_sound_timer -= delta
		if walk_sound_timer <= 0.0:
			s_walk.pitch_scale = randf_range(0.7, 0.9)
			s_walk.play()
			walk_sound_timer = walk_sound_delay
	else:
		walk_sound_timer = 0.0

func _on_animation_finished():
	if anim.animation == "push":
		is_pushing = false
		anim.play("idle")

func just_pressed_button() -> bool:
	return just_pressed_interact
	
func _push_bodies():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var push_dir = collision.get_normal() * -1.0
			push_dir.y = 0
			var force = push_dir * speed / 2
			collider.apply_central_impulse(force)

var is_dying = false

func die():
	if is_dying:
		return
	is_dying = true

	anim.play("die")
	get_tree().create_timer(2.0).timeout.connect(_restart_level)

func _restart_level():
	get_tree().reload_current_scene()

func apply_speed_boost(multiplier: float):
	speed_multiplier = multiplier
	animation_speed_multiplier = multiplier
	walk_sound_delay = 0.25

	anim.speed_scale = animation_speed_multiplier
