extends Container

onready var rope = preload("res://Rope.tscn")
onready var faller = preload("res://Faller.tscn")
onready var long_faller = preload("res://LongFaller.tscn")
onready var Star = preload("res://Star.tscn")
onready var Laser = preload("res://Laser.tscn")
onready var SilverStar = preload("res://SilverStar.tscn")
onready var player = preload("res://Player.tscn").instance()

var GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")

var GameData

signal play_again

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
    GameData = get_node("/root/GameData")
    player.position = Vector2(800,300)
    player.linear_velocity = Vector2(400, -400)
    player.connect("star_entered", self, "_player_touched_star")
    add_child(player)
    set_process(true)
    set_process_input(true)


func _input(event):
    if game_over:
        return
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and !event.is_pressed():
            despawn_rope()
        if event.button_index == BUTTON_LEFT and event.is_pressed():
            if can_spawn_rope:
                spawn_rope()
            else:
                $DeclineRopeSpawn.play()


func _process(_delta):
    if not $OutOfZoneTimer.is_stopped():
        var time_left = $OutOfZoneTimer.get_time_left()
        var percentage = abs(1 - time_left) / 1 * 100
        $HUD/ColorRect.color = Color8(255, 0, 0, percentage)


func _physics_process(_delta):
    if not game_over and ((player.position.y > GAME_HEIGHT or player.position.y < 0) or (player.position.x < 0 or player.position.x > GAME_WIDTH)):
        if $OutOfZoneTimer.is_stopped() and not game_over:
            $OutOfZoneTimer.start(1)
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
    $RollingText.roll_text("Stage " + str(level))
    match level:
        1:
            $FallerTimer.wait_time = 10
        2:

            $FallerTimer.wait_time = 3
        3:
            add_long_faller()

        4:
            add_falling_star()

        5:
            $FallerTimer.wait_time = 1.5
        6:
            add_laser()


func _on_FallerTimer_timeout():
    spawner(level)


func _on_OutOfZoneTimer_timeout():
    game_over()


func _on_RopeRecharge_timeout():
    can_spawn_rope = true


func _player_touched_star(body):
    var is_a_star = true
    if body.is_in_group("one_point"):
        points += 1
        $StarPickup.play()
        add_star()
    elif body.is_in_group("five_points"):
        $SilverStarPickup.play()
        points += 5
    else:
        is_a_star = false

    if is_a_star:
        if points == 1:
            $LevelTimer.start()
            level = 1
            $RollingText.roll_text("Stage " + str(level))

        body.die()
        $HUD/Label.text = str(points)


func spawner(level: int):
    match level:
        0:
            pass
        1, 2:
            add_falling_star()
        3:
            var chance = randi() % 3
            if chance == 0:
                add_long_faller()
            else:
                add_faller()
        4, 5:
            var chance = randi() % 10
            if chance < 5:
                add_long_faller()
            else:
                add_faller()
            if chance == 0:
                add_falling_star()
        6:
            var chance = randi() % 10
            if chance < 5:
                add_long_faller()
            else:
                add_faller()
            if chance == 0:
                add_falling_star()
            if chance < 3:
                add_laser()
        _:
            var chance = randi() % 10
            if chance < 7:
                add_long_faller()
            else:
                add_faller()
            if chance == 0:
                add_falling_star()
            if chance < 5:
                add_laser()


func give_player_boost():
    if game_over:
        return
    var max_boost = 4000
    var boost = Vector2(0,0)
    var velocity = player.linear_velocity
    boost = velocity*10
    if boost.x > max_boost:
        boost.x = max_boost
    if boost.y > max_boost:
        boost.y = max_boost

    if max(abs(velocity.x), abs(velocity.y)) < 200:
        $RubberShot.volume_db = -30
    elif max(abs(velocity.x), abs(velocity.y)) < 400:
        $RubberShot.volume_db = -25
    elif max(abs(velocity.x), abs(velocity.y)) < 600:
        $RubberShot.volume_db = -20
    else:
        $RubberShot.volume_db = -15
    $RubberShot.play()
    player.apply_impulse(Vector2.ZERO, boost)


func add_faller():
    var new_faller = faller.instance()
    var width = GAME_WIDTH
    var new_pos_x = rng.randf_range(0, width)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -64
    $Fallers.call_deferred("add_child", new_faller)


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
    var new_star = SilverStar.instance()
    var width = GAME_WIDTH
    var new_pos_x = rng.randf_range(0, width)
    new_star.position.x = new_pos_x
    new_star.position.y = -64
    new_star.angular_velocity = rng.randf_range(-5, 5)
    $Fallers.call_deferred("add_child", new_star)


func add_star():
    var new_star = Star.instance()
    var width = GAME_WIDTH
    var height = GAME_HEIGHT
    var new_pos_x = rng.randf_range(40, width - 40)
    var new_pos_y = rng.randf_range(40, height - 40)
    new_star.position = Vector2(new_pos_x, new_pos_y)
    $Stars.call_deferred("add_child", new_star)


func add_laser():
    var new_laser = Laser.instance()
    var new_pos_y = rng.randf_range(40, GAME_HEIGHT - 40)
    var new_pos_x = 47
    if randi() % 2 == 0:
        new_pos_x = GAME_WIDTH - 47
        new_laser.flip()
    new_laser.position = Vector2(new_pos_x, new_pos_y)
    $Fallers.call_deferred("add_child", new_laser)


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

    $PlaceRope.play()
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


func game_over():
    game_over = true
    player.queue_free()
    if points > GameData.highscore:
        GameData.highscore = points
        GameData.save_score()
    $GameOver.update_score()
    $GameOver.show()
    get_tree().paused = true
    $RollingText.queue_free()
    $Fallers.queue_free()
    $Stars.queue_free()
    $HUD.queue_free()
    despawn_rope()


func _on_GameOver_play_again():
    emit_signal("play_again")
