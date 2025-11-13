extends Node

const SAVE_PATH := "user://player_data.json"

var player_id: String = ""
var player_name: String = ""

func _ready():
	load_data()
	
# ------ Сохранение ------
func save_data():
	var data = {
		"id": player_id,
		"name": player_name
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

# ------ Загрузка ------
func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var text = file.get_as_text()
		file.close()

		var result = JSON.parse_string(text)
		if result is Dictionary:
			player_id = result.get("id", "")
			player_name = result.get("name", "")
	else:
		_create_new_user()

# ------ Создаём нового игрока ------
func _create_new_user():
	player_id = _generate_id()
	player_name = "Player"  # можешь поставить окно ввода имени

	save_data()

# ------ Генерация ID ------
func _generate_id(length := 8) -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var out = ""
	var rng = RandomNumberGenerator.new()

	for i in length:
		out += chars[rng.randi_range(0, chars.length() - 1)]
	return out
