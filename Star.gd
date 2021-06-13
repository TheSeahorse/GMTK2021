extends StaticBody2D
class_name Star


func die():
    $CollisionShape2D.set_deferred("disabled", true)
    $DeathTimer.start()
    $Sprite.hide()
    $PlusOne.show()


func _on_DeathTimer_timeout():
    self.queue_free()
