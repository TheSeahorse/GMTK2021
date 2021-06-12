extends RigidBody2D


signal star_entered(body)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func _physics_process(_delta):
    pass


func attach_rope(rope_piece: Object):
    $C/J.node_a = self.get_path()
    $C/J.node_b = rope_piece.get_path()


func get_rope_outline():
    return get_node("rope_outline")


func rope_cooldown(on_cooldown: bool):
    $red_ball_cooldown.show()
    $cd_tween.interpolate_property($red_ball_cooldown, "modulate" , Color(1,1,1,1), Color(1,1,1,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $cd_tween.start()


func _on_StarDetector_entered(body):
    emit_signal("star_entered", body)
