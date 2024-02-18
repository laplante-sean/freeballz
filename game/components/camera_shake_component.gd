extends Node
class_name CameraShakeComponent

@export var camera_2d: Camera2D

var shake = 0


func _ready():
    camera_2d.drag_horizontal_enabled = true
    camera_2d.drag_vertical_enabled = true


func _process(_delta):
    camera_2d.drag_horizontal_offset = randf_range(-shake, shake)
    camera_2d.drag_vertical_offset = randf_range(-shake, shake)


func add_screenshake(amount, duration):
    if shake != 0:
        # Don't double up on screen shake
        return

    shake = amount
    get_tree().create_timer(duration).timeout.connect(_on_Timer_timeout)


func _on_Timer_timeout():
    shake = 0
