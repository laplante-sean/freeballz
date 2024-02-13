extends Control
class_name CoinUIComponent

@onready var game_stats = Utils.get_game_stats()


func _process(_delta):
    queue_redraw()


func _draw():
    var pos = Vector2(size.x / 2.0, size.y / 2.0)
    draw_arc(pos, game_stats.coin_radius, 0, deg_to_rad(360), 100, game_stats.coin_color, game_stats.coin_line_thickness, true)
