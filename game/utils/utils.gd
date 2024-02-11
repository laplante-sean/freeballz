extends Node


func get_game_stats() -> GameStats:
    return ResourceLoader.load("res://game/stats/game_stats.tres")


func get_player_stats() -> PlayerStats:
    return ResourceLoader.load("res://game/stats/player_stats.tres")


func has_save_file() -> bool:
    return false


func save_game(block_container: Node2D):
    var player_stats = get_player_stats()
    var game_stats = get_game_stats()
    var player_stats_json = player_stats.save_stats()
    var game_stats_json = game_stats.save_stats()


func load_game():
    pass
