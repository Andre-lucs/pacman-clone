class_name PacMan
extends CharacterBody2D

signal player_died

@onready var picking_coins_timer: Timer = $PickingCoinsTimer
@onready var eating_sound : AudioStreamPlayer = $SoundEffects/EatingSound
@onready var game : Game = owner;
# ou @export var game: Game; ai voce escolhe pelo inspetor
@onready var ready_pos : Vector2 = self.global_position
const SPEED = 100.0
var direction := Vector2.ZERO

var dead := false
var picking_coins := false : 
	set(value):
		picking_coins = value
		if picking_coins:
			eating_sound.play(eating_sound.get_playback_position())
		else:
			eating_sound.stop()

func _physics_process(_delta: float) -> void:
	if not game.game_state == Game.GameState.PLAYING: return
	if dead: return
	controls()
	
	velocity = direction * SPEED
	
	move_and_slide()

func controls():
	if Input.is_action_just_pressed("up"):
		direction = Vector2.UP
	if Input.is_action_just_pressed("down"):
		direction = Vector2.DOWN
	if Input.is_action_just_pressed("left"):
		direction = Vector2.LEFT
	if Input.is_action_just_pressed("right"):
		direction = Vector2.RIGHT
	
	rotation = direction.angle()

func picked_coin(coin: Coin):
	picking_coins = true
	picking_coins_timer.start()

func die():
	dead = true
	$AnimatedSprite2D.play("death")
	$SoundEffects/DeathSound.play()
	player_died.emit()

func reset():
	direction = Vector2.ZERO
	global_position = ready_pos
	dead = false
	$AnimatedSprite2D.play("default")

func _on_picking_coins_timer_timeout() -> void: picking_coins = false
