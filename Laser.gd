extends RigidBody2D

onready var number_3 = preload("res://Graphics/kenney/PNG/Retina/number_3.png")
onready var number_2 = preload("res://Graphics/kenney/PNG/Retina/number_2.png")
onready var number_1 = preload("res://Graphics/kenney/PNG/Retina/number_1.png")

var countdown = 4

func _ready():
    $LaserGun.play()

func _on_Timer_timeout():
    countdown -= 1
    match countdown:
        3:
            $NumbersSprite.show()
            $NumbersSprite.texture = number_3
        2:
            $NumbersSprite.texture = number_2
        1:
            $NumbersSprite.texture = number_1
        0:
            $Area2D/CollisionShape2D.disabled = false
            $NumbersSprite.hide()
            $LongLaser.show()
            $FadeTween.interpolate_property($LongLaser, "modulate" , Color(1,1,1,1), Color(1,1,1,0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
            $FadeTween.start()
        -1:
            $Area2D/CollisionShape2D.disabled = true
        -2:
            self.queue_free()




func _on_Laser_body_entered(body):
    if body is Faller:
        body.queue_free()
    elif body is Player:
        get_parent().get_parent().end_game()


func flip():
    self.rotation_degrees = 180
    $NumbersSprite.rotation_degrees = 180
