extends Resource
class_name PlayerStats

signal coins_changed(amount: int)
signal balls_changed(amount: int)

var coins: int = 0 : set = _set_coins
var balls: int = 1 : set = _set_balls
var level: int = 0


func save_stats():
    return {
        "coins": coins,
        "balls": balls,
        "level": level
    }


func load_stats(obj: Dictionary):
    coins = obj.coins
    balls = obj.balls
    level = obj.level


func _set_coins(value: int):
    coins = value
    coins_changed.emit(coins)


func _set_balls(value: int):
    balls = value
    balls_changed.emit(balls)
