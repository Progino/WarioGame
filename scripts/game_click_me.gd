extends Node2D

# Segnale personalizzato che avvisa il manager se abbiamo vinto o perso
signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var button: Button = $TargetButton

var has_won: bool = false

func _ready() -> void:
	# Imposta la durata del microgioco (es. 4 secondi)
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.start()
	
	# Collega i segnali dei nodi interni tramite codice
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Se il giocatore clicca, vince immediatamente e il gioco si interrompe
	has_won = true
	end_game()

func _on_timer_timeout() -> void:
	# Se il tempo scade prima del click, ha perso
	end_game()

func end_game() -> void:
	timer.stop()
	# Invia il responso al MainManager
	emit_signal("game_over_signal", has_won)
