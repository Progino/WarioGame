extends Node2D

signal game_over_signal(won: bool)

@onready var timer: Timer = $MicroTimer
@onready var player: ColorRect = $Player
@onready var obstacle: ColorRect = $Obstacle

var speed: float = 300.0
var obstacle_speed: float = 400.0
var has_lost: bool = false

func _ready() -> void:
	timer.wait_time = 3.5
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if has_lost: return
	
	# Movimento del giocatore (Destra / Sinistra)
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		player.position.x -= speed * delta
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		player.position.x += speed * delta
		
	# Movimento dell'ostacolo verso il basso
	obstacle.position.y += obstacle_speed * delta
	
	# Controllo collisione semplificato (AABB)
	if player.get_global_rect().intersects(obstacle.get_global_rect()):
		has_lost = true
		end_game(false) # Colpito! Hai perso

func _on_timer_timeout() -> void:
	# Se il tempo scade e sei vivo, hai vinto!
	end_game(true)

func end_game(won: bool) -> void:
	set_process(false)
	timer.stop()
	emit_signal("game_over_signal", won)
