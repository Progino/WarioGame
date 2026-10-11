extends Node2D

signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var button: Button = $TargetButton

var has_won: bool = false
var game_ended: bool = false
var screen_width: float = 1152.0
var screen_height: float = 648.0

func _ready() -> void:
	randomize_button_position()
	
	timer.wait_time = 2.0
	timer.start()
	
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)

func randomize_button_position() -> void:
	var button_size: Vector2 = button.size
	
	var max_x: float = screen_width - button_size.x
	var max_y: float = screen_height - button_size.y
	
	var min_margin_x: float = 20.0
	var min_margin_y: float = 80.0 
	
	var random_x: float = randf_range(min_margin_x, max_x)
	var random_y: float = randf_range(min_margin_y, max_y)
	
	button.position = Vector2(random_x, random_y)

func _on_button_pressed() -> void:
	has_won = true
	end_game(has_won)

func _on_timer_timeout() -> void:
	end_game(has_won)

func end_game(won: bool) -> void:
	if game_ended: return
	game_ended = true
	
	timer.stop()
	game_over_signal.emit(won)
