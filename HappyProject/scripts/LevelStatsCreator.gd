extends Control

@export var level_id := 1
@export var entry_prefab: PackedScene
@export var list_container: VBoxContainer

func _ready():
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
					"coins": lvl.get("coins", 0),
					"best_time": lvl.get("best_time", 9999999)
				})

	level_stats.sort_custom(Callable(self, "_cmp_by_time"))

	var rank := 1
	for s in level_stats:
		var entry = entry_prefab.instantiate()
		entry.set_data(rank, s.name, s.coins, s.best_time)
		list_container.add_child(entry)
		rank += 1


func _cmp_by_time(a: Dictionary, b: Dictionary) -> int:
	var at = a.get("best_time", null)
	var bt = b.get("best_time", null)

	if at == null and bt == null:
		return 0
	if at == null:
		return 1
	if bt == null:
		return -1

	if at < bt:
		return -1
	elif at > bt:
		return 1
	return 0
