extends RigidBody2D


func _on_BigTimer_timeout():
    $ShrinkTimer.start()


func _on_ShrinkTimer_timeout():
    if self.scale.x < 0.2:
        get_parent().get_parent().despawn_rope()
    else:
        self.scale.x *= 0.97
        self.scale.y *= 0.97

func _on_collision_detector_body_entered(body):
    if !(body is Star):
        $collision.play()
