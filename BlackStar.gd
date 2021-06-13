extends RigidBody2D
class_name BlackStar


func _ready():
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    var ang_vel = rand_range(-5.0,5.0)
    self.angular_velocity = ang_vel


func die():
    $CollisionShape2D.set_deferred("disabled", true)
    $DeathTimer.start()
    $Sprite.hide()
    $MinusOne.show()


func _on_DeathTimer_timeout():
    self.queue_free()


func _on_LifeTimer_timeout():
    self.queue_free()
