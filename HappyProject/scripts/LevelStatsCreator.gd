extends Control

@export var level_id := 1
@export var entry_prefab: PackedScene
@export var list_container: VBoxContainer
@export var sync_button: Button

func _ready():
	sync_button.pressed.connect(_on_sync_pressed)
	update_leaderboard()


func update_leaderboard():
	for child in list_container.get_children():
		child.queue_free()


	var players = PlayersLoader.load_all_players()

	var level_stats = []

	for p in players:
		for lvl in p.get("levels", []):
			if int(lvl["lvl_id"]) == level_id:
				level_stats.append({
					"name": p.get("name", "???"),
					"coins": int(lvl.get("coins", 0)),
					"best_time": lvl.get("best_time", 9999999)
				})
	
	level_stats = _sort_level_stats_by_keys(level_stats)

	var rank := 1
	for s in level_stats:
		var entry = entry_prefab.instantiate()
		entry.set_data(rank, s.name, s.coins, s.best_time)
		list_container.add_child(entry)
		rank += 1

func _sort_level_stats_by_keys(arr: Array) -> Array:
	var tuples := []
	for item in arr:
		var coins := -int(item.get("coins", 0))
		var time := float(item.get("best_time", 9999999.0))
		tuples.append([coins, time, item])
	tuples.sort()
	var out := []
	for t in tuples:
		out.append(t[2])
	return out


func _on_sync_pressed():
	PlayersLoader.send_player_to_server()
	PlayersLoader.fetch_all_players_from_server(self, "_on_players_fetched")

func _on_players_fetched():
	update_leaderboard()
