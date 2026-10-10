extends Node2D

# Segnale personalizzato che avvisa il manager se abbiamo vinto o perso
signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var button: Button = $TargetButton

var has_won: bool = false
var game_ended: bool = false
var screen_width: float = 1152.0
var screen_height: float = 648.0

func _ready() -> void:
	# Sposta il pulsante in una posizione casuale sicura all'interno dello schermo
	randomize_button_position()
	
	# Imposta la durata del microgioco (es. 4 secondi)
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.start()
	
	# Collega i segnali dei nodi interni tramite codice
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)

func randomize_button_position() -> void:
	# Recuperiamo la dimensione del pulsante per evitare che esca dai bordi destri o inferiori
	var button_size: Vector2 = button.size
	
	# Calcoliamo i limiti massimi sottraendo la grandezza del pulsante
	var max_x: float = screen_width - button_size.x
	var max_y: float = screen_height - button_size.y
	
	# Margine di sicurezza minimo dal bordo alto/sinistro (es. 20 pixel)
	var min_margin: float = 20.0
	
	# Posizioniamo SOLO il pulsante, lasciando la scena principale a (0,0)
	var random_x: float = randf_range(min_margin, max_x)
	var random_y: float = randf_range(min_margin, max_y)
	
	button.position = Vector2(random_x, random_y)

func _on_button_pressed() -> void:
	# Se il giocatore clicca, vince immediatamente e il gioco si interrompe
	has_won = true
	end_game(has_won)

func _on_timer_timeout() -> void:
	# Se il tempo scade prima del click, ha perso
	end_game(has_won)

func end_game(won: bool) -> void:
	# FIX ENDGAME: impedisce l'attivazione di segnali multipli nello stesso frame
	if game_ended: return
	game_ended = true
	
	timer.stop()
	# Invia il responso al MainManager usando la sintassi nativa di Godot 4
	game_over_signal.emit(won)
