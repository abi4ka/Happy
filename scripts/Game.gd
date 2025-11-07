extends Node2D

var total_collected: int = 0

func _ready():
	# Подписываемся на все предметы на сцене
	for collectible in get_tree().get_nodes_in_group("collectibles"):
		collectible.connect("collected", Callable(self, "_on_collectible_collected"))

func _on_collectible_collected(body):
	total_collected += 1
	print("Total collected:", total_collected)
	print("Player ", body.name, "collected item!")
