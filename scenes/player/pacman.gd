class_name Player
extends CharacterBody2D

const SPEED = 300.0
var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	player_input()
	
	velocity = direction * SPEED
	
	move_and_slide()

func player_input():
	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2.LEFT
	if Input.is_action_just_pressed("ui_right"):
		direction = Vector2.RIGHT
	if Input.is_action_just_pressed("ui_up"):
		direction = Vector2.UP
	if Input.is_action_just_pressed("ui_down"):
		direction = Vector2.DOWN

func die():
	get_tree().reload_current_scene()
