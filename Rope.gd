extends Node

var rope_piece = preload("res://RopePiece.tscn")
var piece_length = 20.0
var rope_pieces = []
var rope_close_tolerence = 20.0

onready var rope_start_piece = $RopeStartPiece
onready var rope_end_piece = $RopeEndPiece


func spawn_rope(start_pos: Vector2, end_pos: Vector2, player: Object):
    rope_start_piece.global_position = start_pos
    rope_end_piece.global_position = end_pos
    
    start_pos = rope_start_piece.get_node("C/J").global_position
    end_pos = rope_end_piece.get_node("C/J").global_position
    
    var distance = start_pos.distance_to(end_pos)
    var segments = round(distance / piece_length)
    var spawn_angle = (end_pos - start_pos).angle() - PI/2
    
    create_rope(segments, rope_start_piece, end_pos, spawn_angle, player)


func create_rope(amount: int, parent: Object, end_pos: Vector2, spawn_angle: float, player: Object):
    for i in amount:
        parent = add_piece(parent, i, spawn_angle)
        rope_pieces.append(parent)
        
        var joint_pos = parent.get_node("C/J").global_position
        if joint_pos.distance_to(end_pos) < rope_close_tolerence:
            break
    
    rope_end_piece.get_node("C/J").node_a = player.get_path()
    rope_end_piece.get_node("C/J").node_b = rope_pieces[-1].get_path()
    rope_end_piece.hide()



func add_piece(parent:Object, id:int, spawn_angle:float) -> Object:
    var joint = parent.get_node("C/J") as PinJoint2D
    var piece = rope_piece.instance()
    piece.global_position = joint.global_position
    piece.rotation = spawn_angle
    piece.parent = self
    add_child(piece)
    joint.node_a = parent.get_path()
    joint.node_b = piece.get_path()
    
    return piece
