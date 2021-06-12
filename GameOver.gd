extends Control

signal play_again


func _on_Button_pressed():
    emit_signal("play_again")
