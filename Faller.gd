extends RigidBody2D
class_name Faller

var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")


func _physics_process(_delta):
    if position.y > GAME_WIDTH:
        queue_free()
