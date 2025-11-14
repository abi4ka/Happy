extends Node2D

@export var move_distance := 64.0
@export var move_speed := 3.0
@export var horizontal_move := true

var start_pos: Vector2
var target_pos: Vector2
var direction: Vector2 = Vector2.ZERO

var hold_count: int = 0

func _ready():
	start_pos = position
	target_pos = start_pos

func button_pressed():
	hold_count += 1
	update_target()

func button_released():
	hold_count = max(hold_count - 1, 0)
	update_target()

func update_target():
	if hold_count > 0:
		lower()
	else:
		raise()

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
