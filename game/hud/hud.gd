extends VBoxContainer
class_name HUD

signal balls_down_button_pressed()
signal shot_lines_button_pressed()
signal fire_ball_button_pressed()
signal kill_bottom_row_button_pressed()

@onready var player_stats = Utils.get_player_stats()
@onready var coin_label = $TopPanel/MarginContainer/HBoxContainer/CoinLabel
@onready var num_balls_label = $TopPanel/MarginContainer/HBoxContainer/NumBallsLabel
@onready var bottom_panel = $BottomPanel
@onready var top_panel = $TopPanel


func _ready():
    coin_label.text = "0"
    num_balls_label.text = "1"
    player_stats.coins_changed.connect(_on_player_stats_coins_changed)
    player_stats.balls_changed.connect(_on_player_stats_balls_changed)


func _on_player_stats_coins_changed(coins: int):
    coin_label.text = str(coins)


func _on_player_stats_balls_changed(balls: int):
    num_balls_label.text = str(balls)


func _on_balls_down_held_button_activator_pressed():
    balls_down_button_pressed.emit()


func _on_shot_lines_button_pressed():
    shot_lines_button_pressed.emit()


func _on_fire_ball_button_pressed():
    fire_ball_button_pressed.emit()


func _on_kill_bottom_row_pressed():
    kill_bottom_row_button_pressed.emit()


func get_bottom_panel_height() -> float:
    return bottom_panel.size.y


func get_top_panel_height() -> float:
    return top_panel.size.y
