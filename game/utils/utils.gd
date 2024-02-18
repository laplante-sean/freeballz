extends Node

const SAVE_DATA_PATH = "user://free_ballz_save.json"

var is_new_game: bool = true


func get_block_width() -> int:
    var game_stats = get_game_stats()
    var screen_size = get_viewport().get_visible_rect().size
    return int(floor(screen_size.x / game_stats.block_columns)) - game_stats.block_spacing


func get_game_floor_y_pos() -> float:
    var floor = get_tree().current_scene.find_child("Floor") as StaticBody2D
    var collider = floor.find_child("CollisionShape2D") as CollisionShape2D
    var offset = collider.shape.size.y / 2.0
    return floor.global_position.y - offset


func get_game_stats() -> GameStats:
    return ResourceLoader.load("res://game/stats/game_stats.tres")


func get_player_stats() -> PlayerStats:
    return ResourceLoader.load("res://game/stats/player_stats.tres")


func has_save_file() -> bool:
    if not FileAccess.file_exists(SAVE_DATA_PATH):
        return false
    return _read_saved_json() != null


func _read_saved_json():
    var file = FileAccess.open(SAVE_DATA_PATH, FileAccess.READ)
    var data = file.get_line()
    var ret = JSON.parse_string(data)
    file.close()
    return ret


func clear_save_game():
    if not has_save_file():
        return
    var file = FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
    file.store_line("")
    file.close()


func save_game(block_container: Node2D) -> bool:
    if not block_container:
        return false

    var save_data = {}
    var player_stats = get_player_stats()
    var game_stats = get_game_stats()
    var player_stats_obj = player_stats.save_stats()
    var game_stats_obj = game_stats.save_stats()

    save_data.player_stats = player_stats_obj
    save_data.game_stats = game_stats_obj
    save_data.blocks = {}
    save_data.blocks.global_position = var_to_str(block_container.global_position)
    save_data.blocks.children = []

    for child in block_container.get_children():
        var child_obj = {}
        if child is Ball:
            child_obj.path = "res://game/objects/ball.tscn"
        elif child is BombBlock:
            child_obj.path = "res://game/objects/bomb_block.tscn"
            child_obj.max_health = child.max_health
            child_obj.health = child.health
        elif child is Block:
            child_obj.path = "res://game/objects/block.tscn"
            child_obj.max_health = child.max_health
            child_obj.health = child.health
        elif child is Coin:
            child_obj.path = "res://game/objects/coin.tscn"
        else:
            print("ERROR: Unknown child type. Can't save")
            continue

        child_obj.position = var_to_str(child.position)
        save_data.blocks.children.append(child_obj)

    var json_string = JSON.stringify(save_data)
    var save_file = FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
    save_file.store_line(json_string)
    save_file.close()
    return true


func load_game(block_container: Node2D) -> bool:
    if not has_save_file():
        return false

    var block_width = get_block_width()
    var save_data = _read_saved_json()
    if not save_data:
        return false

    var player_stats = get_player_stats()
    var game_stats = get_game_stats()

    player_stats.load_stats(save_data.player_stats)
    game_stats.load_stats(save_data.game_stats)

    for child in save_data.blocks.children:
        var obj = load(child.path) as PackedScene
        var inst = obj.instantiate()
        if inst is Block:
            inst.setup(block_width, child.max_health)
            inst.health = child.health
        if inst is Ball:
            inst.is_colletible = true

        if inst is BombBlock:
            # Setup the signal
            inst.exploded.connect(get_tree().current_scene._on_bomb_block_exploded)

        block_container.add_child(inst)
        inst.position = str_to_var(child.position)

    block_container.global_position = str_to_var(save_data.blocks.global_position)
    return true
