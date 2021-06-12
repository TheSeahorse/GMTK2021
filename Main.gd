extends Container

onready var rope = preload("res://Rope.tscn")
onready var faller = preload("res://Faller.tscn")
onready var star = preload("res://Star.tscn")
onready var player = preload("res://Player.tscn").instance()

var GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")

var rng = RandomNumberGenerator.new()
var current_rope = null
var current_star
var points = 0
var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()
    player.position = Vector2(800,300)
    player.linear_velocity = Vector2(400, -400)
    add_child(player)
    add_star()
    set_process(true)
    set_process_input(true)


func _input(event):
    if game_over:
        return
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and !event.is_pressed():
            despawn_rope()
        if event.button_index == BUTTON_LEFT and event.is_pressed():
            spawn_rope()


func _process(delta):
    if not $OutOfZoneTimer.is_stopped():
        var time_left = $OutOfZoneTimer.get_time_left()
        var percentage = abs(3 - time_left) / 3 * 100
        $HUD/ColorRect.color = Color8(255, 0, 0, percentage)



func _physics_process(delta):
    if not game_over and ((player.position.y > GAME_HEIGHT or player.position.y < 0) or (player.position.x < 0 or player.position.x > GAME_WIDTH)):
        if $OutOfZoneTimer.is_stopped() and not game_over:
            print("Starting OutOfZoneTimer timer")
            $OutOfZoneTimer.start(3)
    else:
        if not $OutOfZoneTimer.is_stopped():
            $OutOfZoneTimer.stop()
            reset_game_over_colors()

func reset_game_over_colors():
    var tween = get_node("Tween")
    tween.interpolate_property($HUD/ColorRect, "color",
        $HUD/ColorRect.color, Color8(255, 0, 0, 0), 0.5,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.start()


func _on_Timer_timeout():
    add_faller()


func _on_OutOfZoneTimer_timeout():
    print("Game over")
    game_over = true
    player.queue_free()


func _star_touched(star):
    star.queue_free()
    points += 1
    $HUD/Label.text = str(points)
    add_star()


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


func add_star():
    var new_star = star.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var height = GAME_HEIGHT
    var new_pos_x = rng.randf_range(0, width)
    var new_pos_y = rng.randf_range(0, height)
    new_star.position = Vector2(new_pos_x, new_pos_y)
    new_star.connect("body_entered", self, "_star_touched")
    $Stars.add_child(new_star)

#called by Player
func spawn_rope():
    var mouse_pos = get_global_mouse_position()
    var player_pos = player.position
    if game_over:
        return
    if player_pos.distance_to(mouse_pos) > 300:
        var angle = mouse_pos.angle_to_point(player_pos)
        mouse_pos = player_pos + Vector2(cos(angle) * 320, sin(angle) * 320)

    current_rope = rope.instance()
    add_child(current_rope)
    current_rope.spawn_rope(mouse_pos, player_pos, player)

func despawn_rope():
    if current_rope != null:
        remove_child(current_rope)
        current_rope.free()
        current_rope = null
        give_player_boost()
