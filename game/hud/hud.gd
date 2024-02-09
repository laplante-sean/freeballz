extends VBoxContainer
class_name HUD

signal balls_down_button_pressed()

@onready var player_stats = Utils.get_player_stats()
@onready var coin_label = $TopPanel/MarginContainer/HBoxContainer/CoinLabel
@onready var num_balls_label = $TopPanel/MarginContainer/HBoxContainer/NumBallsLabel


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
