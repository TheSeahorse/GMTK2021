extends Container

onready var rope = preload("res://Rope.tscn")
onready var faller = preload("res://Faller.tscn")
onready var long_faller = preload("res://LongFaller.tscn")
onready var Star = preload("res://Star.tscn")
onready var BlackStar = preload("res://BlackStar.tscn")
onready var Laser = preload("res://Laser.tscn")
onready var SilverStar = preload("res://SilverStar.tscn")
onready var player = preload("res://Player.tscn").instance()

var GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")

var GameData

signal play_again
signal back_to_menu

var rng = RandomNumberGenerator.new()
var current_rope = null
var current_star
var points = 0
var game_over = false
var can_spawn_rope = true
var level = 0
var faller_wait_time = 3

var level_first_faller = false
var previous_star_position : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    $MouseCooldown.hide()
    $MouseActive.show()
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

    # Set mouse sprite position
    var new_position = get_global_mouse_position()
    $MouseActive.position = new_position
    $MouseCooldown.position = new_position


func _physics_process(_delta):
    if not game_over and ((player.position.y > GAME_HEIGHT + 32 or player.position.y < -32) or (player.position.x < 0 or player.position.x > GAME_WIDTH)):
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
    increase_level()


func _on_FallerTimer_timeout():
    spawner()


func _on_OutOfZoneTimer_timeout():
    end_game()


func _on_RopeRecharge_timeout():
    can_spawn_rope = true
    $MouseActive.show()
    $MouseCooldown.hide()


func _player_touched_star(body):
    var is_a_star = true
    if body.is_in_group("one_point"):
        points += 1
        $StarPickup.play()
        add_star()
    elif body.is_in_group("five_points"):
        $SilverStarPickup.play()
        points += 5
    elif body.is_in_group("minus_points"):
        $BlackStarPickup.play()
        points -= 3
    else:
        is_a_star = false

    if is_a_star:
        if points == 1:
            $LevelTimer.start()
            increase_level()

        body.die()
        $HUD/Label.text = str(points)


func increase_level():
    level += 1
    level_first_faller = true
    $RollingText.roll_text("Stage " + str(level))
    spawner()


func spawner():
    var chance = rng.randi() % 100
    match level:
        0:
            pass
        1:
            faller_wait_time = 10
            add_faller()
        2:
            faller_wait_time = 5
            add_faller()
        3:
            if level_first_faller:
                add_long_faller()
            else:
                if chance < 30:
                    add_long_faller()
                else:
                    add_faller()
        4:
            faller_wait_time = 3
            if level_first_faller:
                add_falling_star()
            else:
                if chance < 50:
                    add_long_faller()
                else:
                    add_faller()
                if chance < 10:
                    add_falling_star()
        5:
            if chance < 50:
                add_long_faller()
            else:
                add_faller()
            if chance < 10:
                add_falling_star()
        6:
            if level_first_faller:
                add_laser()
            else:
                if chance < 50:
                    add_long_faller()
                else:
                    add_faller()
                if chance < 15:
                    add_falling_star()

        7:
            if chance < 70:
                add_long_faller()
            else:
                add_faller()
            if chance < 15:
                add_falling_star()
            if chance < 20:
                add_laser()
        8:
            if chance < 70:
                add_long_faller()
            else:
                add_faller()
            if chance < 15:
                add_falling_star()
            if chance < 25:
                add_laser()
        9:
            if chance < 70:
                add_long_faller()
            else:
                add_faller()
            if chance < 15:
                add_falling_star()
            if chance < 30:
                add_laser()
        10:
            if chance < 70:
                add_long_faller()
            if chance < 70:
                add_faller()
            if chance < 20:
                add_falling_star()
            if chance < 30:
                add_laser()
        _:
            faller_wait_time = 3.0 - (level / 25)
            if chance < 70 + level:
                add_long_faller()
            if chance < 70 + level:
                add_faller()
            if chance < 30 + level:
                add_laser()

            if chance < 20 + level:
                add_falling_star()
                if rng.randi() % 100 < 50 + level:
                    # Double star
                    add_falling_star()


    level_first_faller = false
    $FallerTimer.wait_time = faller_wait_time
    $FallerTimer.start(faller_wait_time)


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
    var new_pos_x = rng.randf_range(40, GAME_WIDTH - 40)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -64
    $Fallers.call_deferred("add_child", new_faller)


func add_long_faller():
    var new_faller = long_faller.instance()
    var new_pos_x = rng.randf_range(256, GAME_WIDTH - 256)
    new_faller.position.x = new_pos_x
    new_faller.position.y = -256
    if rng.randi() % 2 == 0:
        new_faller.rotation_degrees = 90
    $Fallers.add_child(new_faller)


func add_falling_star():
    var new_star = SilverStar.instance()
    var new_pos_x = rng.randf_range(40, GAME_WIDTH - 40)
    new_star.position.x = new_pos_x
    new_star.position.y = -64
    new_star.angular_velocity = rng.randf_range(-5, 5)
    $Fallers.call_deferred("add_child", new_star)


func add_star():
    var new_star = Star.instance()
    new_star.position = previous_star_position
    while new_star.position.distance_to(previous_star_position) < 500:
        var new_pos_x = rng.randf_range(40, GAME_WIDTH - 40)
        var new_pos_y = rng.randf_range(40, GAME_HEIGHT - 40)
        new_star.position = Vector2(new_pos_x, new_pos_y)
        if new_star.position.y < 100 and new_star.position.x > 1650:
            # Star is too close to score. Loop again.
            new_star.position = previous_star_position
    previous_star_position = new_star.position
    $Stars.call_deferred("add_child", new_star)


func add_black_star():
    var new_star = BlackStar.instance()
    var pos_x = rng.randf_range(100, GAME_WIDTH - 100)
    var pos_y = rng.randf_range(100, GAME_HEIGHT - 100)
    new_star.position = Vector2(pos_x, pos_y)
    $Stars.call_deferred("add_child", new_star)


func add_laser():
    var new_laser = Laser.instance()
    var new_pos_y = rng.randf_range(40, GAME_HEIGHT - 40)
    var new_pos_x = 47
    if rng.randi() % 2 == 0:
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
    if player_pos.distance_to(mouse_pos) > 320:
        var angle = mouse_pos.angle_to_point(player_pos)
        mouse_pos = player_pos + Vector2(cos(angle) * 320, sin(angle) * 320)
    current_rope = rope.instance()
    if player_pos.distance_to(mouse_pos) < 60:
        var angle = mouse_pos.angle_to_point(player_pos)
        mouse_pos = player_pos + Vector2(cos(angle) * 60, sin(angle) * 60)
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
    $MouseActive.hide()
    $MouseCooldown.show()
    player.rope_cooldown(true)


func end_game():
    game_over = true
    player.queue_free()
    if points > GameData.highscore:
        GameData.highscore = points
        GameData.save_score()

    $GameOver.update_score()
    $GameOver.show()
    $RollingText.queue_free()
    $Fallers.queue_free()
    $Stars.queue_free()
    $HUD.queue_free()
    despawn_rope()
    $MouseActive.hide()
    $MouseCooldown.hide()
    Input.set_custom_mouse_cursor(null)
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    get_tree().paused = true


func _on_GameOver_play_again():
    emit_signal("play_again")


func _on_GameOver_back_to_menu():
    emit_signal("back_to_menu")
