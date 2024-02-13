extends Control
class_name BallUIComponent

@onready var game_stats = Utils.get_game_stats()


func _process(_delta):
    queue_redraw()


func _draw():
    var pos = Vector2(size.x / 2.0, size.y / 2.0)
    draw_circle(pos, game_stats.ball_radius, game_stats.ball_color)
