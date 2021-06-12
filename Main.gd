extends Node2D

onready var rope = preload("res://Rope.tscn")
onready var faller = preload("res://Faller.tscn")
onready var star = preload("res://Star.tscn")
onready var player = preload("res://Player.tscn").instance()
var rng = RandomNumberGenerator.new()
var start_pos: Vector2 #Point where the rope starts aka where you click
var end_pos: Vector2 #Point where the rope ends aka where the player ball is
var current_rope
var current_star
var points = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()
    player.position.x = 1200
    add_child(player)
    add_star()


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
        player.apply_impulse(Vector2.ZERO,Vector2(0,-10000))


func _process(delta):
    pass


func _on_Timer_timeout():
    add_faller()


func add_faller():
    var new_faller = faller.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var new_pos_x = rng.randf_range(0, width)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -64
    $Fallers.add_child(new_faller)


func add_star():
    var new_star = star.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var height = ProjectSettings.get_setting("display/window/size/height")
    var new_pos_x = rng.randf_range(0, width)
    var new_pos_y = rng.randf_range(0, height)
    new_star.position = Vector2(new_pos_x, new_pos_y)
    new_star.connect("body_entered", self, "_star_touched")
    $Stars.add_child(new_star)


func _star_touched(star):
    star.queue_free()
    points += 1
    $HUD/Label.text = str(points)
    add_star()
