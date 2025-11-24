extends Node2D

@export var move_distance := 64.0
@export var move_speed := 3.0
@export var horizontal_move := true
@export var auto_move := false

@export var block := false

var start_pos: Vector2
var end_pos: Vector2
var target_pos: Vector2
var direction: Vector2 = Vector2.ZERO

var hold_count: int = 0

func _ready():
	start_pos = position

	if horizontal_move:
		end_pos = start_pos + Vector2(move_distance, 0)
	else:
		end_pos = start_pos + Vector2(0, move_distance)

	target_pos = start_pos


func button_pressed():
	if auto_move or block:
		return
	hold_count += 1
	update_target()


func button_released():
	if auto_move or block:
		return
	hold_count = max(hold_count - 1, 0)
	update_target()


func update_target():
	if block:
		return

	if hold_count > 0:
		target_pos = end_pos
	else:
		target_pos = start_pos

	direction = (target_pos - position).normalized()


func _process(delta):
	if auto_move:
		_auto_move(delta)
	else:
		_manual_move(delta)


func _manual_move(delta):
	if position.distance_to(target_pos) > move_speed * delta:
		position += direction * move_speed * delta
	else:
		position = target_pos


func _auto_move(delta):
	var dir_to_target = (target_pos - position).normalized()

	if position.distance_to(target_pos) > move_speed * delta:
		position += dir_to_target * move_speed * delta
	else:
		if target_pos == start_pos:
			target_pos = end_pos
		else:
			target_pos = start_pos

func force_open():
	block = true
	target_pos = end_pos
	direction = (target_pos - position).normalized()
	
func force_close():
	block = true
	target_pos = start_pos
	direction = (target_pos - position).normalized()
