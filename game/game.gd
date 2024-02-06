extends Node2D

const BlockScene: PackedScene = preload("res://game/objects/block.tscn")
const BallScene: PackedScene = preload("res://game/objects/ball.tscn")

@export var block_columns:  int = 8
@export var block_spacing: int = 2

var block_width: int = 0
var screen_size: Vector2 = Vector2.ZERO

@onready var launch_point = $LaunchPointComponent


func _ready():
    screen_size = get_viewport().get_visible_rect().size
    block_width = int(floor(screen_size.x / block_columns)) - block_spacing

    print("Screen Size: ", screen_size)
    print("Block Width: ", block_width)

    create_row()


func create_block(x: float, y: float, row: Node2D):
    var block = BlockScene.instantiate()
    block.setup(block_width, Color.BLUE, 1)
    row.add_child(block)
    block.global_position = Vector2(x, y)


func create_row():
    var x: float = 1
    var y: float = 0

    # Create a row
    var row: Node2D = Node2D.new()
    add_child(row)
    row.global_position = Vector2.ZERO

    # Add blocks to the row
    for _i in range(block_columns):
        create_block(x, y, row)
        x += block_width + block_spacing

    # Tween the row down
    var tween = get_tree().create_tween()
    tween.tween_property(row, "position", row.position + Vector2(0, block_width + block_spacing), 0.25)


func _on_launch_point_component_fire(dir: Vector2):
    var ball = BallScene.instantiate()
    launch_point.add_child(ball)
    ball.fire(dir)
