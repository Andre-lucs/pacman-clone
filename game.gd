extends Node2D

var score := 0


func _on_coin_collected(value:int) -> void:
	score += value
	$UI/Control/MarginContainer/Label.text = "Score: "+ String.num(score)
	print(score)
