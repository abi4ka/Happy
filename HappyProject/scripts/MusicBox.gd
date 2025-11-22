extends Node

@onready var player = $Player

var playlist: Array[AudioStream] = [
	preload("res://audio/track1.mp3"),
	preload("res://audio/track2.mp3")
]

var current_index := 0

func _ready():
	_play_current()
	player.connect("finished", Callable(self, "_on_track_finished"))

func _play_current():
	player.stream = playlist[current_index]
	player.play()

func _on_track_finished():
	current_index = (current_index + 1) % playlist.size()
	_play_current()
