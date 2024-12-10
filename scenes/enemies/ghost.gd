extends CharacterBody2D

@export var player : Player
var speed = 200

func _physics_process(delta: float) -> void:

	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * speed
	
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
