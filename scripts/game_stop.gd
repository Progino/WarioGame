extends Node2D

signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var goal: ColorRect = $Goal
@onready var player: ColorRect = $Player

var has_won: bool = false
var game_ended: bool = false
var speed: float = 450.0


var screen_width: float = 1152.0

func _ready() -> void:
	timer.wait_time = 3.0
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if game_ended: return
	
	player.position.x += speed * delta
	
	if player.position.x > screen_width:
		end_game(false)

func _input(event: InputEvent) -> void:
	if game_ended: return
	
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		get_viewport().set_input_as_handled()
		
		if player.get_global_rect().intersects(goal.get_global_rect()):
			end_game(true)
		else:
			end_game(false)

func _on_timer_timeout() -> void:
	end_game(false)

func end_game(won: bool) -> void:
	if game_ended: return
	game_ended = true
	
	set_process(false)
	set_process_input(false)
	timer.stop()
	
	game_over_signal.emit(won)
