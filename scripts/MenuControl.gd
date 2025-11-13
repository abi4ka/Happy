extends Control

@onready var main_panel = $MainPanel
@onready var levels_panel = $LevelsPanel
@onready var stats_panel = $StatsPanel
@onready var settings_panel = $SettingsPanel

func _ready():
	# В начале показываем только главное меню
	_show_only(main_panel)
	
	# Подключаем сигналы
	$MainPanel/PlayButton.pressed.connect(_on_play_pressed)
	$MainPanel/StatsButton.pressed.connect(_on_stats_pressed)
	$MainPanel/SettingsButton.pressed.connect(_on_settings_pressed)
	$MainPanel/ExitButton.pressed.connect(_on_exit_pressed)

	$LevelsPanel/Panel/BackButton.pressed.connect(_on_back_pressed)
	$StatsPanel/Panel/BackButton.pressed.connect(_on_back_pressed)
	$SettingsPanel/Panel/BackButton.pressed.connect(_on_back_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Esc по умолчанию
		_show_only(main_panel)

func _show_only(panel: Control):
	for child in get_children():
		if child is Control and child != panel and not child.name.ends_with("Label"):
			child.visible = false
	panel.visible = true

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
