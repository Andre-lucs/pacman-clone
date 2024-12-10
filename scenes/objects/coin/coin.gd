extends Area2D

signal collected(value:int)

@export var value : int = 20
var game

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	collected.connect(game._on_coin_collected)
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collected.emit(value)
		queue_free()
	
