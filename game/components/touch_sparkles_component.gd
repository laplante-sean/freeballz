extends GPUParticles2D
class_name TouchSparklesComponent


func _process(_delta):
    if emitting:
        global_position = get_global_mouse_position()


func _input(event):
    if event is InputEventScreenTouch:
        if event.is_pressed():
            emitting = true
        elif event.is_released() and emitting:
            emitting = false
