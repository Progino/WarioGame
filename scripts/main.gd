extends Node2D

var microgames_dict: Dictionary = {
	"res://scenes/game_click_me.tscn": "CLICK!",
	"res://scenes/game_dodge.tscn": "DODGE!",
	"res://scenes/game_mash.tscn": "PRESS!",
	"res://scenes/game_stop.tscn": "STOPPIT!"
}

@onready var microgames: Array = microgames_dict.keys()

var lives: int = 5
var score: int = 0
var number_of_minigames: int = 0 
var current_game: Node = null
var last_game_path: String = ""
var is_game_over: bool = false

var difficulty_multiplier: float = 1.0

@onready var status_label: Label = $UI/StatusLabel
@onready var time_bar: ProgressBar = $UI/TimeBar

func _ready() -> void:
	time_bar.hide()
	start_intermission()

func _process(_delta: float) -> void:
	if is_instance_valid(current_game) and current_game.has_node("MicroTimer"):
		var game_timer: Timer = current_game.get_node("MicroTimer")
		if game_timer.time_left > 0:
			var percentage: float = (game_timer.time_left / game_timer.wait_time) * 100.0
			time_bar.value = percentage

func _input(event: InputEvent) -> void:
	if is_game_over:
		if event.is_action_pressed("ui_accept") or event is InputEventMouseButton:
			get_viewport().set_input_as_handled()
			restart_entire_game()

func start_intermission() -> void:
	time_bar.hide()
	
	if lives <= 0:
		trigger_game_over()
		return
		
	status_label.text = "Lives: " + str(lives) + " | Points: " + str(score)
	status_label.show()
	
	await get_tree().create_timer(1.5).timeout
	

	if number_of_minigames > 0 and number_of_minigames % 5 == 0:
		
		difficulty_multiplier += 0.2
		status_label.text = "SPEED UP!"
		await get_tree().create_timer(1.5).timeout

	
	var next_game_path = select_random_microgame_path()
	
	if next_game_path != "":
		var command_text: String = microgames_dict[next_game_path]
		status_label.text = command_text
		
		await get_tree().create_timer(0.5).timeout
		
		status_label.hide()
		execute_load(next_game_path)

func select_random_microgame_path() -> String:
	if microgames.size() == 0: 
		print("Error: no game in vocabulary!")
		return ""
	
	if microgames.size() == 1: 
		return microgames[0] 

	var random_path: String = microgames[randi() % microgames.size()]
	while random_path == last_game_path:
		random_path = microgames[randi() % microgames.size()]
	
	last_game_path = random_path
	return random_path


func execute_load(path: String) -> void:
	var game_scene: PackedScene = load(path)
	current_game = game_scene.instantiate()
	
	
	if current_game.has_node("MicroTimer"):
		var micro_timer: Timer = current_game.get_node("MicroTimer")
		micro_timer.wait_time = micro_timer.wait_time / difficulty_multiplier
	
	
	if "speed" in current_game:
		current_game.speed = current_game.speed * difficulty_multiplier
		
	
	if "obstacle_speed" in current_game:
		current_game.obstacle_speed = current_game.obstacle_speed * difficulty_multiplier
		
	
	if "target_clicks" in current_game:
		current_game.target_clicks = int(current_game.target_clicks * (1.0 + (difficulty_multiplier - 1.0) * 0.5))

	current_game.game_over_signal.connect(_on_microgame_finished)
	add_child(current_game)
	
	time_bar.value = 100
	time_bar.show()

func _on_microgame_finished(won: bool) -> void:
	time_bar.hide()
	
	if is_instance_valid(current_game):
		current_game.queue_free()
	
	
	number_of_minigames += 1
	if won:
		score += 1
	else:
		lives -= 1
		
	start_intermission()

func trigger_game_over() -> void:
	is_game_over = true
	time_bar.hide()
	status_label.text = "GAME OVER!\nPoints: " + str(score) + "\n\n[Press space or click to retry]"
	status_label.show()

func restart_entire_game() -> void:
	is_game_over = false
	number_of_minigames = 0
	difficulty_multiplier = 1.0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
