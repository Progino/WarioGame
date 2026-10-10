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
	# Imposta la durata del microgioco (3 secondi per dare frenesia)
	timer.wait_time = 3.0
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if game_ended: return
	
	# Muove il quadratino del giocatore costantemente verso destra
	player.position.x += speed * delta
	
	if player.position.x > screen_width:
		end_game(false)

func _input(event: InputEvent) -> void:
	if game_ended: return
	
	# Rileva quando viene premuto il tasto Spazio (ui_accept)
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		# "Consuma" l'input per evitare che passi al MainManager in caso di Game Over
		get_viewport().set_input_as_handled()
		
		# Controllo collisione: se il quadratino tocca la linea traguardo, hai vinto!
		if player.get_global_rect().intersects(goal.get_global_rect()):
			end_game(true)
		else:
			end_game(false) # Premuto nel momento sbagliato!

func _on_timer_timeout() -> void:
	# Tempo scaduto senza aver premuto Spazio
	end_game(false)

func end_game(won: bool) -> void:
	# Protezione di sicurezza per evitare doppi segnali nello stesso frame
	if game_ended: return
	game_ended = true
	
	set_process(false)
	set_process_input(false)
	timer.stop()
	
	# Invia il verdetto finale al regista del gioco
	game_over_signal.emit(won)
