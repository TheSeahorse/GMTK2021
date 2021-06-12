extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func _on_BigTimer_timeout():
    $ShrinkTimer.start()


func _on_ShrinkTimer_timeout():
    if self.scale.x < 0.2:
        get_parent().get_parent().despawn_rope()
    else:
        self.scale.x *= 0.97
        self.scale.y *= 0.97
