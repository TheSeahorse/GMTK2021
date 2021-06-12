extends RigidBody2D

signal area_body_entered(star)


func _on_Area2D_body_entered(body):
    emit_signal("area_body_entered", self)
