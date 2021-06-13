extends RigidBody2D
class_name Faller

var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")


func _physics_process(_delta):
    if position.y > GAME_WIDTH:
        queue_free()

#Only applies to SilverStars, called from main, main checks if silverstar
func die():
    $CollisionShape2D.set_deferred("disabled", true)
    $DeathTimer.start()
    $Sprite.hide()
    $PlusFive.show()

#Silverstar only
func _on_DeathTimer_timeout():
    self.queue_free()
