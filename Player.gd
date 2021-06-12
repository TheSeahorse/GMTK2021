extends RigidBody2D



# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.



func _physics_process(delta):
    pass


func attach_rope(rope_piece: Object):
    $C/J.node_a = self.get_path()
    $C/J.node_b = rope_piece.get_path()


func get_rope_outline():
    return get_node("rope_outline")


#func _on_rope_outline_input_event(viewport, event, shape_idx):
#    if event is InputEventMouseButton:
#        if event.button_index == BUTTON_LEFT and event.is_pressed():
#            get_parent().spawn_rope()
