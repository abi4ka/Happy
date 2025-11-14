extends Control

@onready var main_panel     = $MainPanel
@onready var levels_panel   = $LevelsPanel
@onready var stats_panel    = $StatsPanel
@onready var settings_panel = $SettingsPanel
@onready var name_label     = $UserNamePanel/UserNameLabel

@onready var name_input = $SettingsPanel/VBoxContainer/HBoxContainer/NameInput
# Сюда добавляй все панели, которые должны переключаться кнопками
var toggle_panels: Array[Control]

func _ready():
	# Инициализация списка переключаемых панелей
	toggle_panels = [
		main_panel,
		levels_panel,
		stats_panel,
		settings_panel
	]

	# В начале показываем только главное меню (и скрываем остальные toggle-панели)
	_show_only(main_panel)

	# Подключаем сигналы
	$MainPanel/PlayButton.pressed.connect(_on_play_pressed)
	$MainPanel/StatsButton.pressed.connect(_on_stats_pressed)
	$MainPanel/SettingsButton.pressed.connect(_on_settings_pressed)
	$MainPanel/ExitButton.pressed.connect(_on_exit_pressed)

	$LevelsPanel/Panel/BackButton.pressed.connect(_on_back_pressed)
	$StatsPanel/Panel/BackButton.pressed.connect(_on_back_pressed)
	$SettingsPanel/Panel/BackButton.pressed.connect(_on_back_pressed)
	$SettingsPanel/VBoxContainer/HBoxContainer/Apply.pressed.connect(_on_apply_name_pressed)

	# Отображаем имя (или id) пользователя
	name_label.text = PlayerData.player_name  # или PlayerData.player_id если надо id

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Esc по умолчанию
		_show_only(main_panel)

# Скрываем все панели из toggle_panels кроме переданной
func _show_only(panel: Control) -> void:
	for p in toggle_panels:
		p.visible = (p == panel)

# Обработчики кнопок
func _on_play_pressed():
	_show_only(levels_panel)

func _on_stats_pressed():
	_show_only(stats_panel)

func _on_settings_pressed():
	_show_only(settings_panel)

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	_show_only(main_panel)

func _on_apply_name_pressed():
	var new_name = name_input.text.strip_edges()

	if new_name.is_empty():
		print("Имя пустое! Не меняем.")
		return

	PlayerData.player_name = new_name
	PlayerData.save_data()

	name_label.text = new_name

	print("Имя успешно изменено на:", new_name)
