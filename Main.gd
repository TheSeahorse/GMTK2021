extends Node2D

onready var faller = preload("res://Faller.tscn")
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()


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
