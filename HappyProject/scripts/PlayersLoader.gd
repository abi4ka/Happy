extends Node

const PLAYERS_PATH := "user://players"

func load_all_players() -> Array:
	var list := []

	DirAccess.make_dir_recursive_absolute(PLAYERS_PATH)
	var dir = DirAccess.open(PLAYERS_PATH)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with(".json"):
				var path = PLAYERS_PATH + "/" + file_name
				var data = load_player(path)
				if data != null:
					list.append(data)
			file_name = dir.get_next()

	return list


func load_player(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return null

	var txt = file.get_as_text()
	var parsed = JSON.parse_string(txt)

	if parsed is Dictionary:
		return parsed

	return null
