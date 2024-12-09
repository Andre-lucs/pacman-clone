class_name Game
extends Node

enum GameState{ INTRO, PLAYING, PAUSED, ENDED }

signal update_score_label(score: int)
signal update_life_display(amount : int)
signal game_over_event(score:int)
signal game_complete

@export var ghosts_states_order : Array[GhostStateResource] = []
@export var blinky : Ghost
@export var pinky : Ghost
@export var inky : Ghost
@export var clyde : Ghost
@onready var walls := $WallsLayer
@onready var ghosts : Array[Ghost] = [blinky, pinky, inky, clyde]
@onready var state_change_timer : Timer = $Timers/StateChangeTimer
var next_state := 0

var game_state : GameState = GameState.INTRO

@onready var pacman: PacMan = $Pacman
var player_lifes : int = 0 :
	set(value):
		player_lifes = value
		update_life_display.emit(player_lifes)

var coin_count : int 
var picked_coins : int = 0:
	set(value):
		handle_coin_picked(value)
		picked_coins = value
var base_coins : Array
var score : int:
	set(value):
		score = value
		update_score_label.emit(score)

var audio_player := AudioStreamPlayer.new()

func _ready() -> void:
	_get_coins.call_deferred()
	
	audio_player.stream = preload("res://assets/sounds/pacman_beginning.wav")
	audio_player.finished.connect(start_game)
	add_child(audio_player)
	new_game.call_deferred()

func _get_coins():
	var coins = get_tree().get_nodes_in_group("coins").filter(func(i):return i is Coin)
	base_coins = coins.map(func(i):return i.duplicate())

# Métodos de controle do jogo

func new_game():
	_spawn_coins()
	player_lifes = 2
	picked_coins = 0
	game_state = GameState.INTRO
	audio_player.play()

func start_game():
	for g in ghosts:
		g.reset()
	pacman.reset()
	next_state = 0
	game_state = GameState.PLAYING
	reset_and_free_ghosts()

func complete_level():
	print("level completed")
	game_state = GameState.ENDED
	pause_ghosts()
	game_complete.emit()
	get_tree().create_timer(5).timeout.connect(new_game)

# Métodos de controle dos fantasmas

func reset_and_free_ghosts():
	for g in ghosts:
			g.reset()
	blinky.current_state = get_current_state() # ja começa ativo
	free_ghost(pinky)
	if picked_coins >= 30:
		free_ghost(inky, 6)
	if picked_coins >= coin_count / 3:
		free_ghost(clyde, 12)
	go_to_next_ghosts_state()

func free_ghost(ghost: Ghost, delay : float = 0):
	var collision = ghost.find_child("CollisionShape2D")
	collision.set_deferred("disabled", true)
	var exitTween = create_tween()
	if delay > 0:
		exitTween.tween_interval(delay)
	exitTween.tween_property(ghost, "global_position", get_hideout_position(), 1)
	exitTween.tween_property(ghost, "global_position", get_outside_pos(), 2)
	exitTween.tween_callback(func():
		collision.set_deferred("disabled", false)
		ghost.set_deferred("current_state", get_current_state())
	)
	exitTween.play()

func pause_ghosts():
	for i in ghosts:
		i.current_state = Ghost.states.IDLE

func set_ghosts_state(new_state : Ghost.states):
	for i in ghosts:
		if i.current_state in [Ghost.states.SCATTER, Ghost.states.CHASE, ]:
			i.current_state = new_state

func go_to_next_ghosts_state():
	# Sets the time for the next state
	state_change_timer.wait_time = ghosts_states_order[next_state].duration
	set_ghosts_state(ghosts_states_order[next_state].state)
	next_state += 1
	if next_state < ghosts_states_order.size():
		state_change_timer.start()

func get_current_state() -> Ghost.states:
	return ghosts_states_order[next_state-1].state

# Métodos de controle das moedas

func collect_coin(value: int):
	if value > score:
		if picked_coins >= coin_count:
			complete_level()
	picked_coins+=1
	score += value

func _spawn_coins():
	for i in get_tree().get_nodes_in_group("coins"):
		i.queue_free()
	for i in base_coins:
		var copy = i.duplicate()
		copy.game = self
		add_child(copy)
	coin_count = base_coins.size()

# Métodos de controle dos eventos

func player_dead():
	print("player died")
	pause_ghosts()
	player_lifes -= 1
	if player_lifes <= 0:
		game_over()
		return
	get_tree().create_timer(5).timeout.connect(start_game)

func game_over():
	game_over_event.emit(score)
	game_state = GameState.ENDED

func handle_coin_picked(value : int):
	if picked_coins < 30 and value >= 30:
		free_ghost(inky);
	if picked_coins < coin_count/3 && value >= coin_count/3:
		free_ghost(clyde);

# Utils

func get_hideout_position() -> Vector2:
	return $Markers/Hideout.global_position
func get_outside_pos() -> Vector2:
	return $Markers/Outside.global_position
