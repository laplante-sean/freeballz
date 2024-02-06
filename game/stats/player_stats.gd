extends Resource
class_name PlayerStats

var coins: int = 0
var balls: int = 100


func save_stats():
    return {
        "coins": coins,
        "balls": balls
    }


func load_stats(obj: Dictionary):
    coins = obj.coins
    balls = obj.balls
