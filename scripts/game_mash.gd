extends Node2D

signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var bar: ProgressBar = $MashBar



var clicks: int = 0
var target_clicks: int = 10

func _ready() -> void:
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _input(event: InputEvent) -> void:
	# Rileva quando viene premuto il tasto Spazio
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		clicks += 1
		bar.value = clicks
		
		# Se raggiungi l'obiettivo prima del tempo, vinci subito
		if clicks >= target_clicks:
			end_game(true)

func _on_timer_timeout() -> void:
	# Tempo scaduto senza abbastanza click
	end_game(false)

func end_game(won: bool) -> void:
	set_process_input(false)
	timer.stop()
	emit_signal("game_over_signal", won)
