extends Node2D

@export var move_distance := 64.0
@export var move_speed := 3.0
@export var horizontal_move := true

var start_pos: Vector2
var target_pos: Vector2

func _ready():
	start_pos = position
	target_pos = start_pos

func lower():
	if horizontal_move:
		target_pos.x = start_pos.x + move_distance
	else:
		target_pos.y = start_pos.y + move_distance

func raise():
	target_pos = start_pos

func _process(delta):
	position = position.lerp(target_pos, delta * move_speed)
