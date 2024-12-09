extends Area2D
class_name Coin

@export var value : int = 10
var game : Game;

func _ready():
	if owner is Game:
		game = owner
	elif(get_parent().owner is Game):
		game = get_parent().owner

func collect():
	game.collect_coin(value)
	$AnimationPlayer.play("collected")

func _on_body_entered(body: Node2D) -> void:
	if body is PacMan:
		body.picked_coin(self)
		collect()
