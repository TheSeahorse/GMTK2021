extends Control

var GameData
onready var Main = preload("res://Main.tscn")
var game


func _ready():
    GameData = get_node("/root/GameData")
    GameData.load_score()


func _on_Credits_pressed():
    $Buttons.hide()
    $Tutorial.hide()
    $Credits.show()
    $Back.show()


func _on_Start_pressed():
    play()


func play():
    if game:
        game.queue_free()
    game = Main.instance()
    game.connect("play_again", self, "play")
    game.connect("back_to_menu", self, "back_to_menu")
    add_child(game)


func back_to_menu():
    if game:
        game.queue_free()
        game = null
    $Buttons.show()
    $Tutorial.show()
    $Credits.hide()
    $Back.hide()


func _on_Back_pressed():
    $Buttons.show()
    $Tutorial.show()
    $Credits.hide()
    $Back.hide()
