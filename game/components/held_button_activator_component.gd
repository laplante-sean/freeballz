extends Node2D
class_name HeldButtonActivatorComponent

signal pressed()

@export var arc_width: float = 5.0
@export var arc_color: Color = Color.WHITE
@export var arc_radius: float = 50.0
@export var hold_duration: float = 1.0

var timer: Timer
var cancelled: bool = false


func _ready():
    var parent = get_parent()
    if not parent is Button and not parent is TextureButton:
        push_error("HeldButtonActivatorComponent must be child of Button or TextureButton")
        return

    position = parent.size / 2

    parent.button_down.connect(_on_button_down)
    parent.button_up.connect(_on_button_up)

    timer = Timer.new()
    timer.one_shot = true
    timer.autostart = false
    timer.timeout.connect(_on_timer_timeout)
    add_child(timer)


func _process(_delta):
    queue_redraw()


func _draw():
    if timer.is_stopped():
        return
    var complete = (hold_duration - timer.time_left) / hold_duration
    var arc = complete * 360
    draw_arc(Vector2.ZERO, arc_radius,
        0, deg_to_rad(arc), 100, arc_color,
        arc_width, true)


func _on_button_down():
    cancelled = false
    timer.start(hold_duration)


func _on_button_up():
    if timer.time_left != 0:
        cancelled = true
        timer.stop()


func _on_timer_timeout():
    pressed.emit()

