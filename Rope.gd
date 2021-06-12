extends Node2D

var rope_piece = preload("res://RopePiece.tscn")
var piece_length = 20.0
var rope_pieces = []
var rope_points : PoolVector2Array = []
var rope_close_tolerence = piece_length

onready var rope_start_piece = $RopeStartPiece


func _process(_delta):
    get_rope_points()
    if !rope_points.empty():
        update()


func _draw():
    if rope_points.size() > 1:
        draw_polyline(rope_points, Color("80604D"))


func spawn_rope(start_pos: Vector2, end_pos: Vector2, player: Object):
    rope_start_piece.global_position = start_pos

    start_pos = rope_start_piece.get_node("C/J").global_position
    end_pos = player.get_node("C/J").global_position

    var distance = start_pos.distance_to(end_pos)
    var segments = round(distance / piece_length)
    var spawn_angle = (end_pos - start_pos).angle() - PI/2

    create_rope(segments, rope_start_piece, end_pos, spawn_angle, player)


func create_rope(amount: int, parent: Object, end_pos: Vector2, spawn_angle: float, player: Object):
    for i in amount:
        parent = add_piece(parent, spawn_angle)
        rope_pieces.append(parent)

        var joint_pos = parent.get_node("C/J").global_position
        if joint_pos.distance_to(end_pos) < rope_close_tolerence:
            player.attach_rope(parent)
            rope_pieces.append(player.get_node("C/J"))
            break


func add_piece(parent:Object, spawn_angle:float) -> Object:
    var joint = parent.get_node("C/J") as PinJoint2D
    var piece = rope_piece.instance()
    piece.global_position = joint.global_position
    piece.rotation = spawn_angle
    piece.parent = self
    add_child(piece)
    joint.node_a = parent.get_path()
    joint.node_b = piece.get_path()

    return piece


func get_rope_points():
    rope_points = []
    #rope_points.append(rope_start_piece.global_position)
    for r in rope_pieces:
        if r != null:
            rope_points.append(r.global_position)

