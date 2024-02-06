extends Marker2D
class_name LaunchPointComponent

signal fire(dir: Vector2)

@export var color: Color = Color.WHITE
@export var width: float = 3.0
@export var antialiased: bool = true
@export var max_shot_lines: int = 3
@export var ball_radius: float = 15.0

var screen_size: Vector2 = Vector2.ZERO
var touching: bool = false
var shot_direction: Vector2 = Vector2.ZERO
var ray_casts: Array[RayCast2D] = []
var render_count: int = 1 : set = _set_render_count


func _ready():
    screen_size = get_viewport().get_visible_rect().size
    for _idx in range(max_shot_lines):
        var tmp = RayCast2D.new()
        tmp.set_collision_mask_value(1, true)
        tmp.set_collision_mask_value(2, true)
        add_child(tmp)
        ray_casts.append(tmp)


func _process(_delta):
    queue_redraw()


func _draw():
    if touching:
        draw_shot_line()


func draw_shot_line():
    var global_mouse_pos: Vector2 = get_global_mouse_position()
    shot_direction = global_position.direction_to(global_mouse_pos).normalized()
    var target: Vector2 = Vector2.ZERO
    var normal: Vector2 = Vector2.ZERO

    # If we're at a steep/almost 90 degree angle or more than cancel the shot
    var angle = shot_direction.angle()
    if angle > -0.075 or angle < -3.075:
        touching = false
        return

    var direction = shot_direction
    for idx in range(render_count):
        var ray_cast_2d = ray_casts[idx]
        var start = Vector2(target)
        ray_cast_2d.position = start

        if idx > 0:
            direction = direction.bounce(normal)

        target = direction * screen_size.y
        ray_cast_2d.target_position = target
        ray_cast_2d.force_raycast_update()
        target = to_local(ray_cast_2d.get_collision_point())
        normal = ray_cast_2d.get_collision_normal()
        
        var adjust = normal * ball_radius
        adjust = Vector2(target.x, target.y) + adjust
        target = target.move_toward(adjust, ball_radius)
        draw_circle(target, ball_radius, color)
        draw_line(start, target, color, width, antialiased)


func _input(event):
    if event is InputEventScreenTouch:
        if event.is_pressed():
            touching = true
        elif event.is_released() and touching:
            touching = false
            fire.emit(shot_direction)


func _set_render_count(value: int):
    render_count = clamp(value, 1, max_shot_lines)
