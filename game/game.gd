extends Node2D
class_name Game

const BlockScene: PackedScene = preload("res://game/objects/block.tscn")
const BallScene: PackedScene = preload("res://game/objects/ball.tscn")

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

@onready var blocks = $Blocks
@onready var game_stats = Utils.get_game_stats()
@onready var player_stats = Utils.get_player_stats()
@onready var launch_point = $LaunchPointComponent


func _ready():
    screen_size = get_viewport().get_visible_rect().size
    block_width = int(floor(screen_size.x / game_stats.block_columns)) - game_stats.block_spacing
    launch_point.global_position = game_stats.launch_point_global_position

    print("Screen Size: ", screen_size)
    print("Block Width: ", block_width)

    create_row()


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


func create_block(x: float, y: float):
    var block = BlockScene.instantiate()
    block.setup(block_width, Color.BLUE, 1)
    blocks.add_child(block)
    block.global_position = Vector2(x, y)


func balls_down():
    shot_cancelled = true
    for child in launch_point.get_children():
        if not child is Ball:
            continue
        child.drop()


func create_row():
    var x: float = 1
    var y: float = 0

    # Add blocks to the row
    for _i in range(game_stats.block_columns):
        create_block(x, y)
        x += block_width + game_stats.block_spacing

    # Tween the row down
    var tween = get_tree().create_tween()
    var tween_dest = blocks.position + Vector2(0, block_width + game_stats.block_spacing)
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
