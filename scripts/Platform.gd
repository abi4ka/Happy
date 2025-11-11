extends Node2D

var start_y
@export var move_distance := 64.0
@export var move_speed := 3.0
var target_y

func _ready():
	start_y = position.y
	target_y = start_y

func lower():
	target_y = start_y + move_distance

func raise():
	target_y = start_y

func _process(delta):
	position.y = lerp(position.y, target_y, delta * move_speed)
