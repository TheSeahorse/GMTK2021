extends Sprite

signal body_entered(star)


func _on_Area2D_body_entered(_body):
    emit_signal("body_entered", self)
