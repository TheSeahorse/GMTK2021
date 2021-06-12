extends Control

signal play_again

var GameData

func _ready():
    GameData = get_node("/root/GameData")
    $VBoxContainer/HighscoreLabel.text = "Highscore: " + str(GameData.highscore)


func update_score():
    $VBoxContainer/HighscoreLabel.text = "Highscore: " + str(GameData.highscore)


func _on_Button_pressed():
    emit_signal("play_again")
