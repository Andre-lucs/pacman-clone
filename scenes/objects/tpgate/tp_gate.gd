class_name TpGate
extends Area2D

@export var gate: TpGate
var recieving := false

func _on_body_entered(body: Node2D) -> void:
	if recieving:
		recieving = false
	else:
		gate.recieving = true
		body.global_position = gate.global_position
