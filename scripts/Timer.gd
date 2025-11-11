extends Label

@export var timer_node: Timer  # Укажи свой Timer вручную в инспекторе

var elapsed_time: float = 0.0

func _ready():
	if timer_node:
		timer_node.connect("timeout", Callable(self, "_on_timer_timeout"))
	else:
		push_warning("Timer node is not assigned!")

func _on_timer_timeout():
	elapsed_time += timer_node.wait_time
	text = format_time(elapsed_time)

func format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
