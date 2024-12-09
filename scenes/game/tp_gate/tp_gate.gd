extends Area2D
class_name TpGate

@export var destination : TpGate
var receiving_body:= false

func _on_body_entered(body: Node2D) -> void:
	if destination and not receiving_body:
		destination.receiving_body = true
		destination.send(body)

func _on_body_exited(body: Node2D) -> void:
	receiving_body = false

func send(body : Node2D):
	body.global_position = global_position
