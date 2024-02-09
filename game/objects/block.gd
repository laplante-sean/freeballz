extends CharacterBody2D
class_name Block

var max_health: int = 1
var health: int = 1 : set = set_health
var width: int = 50
var collision_shape : RectangleShape2D = null

@onready var game_stats = Utils.get_game_stats()
@onready var collider = $Collider
@onready var label = $Label


func setup(b_width: int, b_health: int):
    width = b_width
    health = b_health
    max_health = b_health


func _ready():
    collision_shape = RectangleShape2D.new()
    collision_shape.extents = Vector2(width / 2.0, width / 2.0)
    collider.shape = collision_shape
    collider.position.x += width / 2.0
    collider.position.y += width / 2.0
    label.position.x += width / 2.0
    label.position.y += width / 2.0
    label.text = str(health)


func get_block_color() -> Color:
    var hue_angle = game_stats.block_hue_start
    hue_angle = ((hue_angle + (health * 15)) + health)
    var hue = hue_angle / 360
    hue -= int(hue)
    return Color.from_hsv(hue, game_stats.block_saturation / 100.0, game_stats.block_brightness / 100.0)


func _draw():
    var points : PackedVector2Array = PackedVector2Array([
        Vector2.ZERO,
        Vector2(width, 0),
        Vector2(width, width),
        Vector2(0, width)
    ])

    draw_colored_polygon(points, get_block_color())


func _process(_delta):
    queue_redraw()


func set_health(value):
    health = max(value, 0)
    if label != null:
        label.text = str(health)
    if health == 0:
        queue_free()


func hit():
    health -= 1
