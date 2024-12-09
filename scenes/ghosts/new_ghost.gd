extends CharacterBody2D
class_name Ghost

enum states { IDLE, SCATTER, CHASE, SCARED, EATEN }

const GHOST_BLINK_MATERIAL = preload("res://scenes/ghosts/ghost_blink_material.tres")

@export var scatter_pos : Marker2D
@export var move_speed : float = 50
var game : Game
var pacman : PacMan
var current_state : states = states.IDLE:
	set(value): 
		current_state = value
		handle_state_change(value)
var facing_direction: Vector2i = Vector2.RIGHT

var target_pos : Vector2

@onready var ready_pos := self.global_position
@onready var scared_timer: Timer = $ScaredTimer
@onready var navigation_agent := $NavigationAgent2D

func _ready() -> void:
	game = self.owner
	pacman = game.find_child("Pacman")

func _physics_process(delta: float) -> void:
	if current_state == states.IDLE: return
	pick_target()
	navigation_agent.target_position = target_pos
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_target_reached():
		return

	move_ghost(delta)
	pick_animation()
	
	if current_state == states.EATEN && navigation_agent.is_target_reached():#global_position.distance_to(game.get_outside_pos()) < 3:
		global_position = target_pos
		current_state = states.IDLE
		game.free_ghost(self)

func move_ghost(_delta: float):
	var speed_multiplyer := 1.0
	match current_state:
		states.EATEN:
			speed_multiplyer = 5
		states.SCARED:
			speed_multiplyer = 0.8
	
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * move_speed * speed_multiplyer
	_on_velocity_computed(new_velocity)
	facing_direction = new_velocity.snapped(Vector2(90,90)).sign()

func pick_target() -> Vector2:
	match current_state:
		states.CHASE:
			target_pos = get_chase_target()
		states.SCATTER:
			target_pos = scatter_pos.global_position
		states.EATEN:
			target_pos = game.get_outside_pos()
	# Scared will be handled by the timer
	return target_pos

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func pick_animation():
	if current_state in [states.IDLE, states.SCARED]: return
	var dir_string := "right"
	if facing_direction == Vector2i.UP:
		dir_string = "up"
	elif facing_direction == Vector2i.LEFT: 
		dir_string = "left"
	elif facing_direction == Vector2i.DOWN: 
		dir_string = "down"
	
	var animation = ("dead_" if current_state == states.EATEN else "move_")
	if animation == "dead_":
		$BodyColor.visible = false
		$CommonSprite.visible = true
	else:
		$BodyColor.visible = true
		$CommonSprite.visible = false
		
	$AnimationPlayer.play(animation+dir_string) 

func get_chase_target() -> Vector2:
	return pacman.global_position

func reset():
	global_position = ready_pos
	current_state = states.IDLE
	scared_timer.stop()

func die():
	current_state = states.EATEN
	scared_timer.stop()

func handle_state_change(new_state:states):
	print("set", new_state, self)
	match new_state:
		states.IDLE:
			facing_direction = Vector2.RIGHT
		states.SCARED:
			$AnimationPlayer.play("scared")
			$BodyColor.hide()
			$CommonSprite.show()
			$CommonSprite.material = GHOST_BLINK_MATERIAL
			get_tree().create_timer(10).timeout.connect(func(): 
				$CommonSprite.material = null
				$CommonSprite.hide()
				$BodyColor.show()
				current_state = game.get_current_state())
			scared_timer.start()

func _on_scared_timer_timeout() -> void:    
	if current_state == states.SCARED:
		target_pos = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		scared_timer.start()  # Restart the timer for the next direction change
