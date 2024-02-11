extends Node2D
class_name Game

const BlockScene: PackedScene = preload("res://game/objects/block.tscn")
const BallScene: PackedScene = preload("res://game/objects/ball.tscn")
const CoinScene: PackedScene = preload("res://game/objects/coin.tscn")

enum GameState {
    PREPARE_SHOT,
    EXECUTE_SHOT
}

var block_width: int = 0
var screen_size: Vector2 = Vector2.ZERO
var game_state: GameState = GameState.PREPARE_SHOT : set = _set_game_state
var balls_out: int = 0
var show_shot_ball: bool = true
var shot_cancelled: bool = false
var first_row: bool = true
var top_offset: float = 0.0

@onready var blocks = $Blocks
@onready var game_stats = Utils.get_game_stats()
@onready var player_stats = Utils.get_player_stats()
@onready var launch_point = $LaunchPointComponent
@onready var ceiling_collision_shape_2d = $Boundaries/Ceiling/CollisionShape2D
@onready var left_wall = $Boundaries/LeftWall
@onready var right_wall = $Boundaries/RightWall
@onready var floor = $Boundaries/Floor
@onready var left_wall_collision_shape_2d = $Boundaries/LeftWall/CollisionShape2D
@onready var right_wall_collision_shape_2d = $Boundaries/RightWall/CollisionShape2D


func _ready():
    screen_size = get_viewport().get_visible_rect().size
    _adjust_boundaries()

    block_width = int(floor(screen_size.x / game_stats.block_columns)) - game_stats.block_spacing
    launch_point.global_position = game_stats.launch_point_global_position
    top_offset = ceiling_collision_shape_2d.shape.size.y

    print("Screen Size        : ", screen_size)
    print("Block Width        : ", block_width)
    print("Ball Radius        : ", game_stats.ball_radius)
    print("Block columns      : ", game_stats.block_columns)
    print("Block spacing      : ", game_stats.block_spacing)

    create_row()


func _adjust_boundaries():
    # Designed for 1080x1920 but the scale is set to expand in the height.
    # So on taller/shorter devices we need to adjust the position of the floor
    # and the size of the wall colliders
    screen_size = get_viewport().get_visible_rect().size
    var offset = Vector2(0, screen_size.y - 1920)  # Could be negative for smaller displays

    # Adjust floor and launch point
    floor.global_position += offset
    game_stats.launch_point_global_position += offset - Vector2(0, game_stats.ball_radius)

    # Adjust left and right boundaries
    left_wall.global_position.y = screen_size.y / 2
    right_wall.global_position.y = screen_size.y / 2
    left_wall_collision_shape_2d.shape.size.y = screen_size.y
    right_wall_collision_shape_2d.shape.size.y += screen_size.y


func _process(_delta):
    if Input.is_action_just_pressed("ui_accept") and game_state == GameState.EXECUTE_SHOT:
        balls_down()

    if game_state == GameState.EXECUTE_SHOT:
        if balls_out == 0:
            game_state = GameState.PREPARE_SHOT
            create_row()
    queue_redraw()


func _draw():
    if show_shot_ball:
        draw_circle(launch_point.position, game_stats.ball_radius, game_stats.ball_color)


func get_block_value():
    var chance = randi_range(0, 100)
    if chance < 33:
        # 1/3rd chance of the block value being double the current level
        return player_stats.level * 2

    # otherwise the new blocks value is just the level
    return player_stats.level


func create_block(x: float, y: float):
    var block = BlockScene.instantiate()
    var block_value = get_block_value()
    block.setup(block_width, block_value)
    blocks.add_child(block)
    block.global_position = Vector2(x, y)


func create_coin(x: float, y: float):
    var coin = CoinScene.instantiate()
    blocks.add_child(coin)
    coin.global_position = Vector2(x + (block_width / 2.0), y + (block_width / 2.0))


func create_pickup_ball(x: float, y: float):
    var ball = BallScene.instantiate()
    ball.is_colletible = true
    blocks.add_child(ball)
    ball.global_position = Vector2(x + (block_width / 2.0), y + (block_width / 2.0))


func balls_down():
    shot_cancelled = true
    for child in launch_point.get_children():
        if not child is Ball:
            continue
        child.drop()


func create_row():
    var x: float = game_stats.block_spacing / 2
    var y: float = top_offset
    var coin_column: int = game_stats.block_columns
    var pickup_ball_column: int = game_stats.block_columns

    # Level starts at 0 so we increment first
    player_stats.level += 1

    # Generate a coin and pickup ball per row
    coin_column = randi_range(0, game_stats.block_columns - 1)
    pickup_ball_column = randi_range(1, game_stats.block_columns - 1)
    if coin_column == pickup_ball_column:
        pickup_ball_column -= 1

    # Add blocks to the row
    for col in range(game_stats.block_columns):
        if col == coin_column:
            create_coin(x, y)
        elif col == pickup_ball_column:
            create_pickup_ball(x, y)
        else:
            create_block(x, y)
        x += block_width + game_stats.block_spacing

    _move_down()
    first_row = false


func _move_down():
    # Tween the row down
    var tween = get_tree().create_tween()
    var tween_dest = Vector2.ZERO
    tween_dest = blocks.position + Vector2(0, block_width + game_stats.block_spacing)
    tween.tween_property(blocks, "position", tween_dest, 0.25)


func _set_game_state(value: GameState):
    game_state = value
    match game_state:
        GameState.PREPARE_SHOT:
            launch_point.enabled = true
        GameState.EXECUTE_SHOT:
            launch_point.enabled = false


func _on_ball_tree_exiting():
    show_shot_ball = true
    balls_out = max(balls_out - 1, 0)


func _on_launch_point_component_fire(dir: Vector2):
    game_state = GameState.EXECUTE_SHOT
    show_shot_ball = false
    shot_cancelled = false

    for _idx in range(player_stats.balls):
        var ball = BallScene.instantiate()
        ball.tree_exiting.connect(_on_ball_tree_exiting)
        launch_point.add_child(ball)
        ball.fire(dir)
        balls_out += 1

        await get_tree().create_timer(game_stats.ball_spawn_timer).timeout

        if shot_cancelled:
            shot_cancelled = false
            break


func _on_hud_balls_down_button_pressed():
    balls_down()
