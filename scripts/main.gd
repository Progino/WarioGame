extends Node2D

# Lista dei percorsi dei tuoi microgiochi
var microgames: Array[String] = [
	"res://scenes/game_click_me.tscn",
	"res://scenes/game_dodge.tscn",
	"res://scenes/game_mash.tscn"
]

var lives: int = 4
var score: int = 0
var current_game: Node = null
var last_game_path: String = "" # Memorizza l'ultimo gioco fatto
var is_game_over: bool = false

@onready var status_label: Label = $UI/StatusLabel

func _ready() -> void:
	randomize() 
	start_intermission()

func _input(event: InputEvent) -> void:
	# Se siamo in Game Over e il giocatore preme Spazio/Click, riavvia la partita
	if is_game_over and (event.is_action_pressed("ui_accept") or event is InputEventMouseButton):
		restart_entire_game()

func start_intermission() -> void:
	if lives <= 0:
		trigger_game_over()
		return
		
	status_label.text = "GET READY!\n\nLives: " + str(lives) + " | Points: " + str(score)
	status_label.show()
	
	await get_tree().create_timer(2.0).timeout
	
	status_label.hide()
	load_random_microgame()

func load_random_microgame() -> void:
	# Se c'è solo un gioco nella lista, lo carichiamo e basta per evitare loop infiniti
	if microgames.size() <= 1:
		execute_load(microgames[0])
		return

	# Sceglie un gioco a caso finché non è DIVERSO dall'ultimo fatto
	var random_path: String = microgames[randi() % microgames.size()]
	while random_path == last_game_path:
		random_path = microgames[randi() % microgames.size()]
	
	# Salva questo gioco come "ultimo fatto" per il prossimo round
	last_game_path = random_path
	execute_load(random_path)

func execute_load(path: String) -> void:
	var game_scene: PackedScene = load(path)
	current_game = game_scene.instantiate()
	current_game.connect("game_over_signal", Callable(self, "_on_microgame_finished"))
	add_child(current_game)

func _on_microgame_finished(won: bool) -> void:
	current_game.queue_free()
	
	if won:
		score += 1
	else:
		lives -= 1
		
	start_intermission()

func trigger_game_over() -> void:
	is_game_over = true
	status_label.text = "GAME OVER!\nPoints: " + str(score) + "\n\n[Press space or click to return to main menu]"
	status_label.show()

func restart_entire_game() -> void:
	# Ricarica la scena del menu principale per resettare tutto il loop
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
