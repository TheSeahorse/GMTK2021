extends Node2D

onready var rope = preload("res://Rope.tscn")
onready var faller = preload("res://Faller.tscn")
onready var player = preload("res://Player.tscn").instance()
var rng = RandomNumberGenerator.new()
var start_pos: Vector2 #Point where the rope starts aka where you click
var end_pos: Vector2 #Point where the rope ends aka where the player ball is
var current_rope

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()
    player.position = Vector2(800,300)
    player.linear_velocity = Vector2(400, -400)
    add_child(player)


func _input(event):
    if event is InputEventMouseButton and event.is_pressed():
        start_pos = get_global_mouse_position()
        end_pos = player.position
        current_rope = rope.instance()
        add_child(current_rope)
        current_rope.spawn_rope(start_pos, end_pos, player)
    elif event is InputEventMouseButton and !event.is_pressed():
        remove_child(current_rope)
        current_rope.free()
        current_rope = null
        give_player_boost()


func _process(delta):
    pass


func _on_Timer_timeout():
    add_faller()


func give_player_boost():
    if player.linear_velocity.x > 0:
        player.apply_impulse(Vector2.ZERO,Vector2(3000,-5000))
    else:
        player.apply_impulse(Vector2.ZERO,Vector2(-3000,-5000))


func add_faller():
    var new_faller = faller.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var new_pos_x = rng.randf_range(0, width)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -64
    $Fallers.add_child(new_faller)
