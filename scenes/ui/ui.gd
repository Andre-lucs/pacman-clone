extends CanvasLayer
class_name UIRoot

@onready var score_label: Label = $HUD/MarginContainer/ScoreContainer/ScoreLabel
@onready var high_score_label: Label = $HUD/MarginContainer/HighScoreContainer2/HighScoreLabel
@onready var game_over_overlay: Control = $GameOverOverlay

@export var life_icons : Array[TextureRect]

const HIGH_SCORE_FILE = "user://user_high_score.tres"
var curr_high_score :int = 0

func _ready() -> void:
	get_high_score()
	game_over_overlay.hide()

func update_score_label(value: int):
	var text = String.num(value)
	while text.length() < 4:
		text = "0"+text
	score_label.text = text

func update_life_display(amount:int):
	for i in amount:
		life_icons[i].visible = true
	for i in 3:
		if i>= amount: life_icons[i].visible = false

func update_high_score_label():
	var scoretext: String = String.num_int64(curr_high_score)
	while scoretext.length()<8:
		scoretext =  "0"+scoretext
	high_score_label.text = scoretext

func save_new_score(score:int):
	var hs = HighScoreResource.new()
	hs.highest_score = score
	ResourceSaver.save(hs, HIGH_SCORE_FILE)

func get_high_score():
	if not ResourceLoader.exists(HIGH_SCORE_FILE):
		save_new_score(0)
	var hs :HighScoreResource= ResourceLoader.load(HIGH_SCORE_FILE, "HighScoreResource")
	curr_high_score = hs.highest_score
	update_high_score_label()

func _on_game_over_event(score:int) -> void:
	game_over_overlay.show()
	if curr_high_score < score:
		save_new_score(score)

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
