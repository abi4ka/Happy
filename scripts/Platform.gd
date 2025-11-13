extends Node2D

@export var move_distance := 64.0
@export var move_speed := 3.0
@export var horizontal_move := true

var start_pos: Vector2
var target_pos: Vector2
var direction: Vector2 = Vector2.ZERO

func _ready():
	start_pos = position
	target_pos = start_pos

func lower():
	if horizontal_move:
		target_pos = start_pos + Vector2(move_distance, 0)
	else:
		target_pos = start_pos + Vector2(0, move_distance)
	direction = (target_pos - position).normalized()

func raise():
	target_pos = start_pos
	direction = (target_pos - position).normalized()

func _process(delta):
	if position.distance_to(target_pos) > move_speed * delta:
		position += direction * move_speed * delta
	else:
		position = target_pos
