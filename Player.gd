extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.



func _physics_process(delta):
    pass


func attach_rope(rope_piece: Object):
    $CollisionShape2D/PinJoint2D.node_a = self.get_path()
    $CollisionShape2D/PinJoint2D.node_b = rope_piece.get_path()
