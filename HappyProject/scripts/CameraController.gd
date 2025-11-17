extends Camera2D

@export var player1: Node2D
@export var player2: Node2D

# --- Настройки движения камеры ---
@export var follow_speed: float = 5.0

# --- Настройки авто-зумирования ---
@export var auto_min_zoom: float = 0.8
@export var auto_max_zoom: float = 1.8
@export var zoom_distance: float = 600.0

# --- Настройки ручного зума ---
@export var manual_min_zoom: float = 0.5
@export var manual_max_zoom: float = 2.5
@export var zoom_step: float = 0.1
@export var zoom_reset_delay: float = 2.5

# --- Сдвиг по вертикали (в пикселях, положительное значение — камера выше, отрицательное — ниже) ---
@export var vertical_offset: float = 100.0

# --- Внутренние переменные ---
var target_zoom: float = 1.0
var zoom_timer: float = 0.0
var manual_zoom_active: bool = false


func _ready() -> void:
	if not player1 or not player2:
		return
	
	# Инициализация позиции и зума
	var mid_point = (player1.global_position + player2.global_position) * 0.5
	mid_point.y -= vertical_offset
	global_position = mid_point

	var distance = player1.global_position.distance_to(player2.global_position)
	var start_zoom = lerp(auto_min_zoom, auto_max_zoom, clamp(distance / zoom_distance, 0.0, 1.0))
	target_zoom = start_zoom
	zoom = Vector2(start_zoom, start_zoom)


func _process(delta: float) -> void:
	if not player1 or not player2:
		return

	# Центр между игроками + вертикальный сдвиг
	var mid_point = (player1.global_position + player2.global_position) * 0.5
	mid_point.y -= vertical_offset
	global_position = global_position.lerp(mid_point, delta * follow_speed)

	handle_scroll(delta)

	if not manual_zoom_active:
		var distance = player1.global_position.distance_to(player2.global_position)
		var auto_zoom = lerp(auto_min_zoom, auto_max_zoom, clamp(distance / zoom_distance, 0.0, 1.0))
		target_zoom = lerp(target_zoom, auto_zoom, delta * 2.0)
	else:
		zoom_timer -= delta
		if zoom_timer <= 0:
			manual_zoom_active = false

	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), delta * 5.0)


func handle_scroll(delta: float) -> void:
	var changed := false

	if Input.is_action_just_pressed("zoom_in"):
		target_zoom -= zoom_step
		changed = true
	elif Input.is_action_just_pressed("zoom_out"):
		target_zoom += zoom_step
		changed = true

	if changed:
		target_zoom = clamp(target_zoom, manual_min_zoom, manual_max_zoom)
		manual_zoom_active = true
		zoom_timer = zoom_reset_delay
