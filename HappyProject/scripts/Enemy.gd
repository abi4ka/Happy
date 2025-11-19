extends CharacterBody2D

@export var aggro_area: Area2D
@export var speed := 120.0
@export var gravity := 900.0

var target: Node2D = null
var aggro_list: Array = []
var state := "idle"
var wander_direction := 0
var wander_timer := 0.0

func _ready():
	aggro_area.body_entered.connect(_on_aggro_enter)
	aggro_area.body_exited.connect(_on_aggro_exit)


func _physics_process(delta):
	velocity.y += gravity * delta

	match state:
		"idle":
			_play_anim("idle")
			velocity.x = 0
			wander_timer -= delta
			if wander_timer <= 0:
				_start_wander()

		"wander":
			_play_anim("run")
			velocity.x = wander_direction * (speed * 0.5)
			_update_facing(velocity.x)
			wander_timer -= delta
			if wander_timer <= 0:
				state = "idle"
				wander_timer = randf_range(2.0, 4.0)

		"chase":
			_chase_target()

		"attack":
			velocity.x = 0
			_play_anim("attack")

	move_and_slide()

func _on_aggro_enter(body):
	if body.is_in_group("player"):
		aggro_list.append(body)
		if target == null:
			target = body
			state = "chase"


func _on_aggro_exit(body):
	if body.is_in_group("player"):
		aggro_list.erase(body)
		if body == target:
			target = null
			if aggro_list.size() > 0:
				target = aggro_list[0]
			else:
				state = "idle"
				wander_timer = randf_range(2.0, 4.0)

func _chase_target():
	if target == null:
		state = "idle"
		return

	if global_position.distance_to(target.global_position) < 20:
		state = "attack"
		return

	_play_anim("run")

	var direction_x = sign(target.global_position.x - global_position.x)
	velocity.x = direction_x * speed

	_update_facing(velocity.x)

func _start_wander():
	state = "wander"
	wander_direction = -1 if randf() < 0.5 else 1
	wander_timer = randf_range(1.5, 3.0)


func _update_facing(x_vel: float):
	if x_vel == 0:
		return
	$AnimatedSprite2D.flip_h = x_vel < 0

func _play_anim(name: String):
	if $AnimatedSprite2D.animation != name:
		$AnimatedSprite2D.play(name)
