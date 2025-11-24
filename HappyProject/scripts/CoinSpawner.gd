extends Node

@export var coins: Array[Node]
@export var count_to_show: int = 3

var _pending_result: Array = []


func _ready() -> void:
	ServerSync.request_coin_positions(coins.size(), count_to_show)

	ServerSync.connect("coinpos_received", _on_coinpos_received)
	ServerSync.connect("coinpos_failed", _on_coinpos_failed)

func _on_coinpos_received(result_array: Array) -> void:
	print("[COINSPAWNER] Server result:", result_array)
	_apply_server_result(result_array)


func _on_coinpos_failed() -> void:
	print("[COINSPAWNER] Server failed, showing fallback")
	_apply_fallback()

func _apply_server_result(arr: Array) -> void:
	_disable_all_coins()

	for num in arr:
		var index : int = num - 1
		if index >= 0 and index < coins.size():
			coins[index].visible = true


func _apply_fallback() -> void:
	_disable_all_coins()

	var max_show = min(count_to_show, coins.size())
	for i in range(max_show):
		coins[i].visible = true


func _disable_all_coins():
	for c in coins:
		c.visible = false
