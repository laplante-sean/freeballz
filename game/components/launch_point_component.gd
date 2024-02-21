extends Marker2D
class_name LaunchPointComponent

signal fire(dir: Vector2)

@export var max_shot_lines: int = 3

var screen_size: Vector2 = Vector2.ZERO
var touching: bool = false
var shot_direction: Vector2 = Vector2.ZERO
var shape_casts: Array[ShapeCast2D] = []
var render_count: int = 1 : set = _set_render_count
var enabled: bool = true
var fire_ball: bool = false
var passthrough: bool = false

@onready var game_stats: GameStats = Utils.get_game_stats()


func _ready():
    screen_size = get_viewport().get_visible_rect().size
    for _idx in range(max_shot_lines):
        var tmp_shape_cast: ShapeCast2D = ShapeCast2D.new()
        var tmp_shape: CircleShape2D = CircleShape2D.new()
        tmp_shape.radius = game_stats.ball_radius
        tmp_shape_cast.shape = tmp_shape

        tmp_shape_cast.set_collision_mask_value(1, true) # world
        tmp_shape_cast.set_collision_mask_value(2, true) # blocks
        add_child(tmp_shape_cast)
        shape_casts.append(tmp_shape_cast)


func _process(_delta):
    queue_redraw()


func _draw():
    if touching and enabled:
        draw_shot_line()


func update_collisions_masks():
    for idx in range(max_shot_lines):
        var shape_cast = shape_casts[idx]
        if fire_ball or passthrough:
            shape_cast.set_collision_mask_value(2, false)  # blocks
        else:
            shape_cast.set_collision_mask_value(2, true)  # blocks


func draw_shot_line():
    var global_mouse_pos: Vector2 = get_global_mouse_position()
    shot_direction = global_position.direction_to(global_mouse_pos)
    var target: Vector2 = Vector2.ZERO
    var normal: Vector2 = Vector2.ZERO
    var hit_ceiling: bool = false
    
    var color = game_stats.shot_line_color
    var ball_color = game_stats.ball_color
    if fire_ball:
        color = game_stats.fire_ball_color
        ball_color = game_stats.fire_ball_color

    # Handle whether or not we collide with blocks
    update_collisions_masks()

    # If we're at a steep/almost 90 degree angle or more than cancel the shot
    var angle = shot_direction.angle()
    if angle > -0.075 or angle < -3.075:
        touching = false
        return

    var direction = shot_direction
    for idx in range(render_count):
        var shape_cast_2d: ShapeCast2D = shape_casts[idx]
        var start = Vector2(target)
        shape_cast_2d.position = start

        if passthrough and hit_ceiling:
            shape_cast_2d.set_collision_mask_value(2, true)

        if idx > 0:
            direction = direction.bounce(normal)

        target = direction * screen_size.y
        shape_cast_2d.target_position = target
        shape_cast_2d.force_shapecast_update()
        target = to_local(shape_cast_2d.get_collision_point(0))
        normal = shape_cast_2d.get_collision_normal(0)

        var adjust = normal * game_stats.ball_radius
        adjust = Vector2(target.x, target.y) + adjust
        target = target.move_toward(adjust, game_stats.ball_radius)

        if passthrough and not hit_ceiling:
            draw_arc(target, game_stats.ball_radius, 0, deg_to_rad(360), 100, game_stats.ball_color, 5, true)
        else:
            draw_circle(target, game_stats.ball_radius, ball_color)
        draw_line(start, target, color, game_stats.shot_line_width, game_stats.shot_line_antialiased)

        # Finally check if we hit the ceiling and set the bool for the next/subsequent shot lines
        var collider = shape_cast_2d.get_collider(0)
        if collider and collider.is_in_group("GameCeiling"):
            hit_ceiling = true
        if collider and collider.is_in_group("GameFloor"):
            break  # Balls don't bounce off the game floor


func _input(event):
    if not enabled:
        return

    if event is InputEventScreenTouch:
        if event.is_pressed():
            touching = true
        elif event.is_released() and touching:
            touching = false
            fire.emit(shot_direction)


func _set_render_count(value: int):
    render_count = clamp(value, 1, max_shot_lines)
