extends Control

signal play_again
signal back_to_menu

var GameData

func _ready():
    GameData = get_node("/root/GameData")
    $VBoxContainer/HighscoreLabel.text = "Highscore: " + str(GameData.highscore)


func update_score():
    $Death.play()
    $VBoxContainer/HighscoreLabel.text = "Highscore: " + str(GameData.highscore)


func _on_Button_pressed():
    get_tree().paused = false
    emit_signal("play_again")


func _on_BackToMenu_pressed():
    get_tree().paused = false
    emit_signal("back_to_menu")
