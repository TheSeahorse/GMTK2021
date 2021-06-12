extends Container

onready var rope = preload("res://Rope.tscn")
onready var faller = preload("res://Faller.tscn")
onready var long_faller = preload("res://LongFaller.tscn")
onready var star = preload("res://Star.tscn")
onready var five_star = preload("res://5Star.tscn")
onready var player = preload("res://Player.tscn").instance()

var GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")

var rng = RandomNumberGenerator.new()
var current_rope = null
var current_star
var points = 0
var game_over = false
var can_spawn_rope = true
var level = 0

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
        if event.button_index == BUTTON_LEFT and event.is_pressed() and can_spawn_rope:
            spawn_rope()


func _process(_delta):
    if not $OutOfZoneTimer.is_stopped():
        var time_left = $OutOfZoneTimer.get_time_left()
        var percentage = abs(3 - time_left) / 3 * 100
        $HUD/ColorRect.color = Color8(255, 0, 0, percentage)



func _physics_process(_delta):
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


func _on_LevelTimer_timeout():
    level += 1


func _on_FallerTimer_timeout():
    if level == 0:
        pass
    level(level)


func _on_OutOfZoneTimer_timeout():
    print("Game over")
    game_over = true
    player.queue_free()


func _on_RopeRecharge_timeout():
    can_spawn_rope = true


func _star_touched(body):
    body.queue_free()
    points += 1
    $HUD/Label.text = str(points)
    add_star()


func _five_star_touched(body):
    body.queue_free()
    points += 5
    $HUD/Label.text = str(points)


func level(level: int):
    match level:
        1:
            add_faller()
        2:
            var chance = randi() % 3
            if chance == 0:
                add_long_faller()
            else:
                add_faller()
        3:
            var chance = randi() % 10
            if chance == 0:
                add_falling_star()
            elif chance < 4:
                add_long_faller()
            else:
                add_faller()


func give_player_boost():
    var max_boost = 4000
    var boost = Vector2(0,0)
    var velocity = player.linear_velocity
    boost = velocity*10
    if boost.x > max_boost:
        boost.x = max_boost
    if boost.y > max_boost:
        boost.y = max_boost
    print(boost)
    player.apply_impulse(Vector2.ZERO, boost)


func add_faller():
    var new_faller = faller.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var new_pos_x = rng.randf_range(0, width)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -64
    $Fallers.add_child(new_faller)


func add_long_faller():
    var new_faller = long_faller.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var new_pos_x = rng.randf_range(256, width - 256)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -256
    if randi() % 2 == 0:
        new_faller.rotation_degrees = 90
    $Fallers.add_child(new_faller)


func add_falling_star():
    var star = five_star.instance()
    var width = ProjectSettings.get_setting("display/window/size/width")
    var new_pos_x = rng.randf_range(0, width)
    star.position.x = new_pos_x
    star.position.y = -64
    star.angular_velocity = rng.randf_range(-5, 5)
    star.connect("area_body_entered", self, "_five_star_touched")
    $Fallers.add_child(star)


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

    start_rope_recharge_timer()


func despawn_rope():
    if current_rope != null:
        remove_child(current_rope)
        current_rope.free()
        current_rope = null
        give_player_boost()


func start_rope_recharge_timer():
    can_spawn_rope = false
    $RopeRecharge.start()
    player.rope_cooldown(true)



