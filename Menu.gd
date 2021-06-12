extends Control


onready var Main = preload("res://Main.tscn")
var game

func _on_Button_pressed():
    $MenuItems.hide()
    play()


func play():
    if game:
        game.queue_free()
    game = Main.instance()
    game.connect("play_again", self, "play")
    add_child(game)
