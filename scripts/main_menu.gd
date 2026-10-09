extends Node2D

@onready var play_button: Button = $PlayButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed() -> void:
	# Cambia scena e avvia il manager di gioco
	get_tree().change_scene_to_file("res://scenes/main.tscn")
