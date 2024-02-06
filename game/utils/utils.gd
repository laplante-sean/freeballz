extends Node


func get_game_stats() -> GameStats:
    return ResourceLoader.load("res://game/stats/game_stats.tres")


func get_player_stats() -> PlayerStats:
    return ResourceLoader.load("res://game/stats/player_stats.tres")
