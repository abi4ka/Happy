extends CharacterBody2D

@export var speed := 120.0
@export var gravity := 900.0

@export var zones: Array[Area2D]

var doors := [
	false, 
	true, 
	true,  
	false  
]

var current_room := 0
var player_rooms: Array = []
var target: Node2D = null

var state := "idle"
var wander_direction := 0
var wander_timer := 0.0

func _ready():
	for i in range(zones.size()):
		var zone = zones[i]
		zone.body_entered.connect(_on_zone_enter.bind(i))
		zone.body_exited.connect(_on_zone_exit.bind(i))

func _physics_process(delta):
	velocity.y += gravity * delta
	update_enemy_room()

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

func update_enemy_room():
	for i in range(zones.size()):
		if zones[i].overlaps_body(self):
			current_room = i
			return

func _on_zone_enter(body, room_index: int):
	if not body.is_in_group("player"):
		return

	if not player_rooms.has(room_index):
		player_rooms.append(room_index)

	_check_for_chase()

func _on_zone_exit(body, room_index: int):
	if not body.is_in_group("player"):
		return
	player_rooms.erase(room_index)
	_check_for_chase()

func _can_reach_room(room_index: int) -> bool:
	if room_index == current_room:
		return true

	var step = 1 if room_index > current_room else -1
	var i = current_room

	while i != room_index:
		var door_index = i if step == 1 else i - 1

		if door_index >= 0 and door_index < doors.size():
			if not doors[door_index]:  # дверь закрыта
				return false

		i += step

	return true


func _check_for_chase():
	target = null
	for pr in player_rooms:
		if _can_reach_room(pr):
			target = _get_player_in_room(pr)
			if target != null:
				state = "chase"
				return
	if state == "chase":
		state = "idle"

func _get_player_in_room(room_index: int) -> Node2D:
	for body in zones[room_index].get_overlapping_bodies():
		if body.is_in_group("player"):
			return body
	return null

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

func open_doors(indices: Array) -> void:
	if indices == null:
		return
	for raw in indices:
		var idx = int(raw)
		if idx >= 0 and idx < doors.size():
			doors[idx] = true
	_check_for_chase()

func close_doors(indices: Array) -> void:
	if indices == null:
		return
	for raw in indices:
		var idx = int(raw)
		if idx >= 0 and idx < doors.size():
			doors[idx] = false
	_check_for_chase()
