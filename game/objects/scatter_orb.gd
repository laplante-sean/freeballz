extends Area2D
class_name ScatterOrb

const BallScene: PackedScene = preload("res://game/objects/ball.tscn")

var current_radius: float = 0.0
var entered_bodies: Array = []

@onready var game_stats = Utils.get_game_stats()


func _ready():
    current_radius = game_stats.scatter_orb_animation_radius_start
    var tween = get_tree().create_tween()
    tween.set_loops(0)
    tween.tween_property(self, "current_radius", game_stats.scatter_orb_animation_radius_end, 0.05)
    tween.chain().tween_property(self, "current_radius", game_stats.scatter_orb_animation_radius_start, 0.05)


func _process(delta):
    queue_redraw()


func _draw():
    draw_arc(
        Vector2.ZERO, current_radius, 0, deg_to_rad(360), 100,
        game_stats.scatter_orb_color,
        game_stats.scatter_orb_thickness, true)


func disolve():
    queue_free()


func get_color() -> Color:
    var hue_angle = randf_range(0, 360)
    var hue = hue_angle / 360
    return Color.from_hsv(hue, game_stats.block_saturation / 100.0, game_stats.block_brightness / 100.0)


func _on_body_entered(body):
    if not body is Ball:
        return
    if body in entered_bodies:
        return
    entered_bodies.append(body)

    var game_scene: Game = get_tree().current_scene
    var launch_point = game_scene.launch_point
    
    for _idx in range(game_stats.scatter_orb_count):
        var ball = BallScene.instantiate()

        entered_bodies.append(ball)

        # Configure first
        ball.tree_exiting.connect(game_scene._on_ball_tree_exiting)
        ball.fire_ball = game_scene.fire_ball
        ball.passthrough = game_scene.passthrough

        var dir = body.direction.rotated(deg_to_rad(randf_range(-45, 45)))

        # Then add it to the scene and fire
        launch_point.add_child(ball)
        ball.ball_color = get_color()
        ball.global_position = global_position
        ball.fire(dir)
        game_scene.balls_out += 1
