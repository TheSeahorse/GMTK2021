extends Control

var GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")


func _ready():
    hide()


func roll_text(text):
    $Label.text = text
    $Label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    $Tween.interpolate_property($Label, "rect_position",
        Vector2($Label.rect_position.x, GAME_HEIGHT + 100), Vector2($Label.rect_position.x, - 100), 5,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
    show()


func _on_Tween_tween_all_completed():
    hide()
