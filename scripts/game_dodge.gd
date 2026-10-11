extends Node2D

signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var player: ColorRect = $Player

var screen_width: float = 1152.0
var screen_height: float = 648.0

var player_speed: float = 400.0 
var obstacle_speed: float = 350.0
var game_ended: bool = false

var obstacles_array: Array[ColorRect] = []
var num_obstacles: int = 50

func _ready() -> void:
	timer.wait_time = 3.5
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	
	spawn_obstacles()

func spawn_obstacles() -> void:
	var obstacle_size: Vector2 = Vector2(50, 50)
	
	var safe_border_margin: float = 120.0 
	
	for i in range(num_obstacles):
		var new_obstacle: ColorRect = ColorRect.new()
		new_obstacle.size = obstacle_size
		new_obstacle.color = Color("red")
		
		var spawn_x: float = 0.0
		
		if i == 0:
			spawn_x = player.position.x + (player.size.x / 2.0) - (obstacle_size.x / 2.0)
		else:
			var min_x: float = safe_border_margin
			var max_x: float = screen_width - obstacle_size.x - safe_border_margin
			spawn_x = randf_range(min_x, max_x)
		
		var distributed_y: float = -obstacle_size.y - (i * 140.0) - randf_range(0, 30)
		
		new_obstacle.position = Vector2(spawn_x, distributed_y)
		
		add_child(new_obstacle)
		obstacles_array.append(new_obstacle)

func _process(delta: float) -> void:
	if game_ended: return
	
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		player.position.x -= player_speed * delta
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		player.position.x += player_speed * delta
		
	var max_player_x: float = screen_width - player.size.x
	player.position.x = clamp(player.position.x, 0.0, max_player_x)
		
	for obs in obstacles_array:
		if is_instance_valid(obs):
			obs.position.y += obstacle_speed * delta
			
			if player.get_global_rect().intersects(obs.get_global_rect()):
				end_game(false)
				return

func _on_timer_timeout() -> void:
	end_game(true)

func end_game(won: bool) -> void:
	if game_ended: return
	game_ended = true
	
	set_process(false)
	timer.stop()
	game_over_signal.emit(won)
