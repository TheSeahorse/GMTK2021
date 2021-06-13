extends RigidBody2D
class_name BlackStar

var shown = false


func _ready():
    $Mohaha.play()
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var ang_vel = rand_range(-5.0,5.0)
    self.angular_velocity = ang_vel

    $GrowTween.interpolate_property(self, "scale" , Vector2(0,0), Vector2(1,1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $GrowTween.start()
    $Sprite.show()


func die():
    $Mohaha.stop()
    $CollisionShape2D.set_deferred("disabled", true)
    $DeathTimer.start()
    $Sprite.hide()
    $MinusThree.show()


func _on_DeathTimer_timeout():
    self.queue_free()


func _on_LifeTimer_timeout():
    $CollisionShape2D.set_deferred("disabled", true)
    $GrowTween.interpolate_property(self, "scale" , Vector2(1,1), Vector2(0,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $GrowTween.start()
    $DeathTimer.start()


func _on_ShowSpriteTimer_timeout():
    self.show()


func _on_CollisionTimer_timeout():
    $CollisionShape2D.set_deferred("disabled", false)
